import 'dart:developer';

import 'package:ccvc_mobile/config/default_env.dart';
import 'package:ccvc_mobile/config/firebase_config.dart';
import 'package:ccvc_mobile/domain/locals/prefs_service.dart';
import 'package:ccvc_mobile/domain/model/profile_model.dart/friend_model.dart';
import 'package:ccvc_mobile/domain/model/profile_model.dart/friend_request_model.dart';
import 'package:ccvc_mobile/domain/model/user_model.dart';
import 'package:ccvc_mobile/utils/extensions/string_extension.dart';

class ProfileService {
  static Future<List<UserModel>> listFriends(String id,
      {bool getBloc = true}) async {
    final listIdFriend = await ProfileService.getIdsRelationShipUser();
    final listsIdFriendRequest = await ProfileService.getIdsFriendRequestUser();
    final idUser = PrefsService.getUserId();
    final List<UserModel> data = [];
    final result = await FirebaseSetup.fireStore
        .collection(DefaultEnv.usersCollection)
        .doc(id)
        .collection(DefaultEnv.relationshipsCollection)
        .get();
    for (var element in result.docs) {
      final vl = FriendModel.fromJson(element.data());
      if (vl.userId2 != idUser) {
        final user = await getUserChat(vl.userId2);
        if (user != null) {
          user.peopleType = peopleType(
              user.userId ?? '', listsIdFriendRequest, listIdFriend, vl);
          if (getBloc) {
            if (user.peopleType != PeopleType.Block) {
              data.add(user);
            }
          } else {
            data.add(user);
          }
        }
      }
    }
    final setData = <UserModel>[];
    for (var element in data) {
      if (setData.map((e) => e.userId).contains(element.userId) == false) {
        setData.add(element);
      }
    }
    return setData;
  }

  static Future<List<UserModel>> blocklist(String id,
      {bool getBloc = true}) async {
    final listIdFriend = await ProfileService.getIdsRelationShipUser();
    final listsIdFriendRequest = await ProfileService.getIdsFriendRequestUser();
    final idUser = PrefsService.getUserId();
    final List<UserModel> data = [];
    final result = await FirebaseSetup.fireStore
        .collection(DefaultEnv.usersCollection)
        .doc(id)
        .collection(DefaultEnv.relationshipsCollection)
        .get();
    for (var element in result.docs) {
      final vl = FriendModel.fromJson(element.data());
      if (vl.userId2 != idUser) {
        final user = await getUserChat(vl.userId2);
        if (user != null) {
          user.peopleType = peopleType(
              user.userId ?? '', listsIdFriendRequest, listIdFriend, vl);
          if (getBloc) {
            if (user.peopleType == PeopleType.Block) {
              data.add(user);
            }
          } else {
            data.add(user);
          }
        }
      }
    }
    final setData = <UserModel>[];
    for (var element in data) {
      if (setData.map((e) => e.userId).contains(element.userId) == false) {
        setData.add(element);
      }
    }
    return setData;
  }

  static Stream<UserModel?> searchKey(
      String keySearch, List<UserModel> blocs) async* {
    final data = await FirebaseSetup.fireStore
        .collection(DefaultEnv.usersCollection)
        .get();
    final List<UserModel> value = [];
    for (final element in data.docs) {
      if (blocs.map((e) => e.userId).contains(element.id) ||
          element.id == PrefsService.getUserId()) {
        continue;
      }
      final result = await FirebaseSetup.fireStore
          .collection(DefaultEnv.usersCollection)
          .doc(element.id)
          .collection(DefaultEnv.profileCollection)
          .get();
      for (final e in result.docs) {
        final data = UserModel.fromJson(e.data());
        if ((data.nameDisplay?.trim().toLowerCase().vietNameseParse().contains(
                    keySearch.trim().toLowerCase().vietNameseParse()) ??
                false) &&
            data.userId != PrefsService.getUserId()) {
          value.add(data);
          yield data;
        }
      }
    }
    if (value.isEmpty) {
      yield null;
    }
  }

