import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:ccvc_mobile/data/exception/app_exception.dart';
import 'package:ccvc_mobile/data/helper/firebase/firebase_const.dart';
import 'package:ccvc_mobile/domain/locals/prefs_service.dart';
import 'package:ccvc_mobile/domain/model/comment_model.dart';
import 'package:ccvc_mobile/domain/model/fcm_tokken_model.dart';
import 'package:ccvc_mobile/domain/model/notify/notification_model.dart';
import 'package:ccvc_mobile/domain/model/post_model.dart';
import 'package:ccvc_mobile/domain/model/user_model.dart';
import 'package:ccvc_mobile/presentation/notification/bloc/screen_stype.dart';
import 'package:ccvc_mobile/utils/constants/dafault_env.dart';
import 'package:ccvc_mobile/utils/extensions/string_extension.dart';
import 'package:ccvc_mobile/utils/push_notification.dart';
import 'package:ccvc_mobile/widgets/dialog/message_dialog/message_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:html_editor_enhanced/utils/utils.dart';

class FireStoreMethod {
  static Future<UserModel> getDataUserInfo(String id) async {
    try {
      final QuerySnapshot<dynamic> snap = await FirebaseFirestore.instance
          .collection(DefaultEnv.socialNetwork)
          .doc(DefaultEnv.develop)
          .collection(DefaultEnv.users)
          .doc(id)
          .collection(DefaultEnv.profile)
          .get();

      final UserModel userInfo = UserModel.fromJson(
        snap.docs.first.data(),
      );
      return userInfo;
    } catch (error) {
      if (error is TimeoutException || error is NoNetworkException) {
        MessageConfig.show(
          title: 'Không có kết nối Interet',
          messState: MessState.error,
        );
      } else {
        MessageConfig.show(
          title: 'Truy cập thất bại, vui lòng thử lại !',
          messState: MessState.error,
        );
      }

      return UserModel.empty();
    }
  }

  static Future<bool> isDataUser(String userId) async {
    try {
      final QuerySnapshot<dynamic> snap = await FirebaseFirestore.instance
          .collection(DefaultEnv.socialNetwork)
          .doc(DefaultEnv.develop)
          .collection(DefaultEnv.users)
          .get();

      for (final id in snap.docs) {
        if (id.id == userId) {
          return true;
        }
      }
      return false;
    } catch (error) {
      if (error is TimeoutException || error is NoNetworkException) {
        MessageConfig.show(
          title: 'Không có kết nối Interet',
          messState: MessState.error,
        );
      } else {
        MessageConfig.show(
          title: 'Truy cập thất bại, vui lòng thử lại !',
          messState: MessState.error,
        );
      }

      return false;
    }
  }

  static Future<void> updateUser(
    String userId,
    UserModel model,
  ) async {
    try {
      final QuerySnapshot<dynamic> snap = await FirebaseFirestore.instance
          .collection(DefaultEnv.socialNetwork)
          .doc(DefaultEnv.develop)
          .collection(DefaultEnv.users)
          .doc(userId)
          .collection(DefaultEnv.profile)
          .get();

      await FirebaseFirestore.instance
          .collection(DefaultEnv.socialNetwork)
          .doc(DefaultEnv.develop)
          .collection(DefaultEnv.users)
          .doc(userId)
          .collection(DefaultEnv.profile)
          .doc(snap.docs.first.id)
          .update(model.toJson(model));
    } catch (error) {
      if (error is TimeoutException || error is NoNetworkException) {
        MessageConfig.show(
          title: 'Không có kết nối Interet',
          messState: MessState.error,
        );
      } else {
        MessageConfig.show(
          title: 'Truy cập thất bại, vui lòng thử lại !',
          messState: MessState.error,
        );
      }
    }
  }

