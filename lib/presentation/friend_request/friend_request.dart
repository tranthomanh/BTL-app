import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:ccvc_mobile/domain/model/user_model.dart';
import 'package:ccvc_mobile/presentation/friend_request/bloc/friend_request_bloc.dart';
import 'package:ccvc_mobile/presentation/relationship_screen/widget/skeleton_friend_widget.dart';
import 'package:ccvc_mobile/widgets/appbar/app_bar_default_back.dart';
import 'package:flutter/material.dart';

import '../../widgets/views/state_loading_skeleton.dart';
import 'widgets/friend_cell_request.dart';

class FriendRequestScreen extends StatefulWidget {
  const FriendRequestScreen({Key? key}) : super(key: key);

  @override
  _FriendRequestScreenState createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  FriendRequestCubit cubit = FriendRequestCubit();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cubit.fetchFriends();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarDefaultBack('Lời mời kết bạn'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: StateLoadingSkeleton(
          stream: cubit.stateStream,
          skeleton: const SkeletonFriendWidget(),
          child: StreamBuilder<List<UserModel>>(
              stream: cubit.getListFriend,
              builder: (context, snapshot) {
                final data = snapshot.data ?? <UserModel>[];
                return data.isEmpty
                    ? Center(child: const Text('Không có dữ liệu'))
                    : ListView(
                        children: List.generate(data.length, (index) {
                          final result = data[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: FriendRequestCellWidget(
                              avatarUrl: result.avatarUrl ?? '',
                              name: result.nameDisplay ?? '',
                              peopleType: result.peopleType,
                              onAccept: () async {
                                final accept = await showOkCancelAlertDialog(
                                  context: context,
                                  title: 'Đồng ý kết bạn',
                                  message:
                                      'Bạn có chắc chắn muốn đồng ý kết bạn với người này?',
                                  okLabel: 'Ok',
                                  cancelLabel: 'Hủy',
                                  fullyCapitalizedForMaterial: false,
                                );

                                if (accept.name == 'ok') {
                                  cubit.confirmFriend(result.userId ?? '');
                                } else {
                                  Navigator.pop(context);
                                }
                              },
                              onDelete: () async {
                                final accept = await showOkCancelAlertDialog(
                                  context: context,
                                  title: 'Xoá lời mời kết bạn',
                                  message:
                                      'Bạn có chắc chắn muốn xoá lời mời kết bạn của người này?',
                                  okLabel: 'Ok',
                                  cancelLabel: 'Hủy',
                                  fullyCapitalizedForMaterial: false,
                                );

                                if (accept.name == 'ok') {
                                  cubit
                                      .delectFriendRequest(result.userId ?? '');
                                } else {
                                  Navigator.pop(context);
                                }
                              },
                            ),
                          );
                        }),
                      );
              }),
        ),
      ),
    );
  }
}
