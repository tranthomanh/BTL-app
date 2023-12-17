import 'package:ccvc_mobile/data/helper/firebase/firebase_store.dart';
import 'package:ccvc_mobile/domain/locals/prefs_service.dart';
import 'package:ccvc_mobile/domain/model/fcm_tokken_model.dart';

import 'package:rxdart/rxdart.dart';

class AppState {
  String userId = '';

  bool isUserModel = false;

  FcmTokenModel tokenFcm = FcmTokenModel.empty();

  final BehaviorSubject<String> getToken = BehaviorSubject<String>();

  void getTokenPrefs() {
    userId = PrefsService.getUserId();
    getToken.sink.add(userId);
  }

  Future<void> getDataRefeshToken() async {
    userId = PrefsService.getUserId();

    isUserModel = PrefsService.getIsCreateInfo();
    if (isUserModel && userId.isNotEmpty) {
      tokenFcm = await FireStoreMethod.getTokenFcm(id: userId, );
    }
  }
}