  static Future<void> saveInformationUser({
    required String id,
    required UserModel user,
  }) async {
    try {
      await firestore
          .collection(DefaultEnv.socialNetwork)
          .doc(DefaultEnv.develop)
          .collection(DefaultEnv.users)
          .doc(id)
          .collection(DefaultEnv.profile)
          .doc(getRandString(15).removeChar)
          .set(
            user.toJson(user),
          );
    } catch (error) {
      if (error is TimeoutException || error is NoNetworkException) {
        MessageConfig.show(
          title: 'Không có kết nối Interet',
          messState: MessState.error,
        );
      } else {
        MessageConfig.show(
          title: 'Truy cập thất bại, vui lòng thử lại !',
          messState: MessState.error,
        );
      }
    }
  }

  static Future<void> saveFlg({
    required String userId,
  }) async {
    try {
      await firestore
          .collection(DefaultEnv.socialNetwork)
          .doc(DefaultEnv.develop)
          .collection(DefaultEnv.users)
          .doc(userId)
          .set({'onlineFlag': true});
    } catch (error) {
      if (error is TimeoutException || error is NoNetworkException) {
        MessageConfig.show(
          title: 'Không có kết nối Interet',
          messState: MessState.error,
        );
      } else {
        MessageConfig.show(
          title: 'Truy cập thất bại, vui lòng thử lại !',
          messState: MessState.error,
        );
      }
    }
  }

  static Future<void> saveToken({
    required String userId,
    required FcmTokenModel fcmTokenModel,
  }) async {
    await deleteToken(userId: userId, token: fcmTokenModel.tokenFcm ?? '');

    try {
      await firestore
          .collection(DefaultEnv.socialNetwork)
          .doc(DefaultEnv.develop)
          .collection(DefaultEnv.users)
          .doc(userId)
          .collection(DefaultEnv.tokkenFcm)
          .doc(fcmTokenModel.tokenFcm)
          .set(fcmTokenModel.toJson(fcmTokenModel));
    } catch (error) {
      if (error is TimeoutException || error is NoNetworkException) {
        MessageConfig.show(
          title: 'Không có kết nối Interet',
          messState: MessState.error,
        );
      } else {
        MessageConfig.show(
          title: 'Truy cập thất bại, vui lòng thử lại !',
          messState: MessState.error,
        );
      }
    }
  }

  static Future<void> deleteToken({
    required String userId,
    required String token,
  }) async {
    try {
      await firestore
          .collection(DefaultEnv.socialNetwork)
          .doc(DefaultEnv.develop)
          .collection(DefaultEnv.users)
          .doc(userId)
          .collection(DefaultEnv.tokkenFcm)
          .get()
          .then((value) {
        for (final DocumentSnapshot post in value.docs) {
          if (post.id == token) {
            post.reference.delete();
          }
        }
      });
    } catch (error) {
      if (error is TimeoutException || error is NoNetworkException) {
        MessageConfig.show(
          title: 'Không có kết nối Interet',
          messState: MessState.error,
        );
      } else {
        MessageConfig.show(
          title: 'Truy cập thất bại, vui lòng thử lại !',
          messState: MessState.error,
        );
      }
    }
  }

  static Future<void> updateToken({
    required String userId,
    required String tokenOld,
    required FcmTokenModel fcmTokenModel,
  }) async {
    await deleteToken(userId: userId, token: fcmTokenModel.tokenFcm ?? '');

    try {
      await PrefsService.removeTokken();
    } catch (error) {
      if (error is TimeoutException || error is NoNetworkException) {
        MessageConfig.show(
          title: 'Không có kết nối Interet',
          messState: MessState.error,
        );
      } else {
        MessageConfig.show(
          title: 'Truy cập thất bại, vui lòng thử lại !',
          messState: MessState.error,
        );
      }
    }
    try {
      await firestore
          .collection(DefaultEnv.socialNetwork)
          .doc(DefaultEnv.develop)
          .collection(DefaultEnv.users)
          .doc(userId)
          .collection(DefaultEnv.tokkenFcm)
          .doc(fcmTokenModel.tokenFcm)
          .update(fcmTokenModel.toJson(fcmTokenModel));
    } catch (error) {
      if (error is TimeoutException || error is NoNetworkException) {
        MessageConfig.show(
          title: 'Không có kết nối Interet',
          messState: MessState.error,
        );
      } else {
        MessageConfig.show(
          title: 'Truy cập thất bại, vui lòng thử lại !',
          messState: MessState.error,
        );
      }
    }
  }

