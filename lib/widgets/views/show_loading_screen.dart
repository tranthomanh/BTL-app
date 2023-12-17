
import 'package:ccvc_mobile/widgets/dialog/cupertino_loading.dart';
import 'package:ccvc_mobile/widgets/dialog/message_dialog/message_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShowLoadingScreen {
  static  OverlayEntry? _overlayEntry;

  static void show() {
    if(_overlayEntry != null){
      return;
    }
    final OverlayState? overlayState = Overlay.of(MessageConfig.contextConfig!);
    _overlayEntry = _showLoading();
    overlayState?.insert(_overlayEntry!);
  }

  static void dismiss() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  static OverlayEntry _showLoading() {
    return OverlayEntry(
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.grey.withOpacity(0.3),
          body: const Center(child: CupertinoLoading()),
        );
      },
    );
  }
}
