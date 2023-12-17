import 'package:ccvc_mobile/config/base/base_cubit.dart';
import 'package:ccvc_mobile/data/helper/firebase/firebase_authentication.dart';
import 'package:ccvc_mobile/domain/locals/prefs_service.dart';
import 'package:ccvc_mobile/presentation/change_password/bloc/change_password_state.dart';
import 'package:rxdart/rxdart.dart';

class ChangePasswordCubit extends BaseCubit<ChangePasswordSate> {
  ChangePasswordCubit() : super(ChangePasswordSateIntial());

  bool isHideClearData = false;
  bool isCheckEye1 = true;
  bool isCheckEyeXacNhan = true;
  bool isHideEyeXacNhan = false;
  bool isHideEye1 = false;
  bool passIsError = false;
  bool isHideEye2 = false;
  bool isCheckEye2 = true;

  BehaviorSubject<bool> isUpdate = BehaviorSubject.seeded(false);

  void isUpdatePassword(
    String passwordCurrent,
    String passwordNew,
    String passwordConfirm,
  ) {
    if (passwordCurrent.isNotEmpty &&
        passwordNew.isNotEmpty &&
        passwordConfirm.isNotEmpty ) {
      isUpdate.add(true);
    } else {
      isUpdate.add(false);
    }
  }

  Future<void> changePassword({
    required String newPassword,
    required Function subsess,
    required Function(String error) error,
  }) async {
    showLoading();
    await FirebaseAuthentication.changePassword(
      newPassword: newPassword,
      subsess: () async {
        subsess();
        await PrefsService.updatePasswordPresent(newPassword);
      },
      error: (String e) {
        error(e);
      },
    );
    showContent();
  }

  bool isMatchPassword(String oldPassword) {
    showLoading();
    final String passwordPresent = PrefsService.getPasswordPresent();

    if (oldPassword == passwordPresent) {
      showContent();

      return true;
    } else {
      showContent();

      return false;
    }
  }
}
