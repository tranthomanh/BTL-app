import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ccvc_mobile/config/resources/color.dart';
import 'package:ccvc_mobile/config/resources/styles.dart';
import 'package:ccvc_mobile/data/services/message_service.dart';
import 'package:ccvc_mobile/domain/model/message_model/message_sms_model.dart';
import 'package:ccvc_mobile/domain/model/message_model/room_chat_model.dart';
import 'package:ccvc_mobile/utils/constants/image_asset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TinNhanCell extends StatelessWidget {

  final RoomChatModel chatModel;
  const TinNhanCell({Key? key,required this.chatModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final peopleChat = chatModel.peopleChats;

    return Container(
      height: 103,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: const BorderRadius.all(Radius.circular(30))),
      child: Row(
        children: [
          avatar(),
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chatModel.titleName(),
                    style: textNormalCustom(color: colorBlack, fontSize: 14),
                    maxLines: 2,
                  ),
                  const SizedBox(
                    height: 9,
                  ),
                  Expanded(
                    child: StreamBuilder<List<MessageSmsModel>>(
                      stream: MessageService.smsRealTimeMain(chatModel.roomId),
                      builder: (context, snapshot) {
                        final data = snapshot.data ?? <MessageSmsModel>[];
                        String title = '';
                        if (data.isNotEmpty) {
                          if (data.first.smsType == SmsType.Image) {
                            title = 'Có 1 ảnh';
                          } else if(data.first.smsType == SmsType.Tin_Nhan_Go_bo) {
                            title = '1 tin nhắn bị gỡ bỏ';
                          }else{
                            title = data.first.content ?? '';
                          }
                        }
                        return Row(
                          children: [
                            countChuaXem(data
                                .where((element) => element.isDaXem == false)
                                .length),
                            const SizedBox(
                              width: 6,
                            ),
                            Expanded(
                              child: Text(
                                title,
                                style: textNormal(greyHide, 12),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget countChuaXem(int sum) {
    String index = sum > 5 ? '5+' : '$sum';
    return sum == 0
        ? const SizedBox()
        : Container(
            height: 20,
            width: 20,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              index,
              style: textNormal(Colors.white, 12),
            ),
          );
  }

  Widget avatar() {
    return chatModel.peopleChats.length == 1
        ? Container(
            height: 62,
            width: 62,
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all()),
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.teal),
              child: CachedNetworkImage(
                imageUrl: chatModel.peopleChats.first.avatarUrl,
                errorWidget: (context, url, error) =>
                    SvgPicture.asset(ImageAssets.avatarDefault),
                fit: BoxFit.cover,
              ),
            ),
          )
        : avatarGroup();
  }

  Widget avatarGroup() {
    Widget avatar(String url, double size) {
      return Container(
        height: size,
        width: size,
        clipBehavior: Clip.hardEdge,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all()),
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration:
              const BoxDecoration(shape: BoxShape.circle, color: Colors.teal),
          child: CachedNetworkImage(
            imageUrl: url,
            errorWidget: (context, url, error) =>
                SvgPicture.asset(ImageAssets.avatarDefault),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return chatModel.peopleChats.length < 2
        ? const SizedBox()
        : Container(
            width: 62,
            height: 62,
            child: Stack(
              children: [
                avatar(chatModel.peopleChats.first.avatarUrl, 50),
                Positioned(
                  top: 0,
                  right: 0,
                  child: avatar(chatModel.peopleChats.last.avatarUrl, 40),
                )
              ],
            ),
          );
  }


}
