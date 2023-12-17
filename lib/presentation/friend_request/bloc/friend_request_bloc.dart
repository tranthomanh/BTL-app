import 'package:ccvc_mobile/data/services/profile_service.dart';
import 'package:ccvc_mobile/domain/locals/prefs_service.dart';
import 'package:ccvc_mobile/domain/model/user_model.dart';
import 'package:ccvc_mobile/presentation/profile/bloc/profile_cubit.dart';
import 'package:rxdart/rxdart.dart';

class FriendRequestCubit extends ProfileCubit {
  final BehaviorSubject<List<UserModel>> _getListFriend =
      BehaviorSubject<List<UserModel>>();

  Stream<List<UserModel>> get getListFriend => _getListFriend.stream;
  List<UserModel> listFriendRequest = [];

  Future<void> fetchFriends() async {
    String ownerId = PrefsService.getUserId();
    showLoading();
    final result = await ProfileService.listFriendRequest(ownerId);
    listFriendRequest = result;
    showContent();
    _getListFriend.sink.add(result);
  }

  Future<void> confirmFriend(String idUserConfirm) async {
    try {
      listFriendRequest.removeWhere((element) => element.userId == idUserConfirm);
      _getListFriend.sink.add(listFriendRequest);
      await ProfileService.confirmAccecptFreind(idUserConfirm);

    } catch (e) {

    }
  }
  Future<void> delectFriendRequest(String idUserConfirm) async {
    try {
      listFriendRequest.removeWhere((element) => element.userId == idUserConfirm);
      _getListFriend.sink.add(listFriendRequest);
      await ProfileService.delectFriendRequets(idUserConfirm);


    } catch (e) {}
  }
}