  static PeopleType? peopleType(String id, List<String> listsIdFriendRequest,
      List<String> listIdFriend, FriendModel friendModel) {
    if (friendModel.type == 2) {
      return PeopleType.Block;
    }
    if (listsIdFriendRequest.contains(id.trim())) {
      return PeopleType.FriendRequest;
    }
    if (listIdFriend.contains(id)) {
      return PeopleType.Friend;
    }
  }

  static Future<UserModel?> getUserChat(String id) async {
    UserModel? userProfile;
    final result = await FirebaseSetup.fireStore
        .collection(DefaultEnv.usersCollection)
        .doc(id)
        .collection(DefaultEnv.profileCollection)
        .get();

    for (final element in result.docs) {
      userProfile = UserModel.fromJson(element.data());
    }
    return userProfile;
  }

  static Future<List<String>> getIdsRelationShipUser() async {
    final idUser = PrefsService.getUserId();
    final List<String> data = [];
    final result = await FirebaseSetup.fireStore
        .collection(DefaultEnv.usersCollection)
        .doc(idUser)
        .collection(DefaultEnv.relationshipsCollection)
        .get();
    for (var element in result.docs) {
      final vl = FriendModel.fromJson(element.data());
      data.add(vl.userId2);
    }
    return data;
  }

  static Future<List<String>> getIdsFriendRequestUser() async {
    final idUser = PrefsService.getUserId();
    final List<String> data = [];
    final result = await FirebaseSetup.fireStore
        .collection(DefaultEnv.usersCollection)
        .doc(idUser)
        .collection(DefaultEnv.friendRequestCollection)
        .get();
    for (var element in result.docs) {
      final vl = FriendRequestModel.fromJson(element.data());
      data.add(vl.receiverId);
    }
    return data;
  }

  static Future<List<UserModel>> listFriendRequest(
    String id,
  ) async {
    try {
      final List<UserModel> data = [];
      final result = await FirebaseSetup.fireStore
          .collection(DefaultEnv.usersCollection)
          .doc(id)
          .collection(DefaultEnv.friendRequestCollection)
          .get();
      for (var element in result.docs) {
        final vl = FriendRequestModel.fromJson(element.data());

        final user = await getUserChat(vl.senderId);
        if (user != null && user.userId != PrefsService.getUserId()) {
          data.add(user);
        }
      }
      return data;
    } catch (e) {
      return [];
    }
  }

  static Future<void> confirmAccecptFreind(String idConfirm) async {
    String ownerId = PrefsService.getUserId();
    await FirebaseSetup.fireStore
        .collection(DefaultEnv.usersCollection)
        .doc(ownerId)
        .collection(DefaultEnv.relationshipsCollection)
        .add(FriendModel(ownerId, idConfirm, 1).toJson());
    await FirebaseSetup.fireStore
        .collection(DefaultEnv.usersCollection)
        .doc(idConfirm)
        .collection(DefaultEnv.relationshipsCollection)
        .add(FriendModel(idConfirm, ownerId, 1).toJson());
    await delectFriendRequets(idConfirm);
  }

  static Future<void> delectFriendRequets(String idConfirm) async {
    String ownerId = PrefsService.getUserId();
    final result = await FirebaseSetup.fireStore
        .collection(DefaultEnv.usersCollection)
        .doc(ownerId)
        .collection(DefaultEnv.friendRequestCollection)
        .get();

    for (final e in result.docs) {
      final vl = FriendRequestModel.fromJson(e.data());
      if (vl.senderId == idConfirm) {
        await FirebaseSetup.fireStore
            .collection(DefaultEnv.usersCollection)
            .doc(ownerId)
            .collection(DefaultEnv.friendRequestCollection)
            .doc(e.id)
            .delete();
      }
    }
  }
}
