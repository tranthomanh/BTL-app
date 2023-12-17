import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ccvc_mobile/config/resources/color.dart';
import 'package:ccvc_mobile/config/resources/styles.dart';
import 'package:ccvc_mobile/config/themes/theme_color.dart';
import 'package:ccvc_mobile/domain/model/user_model.dart';
import 'package:ccvc_mobile/presentation/block_list/block_list_cubit.dart';
import 'package:ccvc_mobile/presentation/profile/ui/profile_screen.dart';
import 'package:ccvc_mobile/presentation/relationship_screen/bloc/relationship_cubit.dart';
import 'package:ccvc_mobile/presentation/relationship_screen/widget/friend_cell_widget.dart';
import 'package:ccvc_mobile/presentation/relationship_screen/widget/skeleton_friend_widget.dart';
import 'package:ccvc_mobile/utils/constants/image_asset.dart';
import 'package:ccvc_mobile/widgets/appbar/app_bar_default_back.dart';
import 'package:ccvc_mobile/widgets/textformfield/base_search_bar.dart';
import 'package:flutter/material.dart';

import '../../widgets/views/state_loading_skeleton.dart';

class BlockListScreen extends StatefulWidget {
  final String userId;
  final bool isSearch;
  const BlockListScreen(
      {Key? key, required this.userId, this.isSearch = false})
      : super(key: key);

  @override
  _BlockListScreenState createState() => _BlockListScreenState();
}

class _BlockListScreenState extends State<BlockListScreen> {
  final BlockListCubit cubit = BlockListCubit();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (!widget.isSearch) {
      cubit.fetchFriends(widget.userId);
    } else {
      cubit.showContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarDefaultBack(
        widget.isSearch ? 'Tìm kiếm' : 'Danh sách chặn',
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: BaseSearchBar(
                onChange: (value) {
                  if (!widget.isSearch) {
                    cubit.searchUser(value.trim());
                  }
                },
                onFieldSubmitted: (value) {
                  if (value.trim().isNotEmpty && widget.isSearch) {
                  //  cubit.searchNguoiLa(value);
                  }
                },
              ),
            ),
            Expanded(
              child: StateLoadingSkeleton(
                stream: cubit.stateStream,
                skeleton: const SkeletonFriendWidget(),
                child: StreamBuilder<List<UserModel>>(
                    stream: cubit.getBlockList,
                    builder: (context, snapshot) {
                      final data = snapshot.data ?? <UserModel>[];
                      return data.isEmpty
                          ? const Text('Không có dữ liệu')
                          : ListView(
                        children: List.generate(data.length, (index) {
                          final result = data[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ProfileScreen(
                                              userId: result.userId ?? '',
                                            )));
                              },
                              child: BlockCellWidget(
                                userModel: result,
                                cubit: cubit,
                                avatarUrl: result.avatarUrl ?? '',
                                name: result.nameDisplay ?? '',
                                peopleType: result.peopleType,
                              ),
                            ),
                          );
                        }),
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class BlockCellWidget extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final PeopleType? peopleType;
  final BlockListCubit cubit;
  final UserModel userModel;
  const BlockCellWidget(
      {Key? key,
        required this.userModel,
        required this.name,
        required this.avatarUrl,
        required this.cubit,
        this.peopleType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Container(
            height: 62,
            width: 62,
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.teal),
              child: CachedNetworkImage(
                imageUrl: avatarUrl,
                errorWidget: (context, url, error) =>
                    Image.asset(ImageAssets.avatarDefault),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: textNormal(colorBlack, 16),
              ),
              const SizedBox(
                height: 5,
              ),
              button(
                  onTap: () async {
                    final result = await showOkCancelAlertDialog(
                      context: context,
                      title: 'Bỏ chặn',
                      message: 'Bạn có chắc chắn muốn bỏ chặn người này?',
                      okLabel: 'Ok',
                      cancelLabel: 'Hủy',
                      fullyCapitalizedForMaterial: false,
                    );
                  //log(result.name.toString());

                    if (result.name == 'ok') {
                     await cubit.discardRelationship(userModel);
                      Navigator.pop(context);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  title: 'Bỏ chặn',
                  backGround: colorPrimary),
              // Row(
              //   children: [
              //     button(
              //         onTap: () {
              //          // onAccept();
              //         },
              //         title: 'Xác nhận',
              //         backGround: Color(0xff2374E1)),
              //     const SizedBox(
              //       width: 10,
              //     ),
              //     button(
              //         onTap: () {
              //         //  onDelete();
              //         },
              //         title: 'Xóa',
              //         backGround: Colors.black.withOpacity(0.4))
              //   ],
              // )
            ],
          ),
        ],
      ),
    );
  }

  Widget iconRight() {
    // switch (peopleType) {
    //   case PeopleType.Friend:
    //     return const Icon(Icons.more_horiz);
    //   case PeopleType.FriendRequest:
    //     return button(backGround: mainTxtColor, onTap: (){}, title: 'Hủy');
    //   case PeopleType.NoFriend:
    //    return button(backGround: mainTxtColor, onTap: (){}, title: 'Thêm bạn bè');
    // }
    return const SizedBox();
  }
  Widget button({required Color backGround,required Function() onTap,required String title}){
    return GestureDetector(
      onTap: (){
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
        decoration: BoxDecoration(
            color: backGround,
            borderRadius: const BorderRadius.all(Radius.circular(4))
        ),
        child: Text(title,style: textNormalCustom(color: Colors.white),),
      ),
    );
  }
}