  static Future<FcmTokenModel> getTokenFcm({required String id}) async {
    try {
      final idToken = PrefsService.getToken();
      FcmTokenModel tokenModel = FcmTokenModel.empty();

      await FirebaseFirestore.instance
          .collection(DefaultEnv.socialNetwork)
          .doc(DefaultEnv.develop)
          .collection(DefaultEnv.users)
          .doc(id)
          .collection(DefaultEnv.tokkenFcm)
          .get()
          .then((value) {
        for (final data in value.docs) {
          if (data.id == idToken) {
            tokenModel = FcmTokenModel.fromJson(data.data());
          }
        }
      });

      return tokenModel;
    } catch (error) {
      if (error is TimeoutException || error is NoNetworkException) {
        MessageConfig.show(
          title: 'Không có kết nối Interet',
          messState: MessState.error,
        );
      } else {
        MessageConfig.show(
          title: 'Truy cập thất bại, vui lòng thử lại !',
          messState: MessState.error,
        );
      }
      return FcmTokenModel.empty();
    }
  }

  static Future<void> uploadImageToStorage(String id, Uint8List file) async {
    try {
      final Reference ref = storage.ref().child(id).child('avatarUser');

      await ref.putData(file);
    } catch (error) {
      if (error is TimeoutException || error is NoNetworkException) {
        MessageConfig.show(
          title: 'Không có kết nối Interet',
          messState: MessState.error,
        );
      } else {
        MessageConfig.show(
          title: 'Truy cập thất bại, vui lòng thử lại !',
          messState: MessState.error,
        );
      }
    }
  }

  static Future<void> removeImage(String id) async {
    try {
      final Reference ref = storage.ref().child(id);
      await ref.delete();
    } catch (error) {
      if (error is TimeoutException || error is NoNetworkException) {
        MessageConfig.show(
          title: 'Không có kết nối Interet',
          messState: MessState.error,
        );
      } else {
        MessageConfig.show(
          title: 'Truy cập thất bại, vui lòng thử lại !',
          messState: MessState.error,
        );
      }
    }
  }

  static Future<String> downImage(String id) async {
    String downUrlImage = '';
    try {
      downUrlImage =
          await storage.ref().child('$id/avatarUser').getDownloadURL();
    } catch (error) {
      if (error is TimeoutException || error is NoNetworkException) {
        MessageConfig.show(
          title: 'Không có kết nối Interet',
          messState: MessState.error,
        );
      } else {
        MessageConfig.show(
          title: 'Truy cập thất bại, vui lòng thử lại !',
          messState: MessState.error,
        );
      }
    }
    return downUrlImage;
  }

  static Future<void> uploadImageFromCreatePost({
    required String id,
    required String idPost,
    required Uint8List file,
  }) async {
    try {
      final Reference ref = storage
          .ref()
          .child(id)
          .child(DefaultEnv.postsCollection)
          .child(idPost);

      await ref.putData(file);
    } catch (error) {
      if (error is TimeoutException || error is NoNetworkException) {
        MessageConfig.show(
          title: 'Không có kết nối Interet',
          messState: MessState.error,
        );
      } else {
        MessageConfig.show(
          title: 'Truy cập thất bại, vui lòng thử lại !',
          messState: MessState.error,
        );
      }
    }
  }

