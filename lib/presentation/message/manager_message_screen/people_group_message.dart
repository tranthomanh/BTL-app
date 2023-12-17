import 'dart:developer';

import 'package:ccvc_mobile/config/resources/color.dart';
import 'package:ccvc_mobile/config/resources/styles.dart';
import 'package:ccvc_mobile/domain/locals/prefs_service.dart';
import 'package:ccvc_mobile/domain/model/user_model.dart';
import 'package:ccvc_mobile/presentation/message/bloc/message_cubit.dart';
import 'package:ccvc_mobile/presentation/message/manager_message_screen/create_group_screen.dart';
import 'package:ccvc_mobile/utils/constants/image_asset.dart';
import 'package:ccvc_mobile/widgets/dialog/cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rxdart/rxdart.dart';

class PeopleGroupScreen extends StatefulWidget {
  final List<UserModel> listFriend;
  final MessageCubit cubit;
  final String title;
  const PeopleGroupScreen(
      {Key? key,
      required this.listFriend,
      required this.cubit,
      required this.title})
      : super(key: key);

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<PeopleGroupScreen> {
  final BehaviorSubject<List<UserModel>> _data = BehaviorSubject();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _data.sink.add(widget.listFriend);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          appBar(),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: StreamBuilder<List<UserModel>>(
                    stream: _data.stream,
                    builder: (context, snapshot) {
                      final data = snapshot.data ?? <UserModel>[];
                      if(data.isEmpty){
                        return Text("Không có dữ liệu");
                      }
                      return Column(
                        children: List.generate(data.length, (index) {
                          final data = widget.listFriend[index];
                          return cellButton(
                            isCheck: true,
                            urlAvatar: data.avatarUrl ?? '',
                            name: data.nameDisplay ?? '',
                            onTap: () {
                              if(widget.cubit.peopleChat.length < 3){
                                CoolAlert.show(
                                    context: context,
                                    type: CoolAlertType.warning,
                                    text:
                                    'Nhóm cần tối thiểu 3 người',
                                    onConfirmBtnTap: () {

                                      Navigator.pop(context);
                                    });
                                return;
                              }
                              CoolAlert.show(
                                  context: context,
                                  type: CoolAlertType.confirm,
                                  text:
                                      'Bạn có chắc khi xóa người này ra khỏi nhóm?',
                                  onConfirmBtnTap: () {
                                    widget.cubit
                                        .removePeople(data.userId ?? '');
                                    _data.value.removeWhere((element) =>
                                        element.userId == data.userId);
                                    _data.sink.add(_data.value);
                                    Navigator.pop(context);
                                  });
                            }, idUser: data.userId ?? '',
                          );
                        }),
                      );
                    }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget appBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Text(
              'Hủy',
              style: textNormal(Colors.blue, 16),
            ),
          ),
          Text('Thành viên',
              style: textNormalCustom(
                  color: titleCalenderWork,
                  fontSize: 18,
                  fontWeight: FontWeight.w500)),
          GestureDetector(
              onTap: () {
                showCupertinoModalBottomSheet(
                  context: context,
                  builder: (context) => CreateGroupScreen(
                    isAdd: true,
                    listPeople: _data.value,
                    cubit: widget.cubit,
                    title: '',
                  ),
                );
              },
              child: Icon(Icons.add))
        ],
      ),
    );
  }

  Widget cellButton({
    required bool isCheck,
    required String urlAvatar,
    required String name,
    required Function() onTap,
    required String idUser
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        onTap();
      },
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Image.network(
              urlAvatar,
              errorBuilder: (_, __, ___) =>
                  Image.asset(ImageAssets.avatarDefault),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: const BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: borderItemCalender))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: textNormal(Colors.black, 14),
                  ),
                  Visibility(
                    visible: idUser != PrefsService.getUserId(),
                    child: GestureDetector(
                        onTap: () {
                          onTap();
                        },
                        child: const Icon(
                          Icons.remove_circle,
                          color: Colors.red,
                        )),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
