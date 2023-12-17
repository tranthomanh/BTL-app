import 'dart:math';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:otp/otp.dart';


const USER_NAME = 'bancadev01@gmail.com';
const PASS_WORD = 'yzarpbprubwnjxjl';
 final smtpServer = gmail(USER_NAME, PASS_WORD);

 class OtpModel{
  String otp;
  String expired;
  OtpModel({required this.otp,required this.expired});
 }

 OtpModel otpExpired =  OtpModel(expired: '',otp: '');

 String sendOtp(String email)  {
  otpExpired = OtpModel(otp: generateOTP(), expired: '');
  final message = Message()
    ..from = Address(USER_NAME, 'OTP')
    ..recipients.add(email)
    ..subject = 'Social network'
    ..text = 'Mã xác thực của bạn là:${otpExpired.otp}';

  try {
     send(message, smtpServer);
    return otpExpired.otp;
  } on MailerException catch (e) {
    return '';
    print('Message not sent.');
    for (var p in e.problems) {
      print('Problem: ${p.code}: ${p.msg}');
    }
  }
}

String generateOTP(){
var rng =  Random();
var code = rng.nextInt(900000) + 100000;
return code.toString();
}