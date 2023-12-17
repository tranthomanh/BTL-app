import 'package:ccvc_mobile/presentation/update_user/bloc/update_user_cubit.dart';
import 'package:ccvc_mobile/utils/extensions/date_time_extension.dart';
import 'package:ccvc_mobile/utils/extensions/int_extension.dart';
import 'package:ccvc_mobile/widgets/select_only_expands/expand_animation_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../config/resources/color.dart';
import '../../../../config/resources/styles.dart';

class BirthDayUpdateWidget extends StatefulWidget {
  final UpdateUserCubit cubit;
  final Function(DateTime value) onChange;

  const BirthDayUpdateWidget({
    Key? key,
    required this.cubit,
    required this.onChange,
  }) : super(key: key);

  @override
  State<BirthDayUpdateWidget> createState() => _BirthDayUpdateWidgetState();
}

class _BirthDayUpdateWidgetState extends State<BirthDayUpdateWidget>
    with SingleTickerProviderStateMixin {
  bool isShowDateTime = false;
  final GlobalKey _key = GlobalKey();

  void showOverlay(BuildContext context) {
    final RenderBox? renderBox =
        _key.currentContext?.findRenderObject() as RenderBox?;
    final Offset position = renderBox!.localToGlobal(Offset.zero);

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return OverLayBirthdayWidget(
          offset: position,
          onDismis: () {
            overlayEntry.remove();
            isShowDateTime = false;
            setState(() {});
          },
          cubit: widget.cubit,
          onChange: widget.onChange,
        );
      },
    );
    Overlay.of(context)?.insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreamBuilder<DateTime>(
          initialData: (widget.cubit.userInfo.birthday ?? 0).convertToDateTime,
          stream: widget.cubit.birthDaySubject.stream,
          builder: (context, snapshot) {
            final data = snapshot.data ??
                (widget.cubit.userInfo.birthday ?? 0).convertToDateTime;
            return GestureDetector(
              onTap: () {
                showOverlay(context);
                if (!isShowDateTime) {
                  isShowDateTime = true;
                  setState(() {});
                }
              },
              child: Container(
                key: _key,
                width: double.maxFinite,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: bgDropDown,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  data.formatDdMMYYYY,
                  style: textNormal(selectColorTabbar, 14),
                ),
              ),
            );
          },
        ),
        ExpandedSection(
          expand: isShowDateTime,
          child: const SizedBox(
            height: 200,
          ),
        )
      ],
    );
  }
}

class OverLayBirthdayWidget extends StatefulWidget {
  final Offset offset;
  final Function() onDismis;
  final UpdateUserCubit cubit;
  final Function(DateTime value) onChange;

  const OverLayBirthdayWidget({
    Key? key,
    required this.offset,
    required this.onDismis,
    required this.cubit,
    required this.onChange,
  }) : super(key: key);

  @override
  State<OverLayBirthdayWidget> createState() => _OverLayBirthdayWidgetState();
}

class _OverLayBirthdayWidgetState extends State<OverLayBirthdayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              _animationController.reverse().whenComplete(() {
                widget.onDismis();
              });
            },
            child: SizedBox.expand(
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Positioned(
            top: widget.offset.dy + 50,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, _) {
                return Opacity(
                  opacity: _animationController.value,
                  child: Transform(
                    transform: Matrix4.identity()
                      ..scale(
                        _animationController.value,
                        _animationController.value,
                      ),
                    child: SizedBox(
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      child: CupertinoDatePicker(
                        minimumYear: 1950,
                        initialDateTime: (widget.cubit.userInfo.birthday ?? 0)
                            .convertToDateTime,
                        maximumDate: DateTime.now(),
                        mode: CupertinoDatePickerMode.date,
                        onDateTimeChanged: (DateTime value) {
                          widget.cubit.birthDaySubject.add(value);
                          widget.cubit.isUpdate();
                          widget.onChange(value);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
