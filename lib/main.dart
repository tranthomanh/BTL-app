import 'dart:convert';
import 'dart:developer';

import 'package:ccvc_mobile/config/crypto_config.dart';
import 'package:ccvc_mobile/config/firebase_config.dart';
import 'package:ccvc_mobile/config/resources/color.dart';
import 'package:ccvc_mobile/config/resources/strings.dart';
import 'package:ccvc_mobile/config/resources/styles.dart';
import 'package:ccvc_mobile/config/routes/router.dart';
import 'package:ccvc_mobile/config/themes/app_theme.dart';
import 'package:ccvc_mobile/data/di/module.dart';
import 'package:ccvc_mobile/data/helper/firebase/firebase_store.dart';
import 'package:ccvc_mobile/domain/locals/hive_local.dart';
import 'package:ccvc_mobile/domain/locals/prefs_service.dart';
import 'package:ccvc_mobile/domain/model/fcm_tokken_model.dart';
import 'package:ccvc_mobile/domain/model/notify/notification_model.dart';
import 'package:ccvc_mobile/domain/model/user_model.dart';
import 'package:ccvc_mobile/generated/l10n.dart';
import 'package:ccvc_mobile/presentation/notification/bloc/screen_stype.dart';
import 'package:ccvc_mobile/presentation/splash/bloc/app_state.dart';
import 'package:ccvc_mobile/utils/constants/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:hive/hive.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:permission_handler/permission_handler.dart';

Future<void> mainApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final appDocumentDirectory =
      await path_provider.getApplicationDocumentsDirectory();
  await Firebase.initializeApp();
  Hive.init(appDocumentDirectory.path);
  requestPermission();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print(
          'Message also contained a notification: ${message.notification?.title ?? 'null data'}');
    }
  });
  await HiveLocal.init();
  await PrefsService.init();
  await FirebaseSetup.setUp();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  configureDependencies();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final AppState appStateCubit = AppState();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    appStateCubit.getDataRefeshToken();
    appStateCubit.getTokenPrefs();
    onStateWhenOpenApp();
    if (appStateCubit.isUserModel) {
      FirebaseMessaging.instance.onTokenRefresh.listen((event) async {
        await FireStoreMethod.updateToken(
          tokenOld: PrefsService.getToken(),
          userId: PrefsService.getUserId(),
          fcmTokenModel: FcmTokenModel(
            userId: PrefsService.getUserId(),
            tokenFcm: event,
            createAt: appStateCubit.tokenFcm.createAt,
            updateAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );

        await PrefsService.saveToken(event);
      });
    }
    checkDeviceType();

  }

  Future<void> offStateWhenCloseApp() async {
    final UserModel userInfo =
        await FireStoreMethod.getDataUserInfo(PrefsService.getUserId());
    userInfo.onlineFlag = false;
    await FireStoreMethod.updateUser(userInfo.userId ?? '', userInfo);
  }

  Future<void> onStateWhenOpenApp() async {
    appStateCubit.isUserModel =
        await FireStoreMethod.isDataUser(PrefsService.getUserId());
    if (PrefsService.getUserId().isNotEmpty && appStateCubit.isUserModel) {
      final UserModel userInfo =
          await FireStoreMethod.getDataUserInfo(PrefsService.getUserId());
      userInfo.onlineFlag = true;
      await FireStoreMethod.updateUser(userInfo.userId ?? '', userInfo);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
        {
          offStateWhenCloseApp();
          break;
        }

      case AppLifecycleState.paused:
        {
          offStateWhenCloseApp();

          break;
        }

      case AppLifecycleState.resumed:
        {
          onStateWhenOpenApp();
          break;
        }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateCt(
      appState: appStateCubit,
      child: KeyboardDismisser(
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: () => GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: Strings.app_name,
            theme: ThemeData(
              primaryColor: AppTheme.getInstance().primaryColor(),
              cardColor: Colors.white,
              appBarTheme: const AppBarTheme(
                color: Colors.white,
                systemOverlayStyle: SystemUiOverlayStyle.dark,
              ),
              dividerColor: dividerColor,
              scaffoldBackgroundColor: Colors.white,
              textSelectionTheme: TextSelectionThemeData(
                cursorColor: AppTheme.getInstance().primaryColor(),
                selectionColor: AppTheme.getInstance().primaryColor(),
                selectionHandleColor: AppTheme.getInstance().primaryColor(),
              ),
              colorScheme: ColorScheme.fromSwatch().copyWith(
                secondary: AppTheme.getInstance().accentColor(),
              ),
            ),
            localeResolutionCallback: (deviceLocale, supportedLocales) {
              // if (supportedLocales.contains(
              //   Locale(deviceLocale?.languageCode ?? EN_CODE),
              // )) {
              //   return deviceLocale;
              // } else {
              //   return const Locale.fromSubtags(languageCode: EN_CODE);
              // }
              return const Locale.fromSubtags(languageCode: VI_CODE);
            },
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: AppRouter.splash,
          ),
        ),
      ),
    );
  }

  void checkDeviceType() {
    // final shortestSide =
    //     MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
    //         .size
    //         .shortestSide;
    // APP_DEVICE = shortestSide < 700 ? DeviceType.MOBILE : DeviceType.TABLET;
  }
}

class AppStateCt extends InheritedWidget {
  final AppState appState;

  const AppStateCt({
    Key? key,
    required this.appState,
    required Widget child,
  }) : super(key: key, child: child);

  static AppStateCt of(BuildContext context) {
    final AppStateCt? result =
        context.dependOnInheritedWidgetOfExactType<AppStateCt>();
    assert(result != null, 'No element');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }
}

void requestPermission() async {
  await Permission.storage.request();
  final NotificationSettings settings =
      await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print('Handling a background message ${message.messageId}');
}
