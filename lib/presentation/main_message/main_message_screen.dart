import 'package:ccvc_mobile/config/resources/color.dart';
import 'package:ccvc_mobile/config/resources/styles.dart';

import 'package:ccvc_mobile/domain/model/message_model/room_chat_model.dart';
import 'package:ccvc_mobile/generated/l10n.dart';
import 'package:ccvc_mobile/presentation/main_message/bloc/main_message_cubit.dart';
import 'package:ccvc_mobile/presentation/main_message/widgets/loading_skeleton_message_widget.dart';
import 'package:ccvc_mobile/presentation/main_message/widgets/tin_nhan_cell.dart';
import 'package:ccvc_mobile/presentation/message/bloc/message_cubit.dart';
import 'package:ccvc_mobile/presentation/message/manager_message_screen/create_group_screen.dart';
import 'package:ccvc_mobile/presentation/message/message_screen.dart';

import 'package:ccvc_mobile/utils/constants/image_asset.dart';
import 'package:ccvc_mobile/widgets/views/state_loading_skeleton.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class MainMessageScreen extends StatefulWidget {
  const MainMessageScreen({Key? key}) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MainMessageScreen> {
  MainMessageCubit cubit = MainMessageCubit();
  MessageCubit messageCubit = MessageCubit();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cubit.fetchRoom();
    messageCubit.getListFriend();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    cubit.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          S.current.messages,
          style: textNormalCustom(
              color: colorBlack, fontSize: 24, fontWeight: FontWeight.w700),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              showCupertinoModalBottomSheet(
                context: context,
                builder: (context) => CreateGroupScreen(
                  cubit: messageCubit,
                  title: 'Nhóm mới',
            listPeople: [],
                ),
              ).whenComplete(() {
                setState(() {});
              });
            },
            child: Container(
                width: 30,
                height: 30,
                margin: EdgeInsets.only(right: 16),
                color: Colors.transparent,
                child: const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.group_add,
                    color: Colors.black,
                  ),
                )),
          )
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Transform.translate(
            offset: const Offset(0, 40),
            child: SvgPicture.asset(
              ImageAssets.icBackgroundMessage,
              fit: BoxFit.fill,
            ),
          ),
          RefreshIndicator(
            onRefresh: () async {
              cubit.fetchRoom();
             await messageCubit.getListFriend();
            },
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 23),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    StateLoadingSkeleton(
                      stream: cubit.stateStream,
                      skeleton: const LoadingSkeletonMessageWidget(),
                      child: StreamBuilder<List<RoomChatModel>>(
                          stream: cubit.getRoomChat,
                          builder: (context, snapshot) {
                            final data = snapshot.data ?? <RoomChatModel>[];
                            if (data.isEmpty) {
                              return Center(child: Text("Không có dữ liêu"));
                            }
                            return Column(
                              children: List.generate(data.length, (index) {
                                final result = data[index];

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MessageScreen(
                                            isRoomGroup: result.isGroup,
                                            chatModel: result,
                                            peopleChat: result.peopleChats,
                                            peopleGroupChat:
                                                result.peopleChats.length < 2
                                                    ? null
                                                    : result.peopleChats,
                                          ),
                                        ),
                                      ).then((value) {
                                        setState(() {});
                                      });
                                    },
                                    child: TinNhanCell(

                                      chatModel: result,
                                    ),
                                  ),
                                );
                              }),
                            );
                          }),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
