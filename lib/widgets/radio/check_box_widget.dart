import 'package:ccvc_mobile/config/resources/color.dart';
import 'package:flutter/material.dart';

class CheckBoxWidget extends StatelessWidget {
  final bool value;
  final Function(bool) onChange;

  const CheckBoxWidget({Key? key, required this.value, required this.onChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1.1,
      child: Container(
        width: 19,
        height: 19,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Theme(
          data: ThemeData(
            unselectedWidgetColor: borderColor,
          ),
          child: Checkbox(
            side: const BorderSide(width: 1.5, color: borderColor),
            value: value,
            onChanged: (value) {
              onChange(value ?? false);
            },
            shape: const CircleBorder(),
          ),
        ),
      ),
    );
  }
}
