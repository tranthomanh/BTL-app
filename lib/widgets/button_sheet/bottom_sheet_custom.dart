import 'package:ccvc_mobile/config/resources/color.dart';
import 'package:ccvc_mobile/config/resources/styles.dart';
import 'package:flutter/material.dart';

Future<T?> showBottomSheetCustom<T>(BuildContext context,
    {required Widget child, required String title, bool? textOption}) {
  return showModalBottomSheet(
    backgroundColor: Colors.white,
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
      ),
    ),
    clipBehavior: Clip.hardEdge,
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 20,
          ),
          lineContainer(),
          const SizedBox(
            height: 22,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Visibility(
                //   visible: textOption ?? true,
                //   child: Text(
                //     title,
                //     style: textNormalCustom(fontSize: 18, color: textTitle),
                //   ),
                // ),
                child
              ],
            ),
          )
        ],
      );
    },
  );
}

Future<T?> showBottomSheetCustomPostScreen<T>(BuildContext context,
    {required Widget child, bool? textOption}) {
  return showModalBottomSheet(
    backgroundColor: Colors.white,
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
      ),
    ),
    clipBehavior: Clip.hardEdge,
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 20,
          ),
          lineContainer(),
          const SizedBox(
            height: 22,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [child],
            ),
          )
        ],
      );
    },
  );
}

Widget lineContainer() {
  return Container(
    height: 6,
    width: 48,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: colorECEEF7,
    ),
  );
}
