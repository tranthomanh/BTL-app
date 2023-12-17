import 'package:ccvc_mobile/presentation/notification/bloc/screen_stype.dart';
import 'package:ccvc_mobile/utils/extensions/int_extension.dart';

///type noti :
///1 - thích
///2 - người khác comment
///3 - gửi lời mời kết bạn
///4 - chấp nhận lời mời kết bạn
///5 - chủ bài viết comment
class NotificationModel {
  String notiId;
  String userReactId;
  String userId;
  String detailId;
  ScreenType typeNoti;
  DateTime createAt;
  bool isRead;

  String nameReact = '';
  int countLike = 0;
  bool isPostOfMe;

  NotificationModel({
    this.notiId = '',
    this.isPostOfMe = false,
    required this.userId,
    required this.userReactId,
    required this.detailId,
    required this.typeNoti,
    required this.createAt,
    required this.isRead,
  });

  void setIsPostOfMe(bool isPostOfMe) {
    this.isPostOfMe = isPostOfMe;
  }

  void setNameReact(String name) {
    nameReact = name;
  }

  void setCountLike(int countLike) {
    this.countLike = countLike;
  }

  Map<String, dynamic> toJson(NotificationModel instance) => <String, dynamic>{
        'user_id': instance.userId,
        'detail_id': instance.detailId,
        'type_noti': instance.typeNoti.getType,
        'create_at': instance.createAt.millisecondsSinceEpoch,
        'is_read': instance.isRead,
        'user_react_id': instance.userReactId,
        'noti_id': instance.notiId,
      };

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notiId: json['noti_id'] as String,
      userReactId: json['user_react_id'] as String,
      userId: json['user_id'] as String,
      detailId: json['detail_id'] as String,
      typeNoti: (json['type_noti'] as int).getType,
      createAt: (json['create_at'] as int).convertToDateTime,
      isRead: json['is_read'] as bool,
    );
  }
}

extension getNoti on int {
  ScreenType get getType {
    switch (this) {
      case 1:
        return ScreenType.LIKE;
      case 2:
        return ScreenType.YOU_COMMENT;
      case 3:
        return ScreenType.FRIEND_REQUEST;
      case 4:
        return ScreenType.ACCEPT_REQUEST_FRIEND;
      case 5:
        return ScreenType.ME_COMMENT;
      default:
        return ScreenType.LIKE;
    }
  }
}
