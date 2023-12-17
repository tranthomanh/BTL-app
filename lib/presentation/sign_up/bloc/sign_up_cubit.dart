import 'dart:math';
import 'dart:typed_data';

import 'package:ccvc_mobile/config/base/base_cubit.dart';
import 'package:ccvc_mobile/data/helper/firebase/firebase_authentication.dart';
import 'package:ccvc_mobile/data/helper/firebase/firebase_store.dart';
import 'package:ccvc_mobile/domain/locals/hive_local.dart';
import 'package:ccvc_mobile/domain/locals/prefs_service.dart';
import 'package:ccvc_mobile/domain/model/fcm_tokken_model.dart';
import 'package:ccvc_mobile/domain/model/user_model.dart';
import 'package:ccvc_mobile/presentation/sign_up/bloc/sign_up_state.dart';
import 'package:ccvc_mobile/utils/constants/dafault_env.dart';
import 'package:ccvc_mobile/utils/constants/image_asset.dart';
import 'package:ccvc_mobile/utils/extensions/date_time_extension.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';

class SignUpCubit extends BaseCubit<SignUpState> {
  SignUpCubit() : super(SignUpStateIntial());

  bool isHideClearData = false;
  bool isCheckEye1 = true;
  bool isCheckEyeXacNhan = true;
  bool isHideEyeXacNhan = false;
  bool isHideEye1 = false;
  bool passIsError = false;
  String gender = 'Nam';
  DateTime birthDay = DateTime(2001, 1, 1);
  UserModel dataUser = UserModel();
  Uint8List? image;

  BehaviorSubject<DateTime> birthDaySubject =
      BehaviorSubject.seeded(DateTime(2001, 1, 1));

  Future<void> saveUser() async {
    final snap = await FirebaseFirestore.instance
        .collection(DefaultEnv.socialNetwork)
        .doc(DefaultEnv.develop)
        .collection(DefaultEnv.users)
        .doc(PrefsService.getUserId())
        .collection(DefaultEnv.profile)
        .get();
    final UserModel userInfo = UserModel.fromJson(
      snap.docs.first.data(),
    );

    final String? token = await FirebaseMessaging.instance.getToken();
    await PrefsService.saveToken(token ?? '');
    final FcmTokenModel tokenModel = FcmTokenModel(
      userId: userInfo.userId,
      tokenFcm: token,
      createAt: DateTime.now().millisecondsSinceEpoch,
      updateAt: DateTime.now().millisecondsSinceEpoch,
    );

    await FireStoreMethod.saveToken(
      userId: userInfo.userId ?? '',
      fcmTokenModel: tokenModel,
    );

    await FireStoreMethod.saveFlg(
      userId: userInfo.userId ?? '',
    );
    await HiveLocal.saveDataUser(userInfo);
    if (PrefsService.getToken().isEmpty) {
      await PrefsService.saveToken(userInfo.userId ?? '');
    }
  }

  Future<User?> signUp(
    String email,
    String password,
  ) async {
    showLoading();
    final User? user = await FirebaseAuthentication.signUp(
      email: email,
      password: password,
    );

    if (user != null) {
      dataUser = UserModel(
        userId: user.uid,
        email: user.email,
        birthday: 0,
        gender: true,
        nameDisplay: user.displayName,
        createAt: 0,
        updateAt: 0,
      );

      await PrefsService.saveUserId(user.uid);
    }
    showContent();
    return user;
  }

// Returns true if email address is in use.
Future<bool> checkIfEmailInUse(String emailAddress) async {
  try {
    // Fetch sign-in methods for the email address
    final list = await FirebaseAuth.instance.fetchSignInMethodsForEmail(emailAddress);

    // In case list is not empty
    if (list.isNotEmpty) {
      // Return true because there is an existing
      // user using the email address
      return true;
    } else {
      // Return false because email adress is not in use
      return false;
    }
  } catch (error) {
    // Handle error
    // ...
    return true;
  }
}

  Future<void> saveInformationUser(
    String name,
    String email,
  ) async {
    showLoading();
    final String userId = PrefsService.getUserId();

    dataUser.gender = gender.getGender;
    dataUser.birthday = birthDay.convertToTimesTamp;
    dataUser.nameDisplay = name;
    dataUser.createAt = DateTime.now().millisecondsSinceEpoch;
    dataUser.updateAt = DateTime.now().millisecondsSinceEpoch;
    dataUser.onlineFlag = true;
    dataUser.userId = userId;

    /// trường hợp tạo tài khoản nhưng chưa tạo thông tin
    dataUser.email = email;
    if (image == null) {
      dataUser.avatarUrl = ImageAssets.imgEmptyAvata;
    } else {
      await FireStoreMethod.uploadImageToStorage(
        userId,
        image ?? Uint8List(0),
      );

      final String photoImage = await FireStoreMethod.downImage(userId);
      dataUser.avatarUrl = photoImage;
    }

    await FireStoreMethod.saveInformationUser(
      id: userId,
      user: dataUser,
    );
    await PrefsService.saveIsCreateInfo(true);
    showContent();
  }

  Future<Uint8List?> pickImage(ImageSource source) async {
    final ImagePicker _imagePicker = ImagePicker();
    final XFile? _file = await _imagePicker.pickImage(source: source);
    if (_file != null) {
      return _file.readAsBytes();
    }
    return null;
  }
}

extension ConvertGender on String {
  bool get getGender {
    switch (this) {
      case 'Nam':
        return true;
      case 'Nữ':
        return false;

      default:
        return true;
    }
  }
}