  static Future<String> downImageCreatePost(
      {required String id, required String idPost}) async {
    String downUrlImage = '';
    try {
      downUrlImage = await storage
          .ref()
          .child('$id/${DefaultEnv.postsCollection}/$idPost')
          .getDownloadURL();
    } catch (error) {
      if (error is TimeoutException || error is NoNetworkException) {
        MessageConfig.show(
          title: 'Không có kết nối Interet',
          messState: MessState.error,
        );
      } else {
        MessageConfig.show(
          title: 'Truy cập thất bại, vui lòng thử lại !',
          messState: MessState.error,
        );
      }
    }
    return downUrlImage;
  }

  static Future<void> createPost(
      {required PostModel model, required String postId}) async {
    try {
      await firestore
          .collection(DefaultEnv.socialNetwork)
          .doc(DefaultEnv.develop)
          .collection(DefaultEnv.postsCollection)
          .doc(postId)
          .set(model.toJson(model));
    } catch (error) {
      if (error is TimeoutException || error is NoNetworkException) {
        MessageConfig.show(
          title: 'Không có kết nối Interet',
          messState: MessState.error,
        );
      } else {
        MessageConfig.show(
          title: 'Truy cập thất bại, vui lòng thử lại !',
          messState: MessState.error,
        );
      }
    }
  }

  static Future<int> getCountLike({required String postId}) async {
    int countLike = 0;
    try {
      final DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(DefaultEnv.socialNetwork)
          .doc(DefaultEnv.develop)
          .collection(DefaultEnv.posts)
          .doc(postId)
          .get();

      if (documentSnapshot.exists) {
        final Map<String, dynamic> fetchDoc =
            documentSnapshot.data() as Map<String, dynamic>;

        countLike = (fetchDoc['likes'] as List).length;
      }
    } catch (error) {
      if (error is TimeoutException || error is NoNetworkException) {
        MessageConfig.show(
          title: 'Không có kết nối Interet',
          messState: MessState.error,
        );
      } else {
        MessageConfig.show(
          title: 'Truy cập thất bại, vui lòng thử lại !',
          messState: MessState.error,
        );
      }
    }

    return countLike;
  }

  static Future<List<String>> getListToken(String userId) async {
    final List<String> data = [];
    try {
      await FirebaseFirestore.instance
          .collection(DefaultEnv.socialNetwork)
          .doc(DefaultEnv.develop)
          .collection(DefaultEnv.users)
          .doc(userId)
          .collection(DefaultEnv.tokkenFcm)
          .get()
          .then((value) {
        for (final value in value.docs) {
          data.add(value.id);
        }
      });
    } catch (error) {
      if (error is TimeoutException || error is NoNetworkException) {
        MessageConfig.show(
          title: 'Không có kết nối Interet',
          messState: MessState.error,
        );
      } else {
        MessageConfig.show(
          title: 'Truy cập thất bại, vui lòng thử lại !',
          messState: MessState.error,
        );
      }
    }

    return data;
  }

  static Future<List<PushDataComment>> getTokenUserCommentPost(
    PostModel postModel,
    NotificationModel notificationModel,
  ) async {
    final List<PushDataComment> value = [];
    try {
      //bỏ những userId trùng nhau
      final List<String> listDataUser = [];
      (postModel.comments ?? []).forEach((element) {
        if ((element.author?.userId ?? '') != PrefsService.getUserId()) {
          listDataUser.add(element.author?.userId ?? '');
        }
      });

      final List<String> listIdUSer = [];

      listIdUSer.addAll(listDataUser.toSet().toList());

      if (!listIdUSer.contains(postModel.author?.userId ?? '')) {
        listIdUSer.add(postModel.author?.userId ?? '');
      }

      listIdUSer.forEach((element) {
        if (element != PrefsService.getUserId()) {
          notificationModel.userId = element;
          isCreateNotification(
            model: notificationModel,
            userId: element,
          );
        }
      });

      for (final userId in listIdUSer) {
        final List<String> tokens = await getListToken(userId);
        value.add(
          PushDataComment(
            tokens: tokens,
            userId: userId,
            isPostToMe: (postModel.author?.userId ?? '') == userId,
          ),
        );
      }
    } catch (error) {
      if (error is TimeoutException || error is NoNetworkException) {
        MessageConfig.show(
          title: 'Không có kết nối Interet',
          messState: MessState.error,
        );
      } else {
        MessageConfig.show(
          title: 'Truy cập thất bại, vui lòng thử lại !',
          messState: MessState.error,
        );
      }
    }
    return value;
  }

