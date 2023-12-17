import 'dart:convert';
import 'dart:developer';
import 'package:ccvc_mobile/domain/model/notify/notification_model.dart';
import 'package:ccvc_mobile/presentation/message/message_screen.dart';
import 'package:ccvc_mobile/presentation/notification/bloc/screen_stype.dart';
import 'package:ccvc_mobile/presentation/tabbar_screen/bloc/main_cubit.dart';
import 'package:ccvc_mobile/presentation/tabbar_screen/ui/tabbar_item.dart';
import 'package:ccvc_mobile/presentation/tabbar_screen/ui/widgets/custom_navigator_tabbar.dart';
import 'package:ccvc_mobile/utils/push_notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainTabBarView extends StatefulWidget {
  const MainTabBarView({Key? key}) : super(key: key);

  @override
  _MainTabBarViewState createState() => _MainTabBarViewState();
}

class _MainTabBarViewState extends State<MainTabBarView> {
  final List<TabScreen> _listScreen = [];
  final MainCubit _cubit = MainCubit();

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    _addScreen(TabBarType.home);
    FirebaseMessaging.instance.getInitialMessage().then((value) {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        if (value != null) {}
      });
    });
    FirebaseMessaging.onMessageOpenedApp.listen((value) {
      log('${value.data}');
      final data = json.decode(value.data['data'] ?? '');
      final dataChat = DataChat.fromJson(data);

      if (data['type_noti'] == null) {
        WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
          pushDetailsOnTapNotification(dataChat);
        });
      } else {
        final NotificationModel noti = NotificationModel.fromJson(data);

        noti.typeNoti
            .navigatorScreen(context: context, detailId: noti.detailId);
      }
    });
  }

  void pushDetailsOnTapNotification(DataChat model) {

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MessageScreen(
                isRoomGroup: model.isRoomGroup,
                peopleChat: model.peopleChat,
                peopleGroupChat: model.peopleGroupChat,
                chatModel: model.chatModel)));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _cubit.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TabBarType>(
      stream: _cubit.selectTabBar,
      builder: (context, snapshot) {
        final type = snapshot.data ?? TabBarType.home;
        return Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          body: IndexedStack(
            index: _getIndexListScreen(type),
            children: _listScreen.map((e) => e.widget).toList(),
          ),
          bottomNavigationBar: BottomTabBarWidget(
            streamNoti: _cubit.isNotiStream(),
            selectItemIndex: type.index,
            onChange: (value) {
              _addScreen(value);
              _cubit.selectTab(value);
            },
          ),
        );
      },
    );
  }

  int _getIndexListScreen(TabBarType type) {
    return _listScreen
        .indexWhere((element) => element.type.index == type.index);
  }

  void _addScreen(TabBarType type) {
    if (_listScreen.indexWhere((element) => element.type.index == type.index) ==
        -1) {
      _listScreen.add(
        TabScreen(widget: type.getScreen(), type: type),
      );
    }
  }
}
