import 'package:ccvc_mobile/config/resources/color.dart';
import 'package:ccvc_mobile/config/resources/styles.dart';
import 'package:ccvc_mobile/domain/model/notify/notification_model.dart';
import 'package:ccvc_mobile/presentation/notification/bloc/screen_stype.dart';
import 'package:ccvc_mobile/utils/constants/image_asset.dart';
import 'package:ccvc_mobile/utils/extensions/date_time_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ItemNotificationWidget extends StatelessWidget {
  final NotificationModel model;
  final Function() deleteNoti;
  final Function() ontapNoti;

  const ItemNotificationWidget({
    Key? key,
    required this.model,
    required this.deleteNoti,
    required this.ontapNoti,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ontapNoti();
      },
      child: Dismissible(
        key: ObjectKey(model),
        background: rightDelete(),
        secondaryBackground: rightDelete(),
        onDismissed: (DismissDirection direction) {
          deleteNoti();
        },
        child: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: model.isRead ? Colors.white : const Color(0xFFF8F9FC),
          child: Row(
            children: [
              SvgPicture.asset(
                ImageAssets.icNotify,
              ),
              spaceW15,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: model.nameReact,
                        style: textNormalCustom(
                          color: textTitle,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(
                            text: model.typeNoti.getTitle(
                              countLike: model.countLike,
                              isPostToMe: model.isPostOfMe,
                            ),
                            style: textNormalCustom(
                              fontSize: 13,
                              color: subTitle,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        ],
                      ),
                    ),
                    spaceH14,
                    Text(
                      model.createAt.formatHHmmDdMMYYYY,
                      style: textNormalCustom(
                        fontSize: 12,
                        color: subTitle,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget rightDelete() {
    return Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      child: const Icon(Icons.delete),
    );
  }
}
