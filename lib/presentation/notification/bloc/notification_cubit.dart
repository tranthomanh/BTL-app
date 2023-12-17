import 'package:ccvc_mobile/config/base/base_cubit.dart';
import 'package:ccvc_mobile/data/helper/firebase/firebase_store.dart';
import 'package:ccvc_mobile/domain/locals/prefs_service.dart';
import 'package:ccvc_mobile/domain/model/notify/notification_model.dart';
import 'package:rxdart/rxdart.dart';

import 'notification_state.dart';

class NotificationCubit extends BaseCubit<NotificationState> {
  NotificationCubit() : super(NotificationStateInitial());

  BehaviorSubject<List<NotificationModel>> listNotificationSubject =
      BehaviorSubject.seeded([]);

  Future<void> initData() async {
    showLoading();
   await FireStoreMethod.getDataNoti((noti) {
      listNotificationSubject.add(noti);
    });
   showContent();
  }

  void deleteNoti(NotificationModel noti) {
    FireStoreMethod.deleteNoti(model: noti, userId: PrefsService.getUserId());
  }

  void onTapNoti(NotificationModel noti) {
    FireStoreMethod.readNoti(model: noti, userId: PrefsService.getUserId());
  }

  void readAllNoti() {
    FireStoreMethod.readAllNoti(userId: PrefsService.getUserId());
  }

}
