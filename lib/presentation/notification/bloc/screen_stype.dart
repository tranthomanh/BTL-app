import 'package:ccvc_mobile/presentation/post/ui/post_screen.dart';
import 'package:ccvc_mobile/presentation/profile/ui/profile_screen.dart';
import 'package:flutter/material.dart';

enum ScreenType {
  ME_COMMENT,
  LIKE,
  FRIEND_REQUEST,
  ACCEPT_REQUEST_FRIEND,
  YOU_COMMENT
}

extension ScreenTypeExtension on ScreenType {
  String getTitle({int countLike = 0, bool isPostToMe = false}) {
    switch (this) {
      case ScreenType.FRIEND_REQUEST:
        return ' đã gửi đến bạn lời mời kết bạn.';
      case ScreenType.YOU_COMMENT:
        return isPostToMe
            ? ' đã bình luận bài viết của bạn.'
            : ' đã bình luận bài viết mà bạn đang theo dõi';
      case ScreenType.ME_COMMENT:
        return ' đã bình luận bài viết của họ.';
      case ScreenType.ACCEPT_REQUEST_FRIEND:
        return ' đã chấp nhận lời mời kết bạn của bạn';
      case ScreenType.LIKE:
        return countLike == 1
            ? ' đã thích bài viết của bạn'
            : ' và ${countLike - 1} người khác đã thích bài viết của bạn.';
    }
  }

  void navigatorScreen(
      {required BuildContext context, required String detailId}) {
    switch (this) {
      case ScreenType.FRIEND_REQUEST:
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(userId: detailId),
            ),
          );
          break;
        }
      case ScreenType.ACCEPT_REQUEST_FRIEND:
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(userId: detailId),
            ),
          );
          break;
        }
      case ScreenType.ME_COMMENT:
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostScreen(postId: detailId),
            ),
          );
          break;
        }
      case ScreenType.YOU_COMMENT:
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostScreen(postId: detailId),
            ),
          );
          break;
        }
      case ScreenType.LIKE:
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostScreen(postId: detailId),
            ),
          );
          break;
        }
    }
  }

  ///type noti :
  ///1 - thích
  ///2 - người khác comment comment
  ///3 - gửi lời mời ket ban
  ///4 - chấp nhận lời mời kết bạn
  ///5 - chủ bài viết comment
  int get getType {
    switch (this) {
      case ScreenType.ACCEPT_REQUEST_FRIEND:
        return 4;
      case ScreenType.FRIEND_REQUEST:
        return 3;
      case ScreenType.YOU_COMMENT:
        return 2;
      case ScreenType.LIKE:
        return 1;
      case ScreenType.ME_COMMENT:
        return 5;
    }
  }
}
