import 'dart:async';

import 'package:ccvc_mobile/config/resources/styles.dart';
import 'package:ccvc_mobile/generated/l10n.dart';
import 'package:ccvc_mobile/utils/send_otp.dart';
import 'package:ccvc_mobile/widgets/appbar/app_bar_default_back.dart';
import 'package:ccvc_mobile/widgets/button/button_custom_bottom.dart';
import 'package:flutter/material.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';

Future<bool> pushToConfimOtp(
  BuildContext context,
  String email,
) async {
  final data = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ConfirmOtpScreen(
                email: email.trim(),
              )));
  return data == true;
}

class ConfirmOtpScreen extends StatefulWidget {
  final String email;
  const ConfirmOtpScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<ConfirmOtpScreen> createState() => _ConfirmOtpScreenState();
}

class _ConfirmOtpScreenState extends State<ConfirmOtpScreen> {
  String otp = '';
  String verifyOtp = '';
  int expried = 60;
  Timer? timer;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    otp = sendOtp(widget.email);
    runTimer();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    timer?.cancel();
  }

  void runTimer() {
    expried = 60;

    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (expried == 0) {
        timer?.cancel();
        return;
      }
      expried--;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarDefaultBack('OTP'),
      bottomNavigationBar: Visibility(
        visible: expried != 0 && verifyOtp.length == 6,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: ButtonCustomBottom(
            isColorBlue: true,
            onPressed: () {
              if (otp == verifyOtp) {
                Navigator.pop(context, true);
              } else {
                _showToast(context: context, text: 'Mã xác thực không đúng');
              }
            },
            title: 'Xác thực',
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 16,
            ),
            Text(
              'Mã đã được gửi tới;',
              style: textNormalCustom(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w400),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              widget.email,
              style: textNormalCustom(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w400),
            ),
            const SizedBox(
              height: 16,
            ),
            OTPTextField(
              length: 6,
              width: 200,
              style: TextStyle(fontSize: 17),
              textFieldAlignment: MainAxisAlignment.spaceAround,
              fieldStyle: FieldStyle.underline,
              onChanged: (pin) {
                verifyOtp = pin;
                setState(() {});
              },
            ),
            const SizedBox(
              height: 16,
            ),
            GestureDetector(
              onTap: () {
                if (expried == 0) {
                  otp = sendOtp(widget.email);
                  runTimer();
                }
              },
              child: Text(
                expried == 0 ? 'Gửi lại' : expried.toString(),
                style: textNormalCustom(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
            )
          ],
        ),
      ),
    );
  }

  void _showToast({required BuildContext context, String? text}) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(text ?? S.current.dang_ky_that_bai),
      ),
    );
  }
}