  static Future<void> createNotification({
    required NotificationModel model,
    required String userId,
    String postId = '',
    PostModel? postModel,
  }) async {
    final List<String> tokens = await getListToken(userId);
    final UserModel userReact = await getDataUserInfo(model.userReactId);
    model.setNameReact(userReact.nameDisplay ?? '');
    if (model.typeNoti == ScreenType.LIKE) {
      await isCreateNotification(
        model: model,
        userId: userId,
      );

      PushFCM.pushNotification(
        tokens: [
          PushDataComment(
            tokens: tokens,
            userId: userId,
            isPostToMe: false,
          )
        ],
        data: model,
        nameReact: model.nameReact,
      );
    } else if (model.typeNoti == ScreenType.ME_COMMENT ||
        model.typeNoti == ScreenType.YOU_COMMENT) {
      final List<PushDataComment> tokensComment = await getTokenUserCommentPost(
        postModel ?? PostModel.empty(),
        model,
      );

      PushFCM.pushNotification(
        tokens: tokensComment,
        data: model,
        nameReact: model.nameReact,
      );
    } else {
      await isCreateNotification(model: model, userId: userId);
      PushFCM.pushNotification(
        tokens: [
          PushDataComment(
            tokens: tokens,
            userId: userId,
            isPostToMe: false,
          )
        ],
        data: model,
        nameReact: model.nameReact,
      );
    }
  }

  static Future<bool> isCreateNotification({
    required NotificationModel model,
    required String userId,
  }) async {
    final notiId = getRandString(15).removeChar;
    model.notiId = notiId;
    model.userId = userId;
    try {
      await FirebaseFirestore.instance
          .collection(DefaultEnv.socialNetwork)
          .doc(DefaultEnv.develop)
          .collection(DefaultEnv.users)
          .doc(userId)
          .collection(DefaultEnv.noifications)
          .doc(notiId)
          .set(model.toJson(model));
    } catch (error) {
      if (error is TimeoutException || error is NoNetworkException) {
        MessageConfig.show(
          title: 'Không có kết nối Interet',
          messState: MessState.error,
        );
      } else {
        MessageConfig.show(
          title: 'Truy cập thất bại, vui lòng thử lại !',
          messState: MessState.error,
        );
      }

      return false;
    }

    return true;
  }

  static Future<void> deleteNoti({
    required NotificationModel model,
    required String userId,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection(DefaultEnv.socialNetwork)
          .doc(DefaultEnv.develop)
          .collection(DefaultEnv.users)
          .doc(userId)
          .collection(DefaultEnv.noifications)
          .get()
          .then((value) {
        for (final DocumentSnapshot data in value.docs) {
          if (data.id == model.notiId) {
            data.reference.delete();
          }
        }
      });
    } catch (error) {
      if (error is TimeoutException || error is NoNetworkException) {
        MessageConfig.show(
          title: 'Không có kết nối Interet',
          messState: MessState.error,
        );
      } else {
        MessageConfig.show(
          title: 'Truy cập thất bại, vui lòng thử lại !',
          messState: MessState.error,
        );
      }
    }
  }

  static Future<void> readNoti({
    required NotificationModel model,
    required String userId,
  }) async {
    model.isRead = true;
    try {
      await FirebaseFirestore.instance
          .collection(DefaultEnv.socialNetwork)
          .doc(DefaultEnv.develop)
          .collection(DefaultEnv.users)
          .doc(userId)
          .collection(DefaultEnv.noifications)
          .doc(model.notiId)
          .update(model.toJson(model));
    } catch (error) {
      if (error is TimeoutException || error is NoNetworkException) {
        MessageConfig.show(
          title: 'Không có kết nối Interet',
          messState: MessState.error,
        );
      } else {
        MessageConfig.show(
          title: 'Truy cập thất bại, vui lòng thử lại !',
          messState: MessState.error,
        );
      }
    }
  }

