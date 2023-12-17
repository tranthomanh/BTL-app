import 'package:ccvc_mobile/domain/model/user_model.dart';
import 'package:ccvc_mobile/presentation/profile/ui/profile_screen.dart';
import 'package:ccvc_mobile/presentation/relationship_screen/bloc/relationship_cubit.dart';
import 'package:ccvc_mobile/presentation/relationship_screen/widget/friend_cell_widget.dart';
import 'package:ccvc_mobile/presentation/relationship_screen/widget/skeleton_friend_widget.dart';
import 'package:ccvc_mobile/widgets/appbar/app_bar_default_back.dart';
import 'package:ccvc_mobile/widgets/textformfield/base_search_bar.dart';
import 'package:flutter/material.dart';

import '../../widgets/views/state_loading_skeleton.dart';

class RelationshipScreen extends StatefulWidget {
  final String userId;
  final bool isSearch;
  const RelationshipScreen(
      {Key? key, required this.userId, this.isSearch = false})
      : super(key: key);

  @override
  _RelationshipScreenState createState() => _RelationshipScreenState();
}

class _RelationshipScreenState extends State<RelationshipScreen> {
  final RelationShipCubit cubit = RelationShipCubit();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (!widget.isSearch) {
      cubit.fetchFriends(widget.userId);
    } else {
      cubit.fetckBloc();
      cubit.showContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarDefaultBack(
        widget.isSearch ? 'Tìm kiếm' : 'Bạn bè',
        rightIcon: widget.isSearch
            ? const SizedBox()
            : GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RelationshipScreen(
                                userId: '',
                                isSearch: true,
                              )));
                },
                child: Container(
                    width: 30,
                    height: 30,
                    color: Colors.transparent,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Icon(
                        Icons.add,
                        color: Colors.black,
                      ),
                    )),
              ),
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
                    cubit.searchNguoiLa(value);
                  }
                },
              ),
            ),
            Expanded(
              child: StateLoadingSkeleton(
                stream: cubit.stateStream,
                skeleton: const SkeletonFriendWidget(),
                child: StreamBuilder<List<UserModel>>(
                    stream: cubit.getListFriend,
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
                                    child: FriendCellWidget(
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
