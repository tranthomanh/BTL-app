import 'package:ccvc_mobile/config/resources/styles.dart';
import 'package:ccvc_mobile/generated/l10n.dart';
import 'package:ccvc_mobile/presentation/sign_up/ui/widget/container_data_widget.dart';
import 'package:ccvc_mobile/presentation/sign_up/ui/widget/drop_down_gender.dart';
import 'package:ccvc_mobile/presentation/update_user/bloc/update_user_cubit.dart';
import 'package:ccvc_mobile/presentation/update_user/ui/widget/avata_update.dart';
import 'package:ccvc_mobile/presentation/update_user/ui/widget/birth_day_update_widget.dart';
import 'package:ccvc_mobile/utils/extensions/string_extension.dart';
import 'package:ccvc_mobile/utils/push_notification.dart';
import 'package:ccvc_mobile/widgets/appbar/base_app_bar.dart';
import 'package:ccvc_mobile/widgets/button/button_custom_bottom.dart';
import 'package:ccvc_mobile/widgets/dialog/show_dialog.dart';
import 'package:ccvc_mobile/widgets/textformfield/form_group.dart';
import 'package:ccvc_mobile/widgets/textformfield/text_field_validator.dart';
import 'package:ccvc_mobile/widgets/views/state_stream_layout.dart';
import 'package:flutter/material.dart';

import '../../../data/exception/app_exception.dart';

class UpdateUserScreen extends StatefulWidget {
  const UpdateUserScreen({Key? key}) : super(key: key);

  @override
  State<UpdateUserScreen> createState() => _UpdateUserScreenState();
}

class _UpdateUserScreenState extends State<UpdateUserScreen> {
  UpdateUserCubit cubit = UpdateUserCubit();
  final keyGroup = GlobalKey<FormGroupState>();
  TextEditingController textNameController = TextEditingController();
  GlobalKey keyDateTime = GlobalKey();

  @override
  void initState() {
    super.initState();
    cubit.initData();
    textNameController.text = cubit.userInfo.nameDisplay ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        title: S.current.cap_nhat_tai_khoan,
        leadingIcon: IconButton(
          onPressed: () {
            if (cubit.isUpdateSubject.value) {
              showDiaLogCustom(
                context,
                title: 'Cập nhật',
                textContent: 'Bạn có chắc muốn thoát không ?',
                btnRightTxt: 'Xác nhận',
                btnLeftTxt: 'Đóng',
                funcBtnRight: () {
                  Navigator.pop(context, '');
                },
              );
            } else {
              Navigator.pop(context, '');
            }
          },
          icon: const Icon(
            Icons.arrow_back_ios_sharp,
            color: Colors.grey,
          ),
        ),
      ),
      body: StateStreamLayout(
        textEmpty: S.current.khong_co_du_lieu,
        retry: () {},
        error: AppException('', S.current.something_went_wrong),
        stream: cubit.stateStream,
        child: SafeArea(
          child: SingleChildScrollView(
            child: FormGroup(
              key: keyGroup,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    spaceH30,
                    AvataUpdateWidget(
                      cubit: cubit,
                    ),
                    spaceH16,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ContainerDataWidget(
                          title: S.current.ho_ten,
                          child: TextFieldValidator(
                            controller: textNameController,
                            hintText: S.current.nguyen_van_a,
                            onChange: (text) {
                              if (text.isEmpty) {
                                setState(() {});
                                return cubit.isHideClearData = false;
                              }
                              cubit.nameDisplay = text;
                              cubit.isUpdate();
                              setState(() {});
                              return cubit.isHideClearData = true;
                            },
                            validator: (value) {
                              return (value ?? '').checkNull();
                            },
                          ),
                        ),
                        ContainerDataWidget(
                          title: S.current.gioi_tinh,
                          child: DropDownGender(
                            initData: cubit.gender,
                            items: const ['Nam', 'Nữ'],
                            onChange: (String value) {
                              cubit.gender = value;
                              cubit.isUpdate();
                            },
                          ),
                        ),
                        ContainerDataWidget(
                          title: S.current.ngay_sinh,
                          child: BirthDayUpdateWidget(
                            key: keyDateTime,
                            onChange: (value) {
                              cubit.birthDay = value;
                              cubit.isUpdate();
                            },
                            cubit: cubit,
                          ),
                        ),
                      ],
                    ),
                    spaceH30,
                    StreamBuilder<bool>(
                        stream: cubit.isUpdateSubject.stream,
                        builder: (context, snapshot) {
                          final data = snapshot.data ?? false;
                          return ButtonCustomBottom(
                            title: S.current.cap_nhat,
                            isColorBlue: data,
                            onPressed: () async {
                              if (keyGroup.currentState!.validator()) {
                                if (cubit.isUpdateSubject.value) {
                                  await cubit.updateInfomationUser();
                                  _showToast(
                                    context: context,
                                    text:
                                        S.current.cap_nhat_tai_khoan_thanh_cong,
                                  );

                                  Navigator.pop(context);
                                }
                              } else {
                                _showToast(
                                  context: context,
                                );
                              }
                            },
                          );
                        }),
                    spaceH30,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showToast({required BuildContext context, String? text}) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(text ?? S.current.dang_nhap_that_bai),
      ),
    );
  }
}
