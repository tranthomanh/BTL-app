import 'package:ccvc_mobile/config/resources/color.dart';
import 'package:ccvc_mobile/config/resources/styles.dart';
import 'package:ccvc_mobile/utils/constants/image_asset.dart';
import 'package:ccvc_mobile/utils/extensions/size_extension.dart';
import 'package:ccvc_mobile/widgets/button/button_custom_bottom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Future<T?> showDiaLogCustom<T>(
  BuildContext context, {
  required String title,
  required String textContent,
  Widget? icon,
  required String btnRightTxt,
  required String btnLeftTxt,
  bool showTablet = false,
  bool isBottomShow = true,
  bool isOneButton = true,
  required Function funcBtnRight,
  Function? funcBtnLeft,
}) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (_) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: showTablet
              ? MediaQuery.of(context).size.width / 2
              : double.maxFinite,
          // padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          padding: EdgeInsets.fromLTRB(
            24,
            showTablet ? 24 : 40,
            24,
            showTablet ? 32 : 40,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon ?? Container(),
              SizedBox(
                height: showTablet ? 20.0.textScale(space: -8) : 20,
              ),
              Text(
                title,
                style: titleAppbar(),
              ),
              if (isOneButton)
                Column(
                  children: [
                    SizedBox(
                      height: showTablet ? 14.0.textScale() : 14,
                    ),
                    Text(
                      textContent,
                      style: textNormal(
                        dateColor,
                        showTablet ? 14.0.textScale() : 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              else
                const SizedBox(),
              SizedBox(
                height: showTablet ? 24.0.textScale(space: 8) : 24,
              ),
              if (isOneButton)
                Row(
                  children: [
                    Expanded(
                      child: ButtonCustomBottom(
                        isColorBlue: false,
                        title: btnLeftTxt,
                        onPressed: () {
                          Navigator.pop(context);
                          if (funcBtnLeft != null) funcBtnLeft();
                        },
                      ),
                    ),
                    SizedBox(
                      width: showTablet ? 16.0.textScale(space: 20) : 16,
                    ),
                    Expanded(
                      child: ButtonCustomBottom(
                        isColorBlue: true,
                        title: btnRightTxt,
                        onPressed: () {
                          funcBtnRight();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 86,
                      child: ButtonCustomBottom(
                        isColorBlue: true,
                        title: btnRightTxt,
                        onPressed: () {
                          funcBtnRight();
                          Navigator.pop(context, true);
                        },
                      ),
                    ),
                  ],
                )
            ],
          ),
        ),
      );
    },
  );
}
