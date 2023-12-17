import 'dart:developer';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:ccvc_mobile/config/resources/styles.dart';
import 'package:ccvc_mobile/data/exception/app_exception.dart';
import 'package:ccvc_mobile/domain/model/message_model/message_sms_model.dart';
import 'package:ccvc_mobile/domain/model/message_model/room_chat_model.dart';
import 'package:ccvc_mobile/presentation/message/bloc/message_cubit.dart';
import 'package:ccvc_mobile/presentation/message/manager_message_screen/manager_message_screen.dart';
import 'package:ccvc_mobile/presentation/message/widgets/header_mess_widget.dart';
import 'package:ccvc_mobile/presentation/message/widgets/send_sms_widget.dart';
import 'package:ccvc_mobile/presentation/message/widgets/sms_cell.dart';
import 'package:flutter/material.dart';

import '../../widgets/views/state_stream_layout.dart';

class MessageScreen extends StatefulWidget {
  final RoomChatModel? chatModel;
  final List<PeopleChat> peopleChat;
  final List<PeopleChat>? peopleGroupChat;
  final bool isRoomGroup;
  const MessageScreen(
      {Key? key,
      this.chatModel,
      required this.peopleChat,
      this.peopleGroupChat,
      this.isRoomGroup = false})
      : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  MessageCubit cubit = MessageCubit();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cubit.isRoomGroup = widget.isRoomGroup;
    cubit.chatModel = widget.chatModel;
    if (widget.chatModel != null) {
      cubit.peopleGroupChat = widget.peopleGroupChat;
      cubit.initDate(widget.chatModel?.roomId ?? '', widget.peopleChat);
    } else {
      cubit.peopleChat = widget.peopleChat;
      cubit.getRoomChat(widget.peopleChat.first.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StateStreamLayout(
      retry: () {},
      error: AppException('', ''),
      stream: cubit.stateStream,
      textEmpty: '',
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ManagerMessagerScreen(
                        peopleChats: cubit.peopleChat,
                        messageCubit: cubit,
                        isGroup: widget.isRoomGroup,
                      ),
                    ),
                  ).then((value) {
                    setState(() {});
                  });
                },
                child: HeaderMessWidget(
                  cubit: cubit,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              StreamBuilder<String>(
                stream: cubit.roomChat,
                builder: (context, snapshot) {
                  final id = snapshot.data ?? '';
                  return Expanded(
                    child: SingleChildScrollView(
                      reverse: true,
                      child: StreamBuilder<List<MessageSmsModel>>(
                          stream: cubit.chatStream(id),
                          builder: (context, snapshot) {
                            final data = snapshot.data ?? <MessageSmsModel>[];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: List.generate(data.length, (index) {
                                final result = data[index];
                                PeopleChat? peopleSender;
                                if (cubit.peopleGroupChat != null) {
                                  final peopleGruop = cubit.peopleGroupChat!
                                      .where((element) =>
                                          element.userId == result.senderId);
                                  if (peopleGruop.isNotEmpty) {
                                    peopleSender = peopleGruop.first;
                                  }
                                } else {
                                  if (widget.peopleChat.isNotEmpty) {
                                    peopleSender = widget.peopleChat.first;
                                  }
                                }
                                return GestureDetector(
                                  onLongPress: () {
                                    if (result.isMe() &&
                                        result.smsType !=
                                            SmsType.Tin_Nhan_Go_bo) {
                                      showModalActionSheet(
                                        context: context,
                                        style: AdaptiveStyle.cupertino,
                                        actions: [
                                          const SheetAction(
                                              label: 'Thu hồi tin nhắn',
                                              key: 'GO_TN')
                                        ],
                                      ).then((value) {
                                        if (value == 'GO_TN') {
                                          cubit.goBoTinNhan(result.id ?? '');
                                        }
                                      });
                                    }
                                  },
                                  child: SmsCell(
                                    smsModel: result,
                                    peopleChat: peopleSender,
                                  ),
                                );
                              }),
                            );
                          }),
                    ),
                  );
                },
              ),
              StreamBuilder(
                  stream: cubit.roomChat,
                  builder: (context, snapshot) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: cubit.isBlock()
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                'Bạn không thể nhắn tin cho tài khoản này',
                                style: textNormal(Colors.black, 14),
                              ),
                            )
                          : SendSmsWidget(
                              hintText: 'Soạn tin nhắn...',
                              sendTap: (value) {
                                cubit.sendSms(value);
                              },
                              onSendFile: (value) {
                                cubit.sendImage(value);
                              },
                            ),
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
}
