import 'dart:async';
import 'dart:developer';

import 'package:ccvc_mobile/config/app_config.dart';
import 'package:ccvc_mobile/config/crypto_config.dart';
import 'package:ccvc_mobile/config/default_env.dart';
import 'package:ccvc_mobile/config/firebase_config.dart';
import 'package:ccvc_mobile/domain/locals/prefs_service.dart';
import 'package:ccvc_mobile/domain/model/message_model/message_sms_model.dart';
import 'package:ccvc_mobile/domain/model/message_model/message_user.dart';
import 'package:ccvc_mobile/domain/model/message_model/room_chat_model.dart';
import 'package:ccvc_mobile/domain/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class MessageService {
  static Map<String, RoomChatModel> idRoomChat = {};
  static Stream<List<RoomChatModel>>? getRoomChat(String idUser) {
    return FirebaseSetup.fireStore
        .collection(DefaultEnv.usersCollection)
        .doc(idUser)
        .collection(DefaultEnv.messCollection)
        .orderBy("update_at", descending: true)
        .snapshots(includeMetadataChanges: true)
        .transform(
      StreamTransformer.fromHandlers(
        handleData: (docSnap, sink) async {
          final data = <RoomChatModel>[];
          await Future.forEach(docSnap.docs,
              (QueryDocumentSnapshot<Map<String, dynamic>> element) async {
            if (!idRoomChat.keys.contains(element.id)) {
              final profileRoom = await FirebaseSetup.fireStore
                  .collection(DefaultEnv.messCollection)
                  .doc(element.id)
                  .get();
              final jsonProfileRoom = profileRoom.data();
              if (jsonProfileRoom != null) {
                final listPeople = await _getChatRoomUser(
                    jsonProfileRoom['people_chat'] as List<dynamic>, idUser);
                final room = RoomChatModel(
                  roomId: element.id,
                  peopleChats: listPeople,
                  colorChart: jsonProfileRoom['color_chart'] ?? 0,
                  isGroup: jsonProfileRoom['is_group'] ?? false,
                  tenNhom: jsonProfileRoom['ten_nhom'] ?? '',
                );
                data.add(room);
                idRoomChat.addAll({element.id: room});
                sink.add(data);
              }
            } else {
              if (idRoomChat[element.id] != null) {
                data.add(idRoomChat[element.id]!);
                sink.add(data);
              }
            }
          });
          if (data.isEmpty) {
            sink.add([]);
          }
        },
      ),
    );
  }

  static Future<UserModel> getUserChat(String id) async {
    late UserModel userProfile;
    final result = await FirebaseSetup.fireStore
        .collection(DefaultEnv.usersCollection)
        .doc(id)
        .collection(DefaultEnv.profileCollection)
        .get(const GetOptions(source: Source.server));
    for (final element in result.docs) {
      userProfile = UserModel.fromJson(element.data());
    }
    return userProfile;
  }

  static Future<List<PeopleChat>> _getChatRoomUser(
      List<dynamic> data, String idUser) async {
    final pepole = <PeopleChat>[];
    for (final element in data) {
      final id = element['user_id'];
      if (id != idUser) {
        final userInfo = await getUserChat(id.toString());

        pepole.add(
          PeopleChat(
              userId: id,
              avatarUrl: userInfo.avatarUrl ?? '',
              nameDisplay: userInfo.nameDisplay ?? '',
              bietDanh: element['biet_danh'] ?? '',
              isOnline: userInfo.onlineFlag ?? false),
        );
      }
    }
    return pepole;
  }

  static Stream<List<MessageSmsModel>>? smsRealTime(String idRoom) {
    final String idUser = PrefsService.getUserId();
    try {
      return FirebaseSetup.fireStore
          .collection(DefaultEnv.messCollection)
          .doc(idRoom)
          .collection(idRoom)
          .orderBy('create_at', descending: false)
          .snapshots()
          .transform(
        StreamTransformer.fromHandlers(
          handleData: (docSnap, sink) {
            final data = <MessageSmsModel>[];
            for (var element in docSnap.docs) {
              final json = element.data();
              final result = MessageSmsModel.fromJson(json);
              if (result.senderId != idUser &&
                  result.daXem?.contains(idUser) == false) {
                _updateDaXemSms(idRoom, element.id, idUser);
              }
              data.add(result);
            }
            sink.add(data);
          },
        ),
      );
    } catch (e) {}
  }

  static Stream<List<MessageSmsModel>>? smsRealTimeMain(String idRoom) {
    final String idUser = PrefsService.getUserId();
    try {
      return FirebaseSetup.fireStore
          .collection(DefaultEnv.messCollection)
          .doc(idRoom)
          .collection(idRoom)
          .orderBy('create_at', descending: true)
          .limit(6)
          .snapshots()
          .transform(
        StreamTransformer.fromHandlers(
          handleData: (docSnap, sink) {
            final data = <MessageSmsModel>[];
            for (var element in docSnap.docs) {
              final json = element.data();
              final result = MessageSmsModel.fromJson(json);
              if (result.senderId != idUser &&
                  result.daXem?.contains(idUser) == false) {
                result.isDaXem = false;
                data.add(result);
              }
            }
            if (data.isEmpty) {
              if (docSnap.docs.isNotEmpty) {
                final doc = docSnap.docs.first;
                final result = MessageSmsModel.fromJson(doc.data());
                result.isDaXem = true;
                data.add(result);
              }
            }
            sink.add(data);
          },
        ),
      );
    } catch (e) {}
  }

  static void sendSms(String idRoom, MessageSmsModel messageSmsModel) {
    final doc = FirebaseSetup.fireStore
        .collection(DefaultEnv.messCollection)
        .doc(idRoom)
        .collection(idRoom)
        .doc(messageSmsModel.messageId);
    doc.set(messageSmsModel.toJson());
  }

  static void getToken(List<String> tokens, List<String> userId) {
    for (final element in userId) {
      FirebaseSetup.fireStore
          .collection(DefaultEnv.usersCollection)
          .doc(element)
          .collection(DefaultEnv.tokenFcm)
          .get()
          .then((value) {
        for (final element in value.docs) {
          final token = element.data()['token_fcm'];
          tokens.add(token);
        }
      });
    }
  }

  static Future<List<RoomChatModel>> findRoomChat(String idUser) async {
    final result = <RoomChatModel>[];
    final listRoom = await FirebaseSetup.fireStore
        .collection(DefaultEnv.messCollection)
        .get();
    await Future.forEach(listRoom.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> item) async {
      final data = await FirebaseSetup.fireStore
          .collection(DefaultEnv.messCollection)
          .doc(item.id)
          .get();
      final room = RoomChatModel.fromJson(data.data() ?? {});
      result.add(room);
    });

    return result;
  }

  static Future<void> addPeopleRoomChat(
      List<PeopleChat> peopleChat, String idRoomChat) async {
    await Future.forEach(peopleChat, (PeopleChat element) async {
      await _addUserRoomChat(element.userId, idRoomChat);
    });
    await FirebaseSetup.fireStore
        .collection(DefaultEnv.messCollection)
        .doc(idRoomChat)
        .update({
      'people_chat':
          FieldValue.arrayUnion(peopleChat.map((e) => e.toJson()).toList())
    });
  }

  static Future<String> createRoomChat(RoomChatModel roomChatModel) async {
    await FirebaseSetup.fireStore
        .collection(DefaultEnv.messCollection)
        .doc(roomChatModel.roomId)
        .set(roomChatModel.toJson());
    for (var element in roomChatModel.peopleChats) {
      _addUserRoomChat(element.userId, roomChatModel.roomId);
    }
    return roomChatModel.roomId;
  }

  static void removeChat(String idRoom, String idUser) {
    FirebaseSetup.fireStore
        .collection(DefaultEnv.messCollection)
        .doc(idRoom)
        .update({
      'people_chat': FieldValue.arrayRemove([
        {'user_id': idUser}
      ])
    });
    FirebaseSetup.fireStore
        .collection(DefaultEnv.usersCollection)
        .doc(idUser)
        .collection(DefaultEnv.messCollection)
        .doc(idRoom)
        .delete();
  }

  static Future<void> _addUserRoomChat(String id, String idRoom) async {
    await FirebaseSetup.fireStore
        .collection(DefaultEnv.usersCollection)
        .doc(id)
        .collection(DefaultEnv.messCollection)
        .doc(idRoom)
        .set(MessageUser(
                id: idRoom,
                createAt: DateTime.now().millisecondsSinceEpoch,
                updateAt: DateTime.now().millisecondsSinceEpoch)
            .toJson());
  }

  static void updateRoomChatUser(String idUser, String idRoom) {
    FirebaseSetup.fireStore
        .collection(DefaultEnv.usersCollection)
        .doc(idUser)
        .collection(DefaultEnv.messCollection)
        .doc(idRoom)
        .update({'update_at': DateTime.now().millisecondsSinceEpoch});
  }

  static void _updateDaXemSms(String idRoom, String idSms, String idUser) {
    FirebaseSetup.fireStore
        .collection(DefaultEnv.messCollection)
        .doc(idRoom)
        .collection(idRoom)
        .doc(idSms)
        .update({
      'da_xem': FieldValue.arrayUnion([idUser])
    });
  }

  static void changeNameGroup(String idGroup, String name) {
    FirebaseSetup.fireStore
        .collection(DefaultEnv.messCollection)
        .doc(idGroup)
        .update({'ten_nhom': name});
  }

  static void goBoTinNhan(String idMessage, String idRoom) {
log(' .>>>>>>>>>>${idMessage}');
log('>>>>>>>>>>>>${idRoom}');
    FirebaseSetup.fireStore
        .collection(DefaultEnv.messCollection)
        .doc(idRoom)
        .collection(idRoom)
        .doc(idMessage)
        .update({'message_type_id': SmsType.Tin_Nhan_Go_bo.getInt()});
  }
}
