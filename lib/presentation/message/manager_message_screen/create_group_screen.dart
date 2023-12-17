import 'package:ccvc_mobile/config/resources/color.dart';
import 'package:ccvc_mobile/config/resources/styles.dart';
import 'package:ccvc_mobile/domain/model/message_model/room_chat_model.dart';
import 'package:ccvc_mobile/domain/model/user_model.dart';
import 'package:ccvc_mobile/presentation/message/bloc/message_cubit.dart';
import 'package:ccvc_mobile/utils/constants/image_asset.dart';
import 'package:ccvc_mobile/widgets/radio/check_box_widget.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class CreateGroupScreen extends StatefulWidget {
  final List<UserModel> listPeople;
  final MessageCubit cubit;
  final String title;
  final bool isAdd;
  final UserModel? selectDefault;
  const CreateGroupScreen(
      {Key? key,
      required this.listPeople,
      required this.cubit,
      required this.title,
      this.isAdd = false,
      this.selectDefault})
      : super(key: key);

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final BehaviorSubject<List<UserModel>> _select = BehaviorSubject();
  final List<UserModel> listSelect = [];
   List<UserModel> listFriend = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.cubit.getListFriend().then((value) {
      if(widget.listPeople.isNotEmpty) {
        listFriend = widget.cubit.listFriend.where((element) =>
        widget.listPeople
            .map((e) => e.userId)
            .contains(element.userId) ==
            false).toList();
      }else{
        listFriend = widget.cubit.listFriend;
      }
      if (widget.isAdd == false && widget.selectDefault != null) {
        if (listFriend
            .map((e) => e.userId)
            .contains(widget.selectDefault?.userId) ==
            false) {
          listFriend.add(widget.selectDefault!);
        }
        listSelect.add(widget.selectDefault!);
        _select.add(listSelect);
      }
      setState(() {

      });
    });

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
          selectItem(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: StreamBuilder<Object>(
                    stream: _select.stream,
                    builder: (context, snapshot) {
                      if(listFriend.isEmpty){
                        return Center(child: Text("Không có dữ liệu"));
                      }
                      return Column(
                        children:
                            List.generate(listFriend.length, (index) {
                          final data = listFriend[index];
                          return cellButton(
                            isCheck: listSelect
                                .map((e) => e.userId)
                                .contains(data.userId),
                            urlAvatar: data.avatarUrl ?? '',
                            name: data.nameDisplay ?? '',
                            onTap: () {
                              if (listSelect
                                  .map((e) => e.userId)
                                  .contains(data.userId)) {
                                listSelect.removeWhere(
                                    (element) => element.userId == data.userId);
                              } else {
                                listSelect.add(data);
                              }
                              _select.sink.add(listSelect);
                            },
                          );
                        }),
                      );
                    }),
              ),
            ),
          )
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
          Text(widget.isAdd ? 'Thêm người' : 'Nhóm mới',
              style: textNormalCustom(
                  color: titleCalenderWork,
                  fontSize: 18,
                  fontWeight: FontWeight.w500)),
          StreamBuilder(
              stream: _select.stream,
              builder: (context, snapshot) {
                return GestureDetector(
                  onTap: () {
                    if (widget.isAdd) {
                      widget.cubit
                          .addPeopleRoomChat(listSelect
                              .map(
                                (e) => PeopleChat(
                                  userId: e.userId?.trim() ?? '',
                                  avatarUrl: e.avatarUrl ?? '',
                                  nameDisplay: e.nameDisplay ?? '',
                                  bietDanh: '',
                                ),
                              )
                              .toList())
                          .then((value) {
                       Navigator.pop(context);
                       Navigator.pop(context);
                      });
                    } else {
                      if (listSelect.length > 1) {
                        widget.cubit
                            .createRoomChatDefault(listSelect
                                .map(
                                  (e) => PeopleChat(
                                    userId: e.userId?.trim() ?? '',
                                    avatarUrl: e.avatarUrl ?? '',
                                    nameDisplay: e.nameDisplay ?? '',
                                    bietDanh: '',
                                  ),
                                )
                                .toList())
                            .then((value) {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        });
                      }
                    }
                  },
                  child: Text(
                    widget.isAdd ? 'Thêm' : 'Tạo',
                    style: textNormalCustom(
                        color: listSelect.length > 1 || widget.isAdd
                            ? Colors.blue
                            : Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w400),
                  ),
                );
              })
        ],
      ),
    );
  }

  Widget selectItem() {
    Widget item(String name, String urlAvatar, Function() onTap) {
      return GestureDetector(
        onTap: () {
          onTap();
        },
        child: SizedBox(
          width: 65,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 4),
                      width: 60,
                      height: 60,
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
                      height: 5,
                    ),
                    Text(
                      name,
                      style: textNormal(titleCalenderWork, 12),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.black38, shape: BoxShape.circle),
                  child: const Icon(
                    Icons.close,
                    size: 20,
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: StreamBuilder<List<UserModel>>(
        stream: _select.stream,
        builder: (context, snapshot) {
          final data = snapshot.data ?? <UserModel>[];
          return Row(
            children: List.generate(
                data.length,
                (index) => Padding(
                      padding:
                          EdgeInsets.only(right: 16, left: index == 0 ? 16 : 0),
                      child: item(data[index].nameDisplay ?? '',
                          data[index].avatarUrl ?? '', () {
                        listSelect.removeWhere(
                            (element) => element.userId == data[index].userId);
                        _select.sink.add(listSelect);
                      }),
                    )),
          );
        },
      ),
    );
  }

  Widget cellButton({
    required bool isCheck,
    required String urlAvatar,
    required String name,
    required Function() onTap,
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
                  CheckBoxWidget(
                    value: isCheck,
                    onChange: (value) {
                      onTap();
                    },
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