  static Future<PostModel> getPostModel(String postId) async {
    PostModel postModel = PostModel.empty();
    try {
      final DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(DefaultEnv.socialNetwork)
          .doc(DefaultEnv.develop)
          .collection(DefaultEnv.posts)
          .doc(postId)
          .get();

      if (documentSnapshot.exists) {
        final Map<String, dynamic> fetchDoc =
            documentSnapshot.data() as Map<String, dynamic>;

        postModel = PostModel.fromJson(fetchDoc);
        postModel.author = UserModel(userId: fetchDoc['user_id']);
      }
    } catch (error) {
      if (error is TimeoutException || error is NoNetworkException) {
        MessageConfig.show(
          title: 'Không có kết nối Interet',
          messState: MessState.error,
        );
      } else {
        MessageConfig.show(
          title: 'Truy cập thất bại, vui lòng thử lại !',
          messState: MessState.error,
        );
      }
    }
    return postModel;
  }

  static Future<void> getDataNoti(
    Function(List<NotificationModel>) callBack,
  ) async {
    try {
      FirebaseFirestore.instance
          .collection(DefaultEnv.socialNetwork)
          .doc(DefaultEnv.develop)
          .collection(DefaultEnv.users)
          .doc(PrefsService.getUserId())
          .collection(DefaultEnv.noifications)
          .orderBy('create_at', descending: true)
          .snapshots()
          .listen((data) async {
        final List<NotificationModel> result = [];

        if (data.docs.isNotEmpty) {
          for (final e in data.docs) {
            final noti = NotificationModel.fromJson(e.data());

            final UserModel userReact = await getDataUserInfo(noti.userReactId);

            noti.setNameReact(userReact.nameDisplay ?? '');

            if (noti.typeNoti == ScreenType.LIKE) {
              final int countLike = await getCountLike(postId: noti.detailId);
              noti.setCountLike(countLike);
            }

            if (noti.typeNoti == ScreenType.YOU_COMMENT) {
              final PostModel postModel = await getPostModel(noti.detailId);
              noti.setIsPostOfMe(
                (postModel.author?.userId ?? '') == noti.userId,
              );
            }

            result.add(noti);
          }
        }
        Timer(const Duration(microseconds: 500), () {
          callBack(result);
        });
      });
    } catch (error) {
      if (error is TimeoutException || error is NoNetworkException) {
        MessageConfig.show(
          title: 'Không có kết nối Interet',
          messState: MessState.error,
        );
      } else {
        MessageConfig.show(
          title: 'Truy cập thất bại, vui lòng thử lại !',
          messState: MessState.error,
        );
      }
    }
  }

  static Future<void> readAllNoti({
    required String userId,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection(DefaultEnv.socialNetwork)
          .doc(DefaultEnv.develop)
          .collection(DefaultEnv.users)
          .doc(userId)
          .collection(DefaultEnv.noifications)
          .get()
          .then((value) async {
        for (final noti in value.docs) {
          await readNoti(
            model: NotificationModel.fromJson(noti.data()),
            userId: userId,
          );
        }
      });
    } catch (error) {
      if (error is TimeoutException || error is NoNetworkException) {
        MessageConfig.show(
          title: 'Không có kết nối Interet',
          messState: MessState.error,
        );
      } else {
        MessageConfig.show(
          title: 'Truy cập thất bại, vui lòng thử lại !',
          messState: MessState.error,
        );
      }
    }
  }
}

class PushDataComment {
  List<String> tokens;
  String userId;
  bool isPostToMe;

  PushDataComment({
    required this.tokens,
    required this.userId,
    required this.isPostToMe,
  });
}
