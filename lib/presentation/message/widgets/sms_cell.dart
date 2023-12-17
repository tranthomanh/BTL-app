import 'package:cached_network_image/cached_network_image.dart';
import 'package:ccvc_mobile/domain/model/message_model/message_sms_model.dart';
import 'package:ccvc_mobile/domain/model/message_model/room_chat_model.dart';
import 'package:ccvc_mobile/presentation/message/message_sms_extension.dart';
import 'package:flutter/material.dart';

class SmsCell extends StatelessWidget {
  final MessageSmsModel smsModel;
  final PeopleChat? peopleChat;
  const SmsCell({Key? key, required this.smsModel, required this.peopleChat})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMe = smsModel.isMe();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Visibility(
          visible: !isMe,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20, right: 16),
            child: Container(
              width: 25,
              height: 25,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: CachedNetworkImage(
                imageUrl: peopleChat?.avatarUrl ?? '',
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: smsModel.smsType.getSmsWidget(context, smsModel),
          ),
        ),
      ],
    );
  }
}
