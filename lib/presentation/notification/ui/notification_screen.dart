import 'package:ccvc_mobile/config/resources/color.dart';
import 'package:ccvc_mobile/config/resources/styles.dart';
import 'package:ccvc_mobile/data/exception/app_exception.dart';
import 'package:ccvc_mobile/domain/model/notify/notification_model.dart';
import 'package:ccvc_mobile/generated/l10n.dart';
import 'package:ccvc_mobile/presentation/notification/bloc/notification_cubit.dart';
import 'package:ccvc_mobile/presentation/notification/bloc/screen_stype.dart';
import 'package:ccvc_mobile/presentation/notification/ui/widget/item_notify.dart';
import 'package:ccvc_mobile/utils/constants/image_asset.dart';
import 'package:ccvc_mobile/widgets/appbar/base_app_bar.dart';
import 'package:ccvc_mobile/widgets/dialog/show_dialog.dart';
import 'package:ccvc_mobile/widgets/views/state_stream_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  NotificationCubit cubit = NotificationCubit();

  @override
  void initState() {
    super.initState();
    cubit.initData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        title: S.current.thong_bao,
        actions: [
          GestureDetector(
            onTap: () {
              showDiaLogCustom(
                context,
                title: 'Thông báo',
                textContent:
                    'Bạn có chắc muốn đọc toàn bộ thông báo không không ?',
                btnRightTxt: 'Xác nhận',
                btnLeftTxt: 'Đóng',
                funcBtnRight: () {
                  cubit.readAllNoti();
                },
              );
            },
            child: SvgPicture.asset(ImageAssets.icReadAll),
          ),
          spaceW15,
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          cubit.initData();
        },
        child: StateStreamLayout(
          textEmpty: S.current.khong_co_du_lieu,
          retry: () {},
          error: AppException('', S.current.something_went_wrong),
          stream: cubit.stateStream,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: StreamBuilder<List<NotificationModel>>(
              stream: cubit.listNotificationSubject.stream,
              builder: (context, snapshot) {
                final data = snapshot.data ?? [];
                return data.isEmpty
                    ? emptyNoti()
                    : Column(
                        children: data
                            .map(
                              (noti) => ItemNotificationWidget(
                                model: noti,
                                ontapNoti: () {
                                  cubit.onTapNoti(noti);
                                  noti.typeNoti.navigatorScreen(
                                    context: context,
                                    detailId: noti.detailId,
                                  );
                                },
                                deleteNoti: () {
                                  cubit.deleteNoti(noti);
                                },
                              ),
                            )
                            .toList(),
                      );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget emptyNoti() {
    return const SizedBox(
      height: 300,
      child: Center(
        child: Text('Không có dữ liệu'),
      ),
    );
  }
}
