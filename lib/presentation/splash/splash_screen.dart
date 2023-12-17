import 'package:ccvc_mobile/domain/locals/prefs_service.dart';
import 'package:ccvc_mobile/main.dart';
import 'package:ccvc_mobile/presentation/login/ui/login_screen.dart';

import 'package:ccvc_mobile/presentation/tabbar_screen/ui/main_screen.dart';

import 'package:ccvc_mobile/utils/extensions/size_extension.dart';
import 'package:ccvc_mobile/widgets/dialog/message_dialog/message_config.dart';
import 'package:ccvc_mobile/widgets/views/show_loading_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      SizeConfig.init(context);
      MessageConfig.init(context);
    });
  }



  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      initialData: AppStateCt.of(context).appState.userId,
      stream: AppStateCt.of(context).appState.getToken,
      builder: (context, snapshot) {
        final data = snapshot.data ?? '';
        return screen(data, AppStateCt.of(context).appState.isUserModel);
      },
    );
  }

  Widget screen(String token, bool isUserModel) {
    if (token.isNotEmpty && isUserModel) {
      return const MainTabBarView();
    } else {
      if (PrefsService.getToken().isNotEmpty) {
        PrefsService.removeTokken();
      }
      return const LoginScreen();
    }
  }
}
