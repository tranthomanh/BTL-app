import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:ccvc_mobile/config/resources/color.dart';
import 'package:ccvc_mobile/config/resources/strings.dart';
import 'package:ccvc_mobile/config/resources/styles.dart';
import 'package:ccvc_mobile/config/themes/theme_color.dart';
import 'package:ccvc_mobile/data/exception/app_exception.dart';
import 'package:ccvc_mobile/data/helper/firebase/firebase_authentication.dart';
import 'package:ccvc_mobile/domain/locals/prefs_service.dart';
import 'package:ccvc_mobile/domain/model/user_model.dart';
import 'package:ccvc_mobile/generated/l10n.dart';
import 'package:ccvc_mobile/presentation/block_list/block_list_screen.dart';
import 'package:ccvc_mobile/presentation/change_password/ui/change_password_screen.dart';
import 'package:ccvc_mobile/presentation/login/ui/login_screen.dart';
import 'package:ccvc_mobile/presentation/personal/bloc/personal_cubit.dart';
import 'package:ccvc_mobile/presentation/profile/ui/profile_screen.dart';
import 'package:ccvc_mobile/presentation/update_user/ui/update_user_screen.dart';
import 'package:ccvc_mobile/utils/constants/image_asset.dart';
import 'package:ccvc_mobile/widgets/app_image.dart';
import 'package:ccvc_mobile/widgets/views/state_stream_layout.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PersonalScreen extends StatefulWidget {
  const PersonalScreen({Key? key}) : super(key: key);

  @override
  State<PersonalScreen> createState() => _PersonalScreenState();
}

class _PersonalScreenState extends State<PersonalScreen> {
  PersonalCubit _personalCubit = PersonalCubit();

  @override
  Widget build(BuildContext context) {
    return StateStreamLayout(
      stream: _personalCubit.stateStream,
      textEmpty: S.current.khong_co_du_lieu,
      retry: () {},
      error: AppException('', S.current.something_went_wrong),
      child: StreamBuilder<UserModel>(
          stream: _personalCubit.user,
          builder: (context, snapshot) => SafeArea(
                  child: Scaffold(
                appBar: AppBar(
                  // backgroundColor: Color(0xFF339999),
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  title: Text(Strings.app_name,
                      style: heading2(color: ThemeColor.black)),
                ),
                body: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Padding(
                        // padding: EdgeInsets.symmetric(horizontal: 24.sp),
                        //    child: Row(
                        //      mainAxisSize: MainAxisSize.max,
                        //      children: [
                        //        Text(Strings.app_name,
                        //            style: titleAppbar(color: ThemeColor.black)),
                        //      ],
                        //    ),
                        //  ),
                        //    SizedBox(
                        //      height: 27.sp,
                        //    ),
                        _buildListTile(
                          title: snapshot.data?.nameDisplay ?? '',
                          subtitle: 'Xem trang cá nhân',
                          avatarUrl: snapshot.data?.avatarUrl,
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => ProfileScreen(
                                        userId: snapshot.data!.userId!)));
                          },
                        ),
                        _buildListTile(
                          title: 'Cập nhật profile',
                          icon: Icons.account_circle,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UpdateUserScreen(),
                              ),
                            ).then((value) {
                              final String userId = PrefsService.getUserId();
                              _personalCubit.getUserInfo(userId);
                            });
                          },
                        ),
                        _buildListTile(
                          title: 'Danh sách chặn',
                          icon: Icons.block,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlockListScreen(
                                    userId: _personalCubit.userId),
                              ),
                            );
                          },
                        ),
                        _buildListTile(
                          title: 'Đổi mật khẩu',
                          icon: Icons.lock,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ChangePasswordScreen(),
                              ),
                            );
                          },
                        ),
                        _buildListTile(
                          title: 'Đăng xuất',
                          icon: Icons.logout,
                          onTap: () async {
                            final result = await showOkCancelAlertDialog(
                              context: context,
                              title: 'Đăng xuất',
                              message: 'Bạn có chắc chắn muốn đăng xuất?',
                              okLabel: 'Ok',
                              cancelLabel: 'Hủy',
                              fullyCapitalizedForMaterial: false,
                            );

                            if (result.name == 'ok') {
                              final result =
                                  await FirebaseAuthentication.logOut(
                                      snapshot.data!.userId!);
                              if (result) {
                                await _personalCubit.logOut();
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => LoginScreen()));
                              }
                            } else {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ]),
                ),
              ))),
    );
  }

  Widget _buildListTile(
      {Function()? onTap,
      required String title,
      String? subtitle,
      String? avatarUrl,
      IconData? icon}) {
    return GestureDetector(
      onTap: onTap ?? null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            if (icon == null)
              ClipRRect(
                child: Container(
                    width: 60.sp,
                    height: 60.sp,
                    child: (avatarUrl.isNullOrEmpty
                        ? Container(
                            color: ThemeColor.ebonyClay,
                          )
                        : CircleAvatar(
                            // radius: 30, // Image radius
                            backgroundImage: NetworkImage(
                                avatarUrl ?? ImageAssets.imgEmptyAvata),
                          ))),
                borderRadius: BorderRadius.circular(120),
              )
            else
              Icon(
                icon,
                color: mainTxtColor,
              ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 16.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title,
                        style:
                            username(color: ThemeColor.black.withOpacity(0.7))),
                    subtitle != null
                        ? Text(subtitle,
                            style: caption(
                                color: ThemeColor.black.withOpacity(0.7)))
                        : SizedBox()
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
