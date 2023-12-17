import 'dart:developer';

import 'package:ccvc_mobile/config/base/base_cubit.dart';
import 'package:ccvc_mobile/data/services/message_service.dart';
import 'package:ccvc_mobile/data/services/profile_service.dart';
import 'package:ccvc_mobile/domain/locals/prefs_service.dart';

import 'package:ccvc_mobile/domain/model/message_model/room_chat_model.dart';
import 'package:ccvc_mobile/domain/model/user_model.dart';
import 'package:ccvc_mobile/presentation/main_message/bloc/main_message_state.dart';
import 'package:ccvc_mobile/presentation/relationship_screen/bloc/relationship_state.dart';
import 'package:ccvc_mobile/utils/extensions/string_extension.dart';

import 'package:rxdart/rxdart.dart';

class RelationShipCubit extends BaseCubit<RelationshipState> {
  RelationShipCubit() : super(RelationshipStateStateIntial());

  final BehaviorSubject<List<UserModel>> _getListFriend =
      BehaviorSubject<List<UserModel>>();

  Stream<List<UserModel>> get getListFriend => _getListFriend.stream;
  final idUser = PrefsService.getUserId();
  List<UserModel> listFriend = [];
  List<UserModel> blocs = [];
  Future<void> fetckBloc() async {
    final result = await ProfileService.listFriends(PrefsService.getUserId(),
        getBloc: false);
    blocs = result.where((e) => e.peopleType == PeopleType.Block).toList();
  }

  Future<void> fetchFriends(String id) async {
    showLoading();
    final result = await ProfileService.listFriends(id);
    listFriend = result;
    showContent();
    _getListFriend.sink.add(result);
  }

  void searchNguoiLa(String keySearch) {
    listFriend = [];
    showLoading();
    ProfileService.searchKey(keySearch,blocs).listen((event) {
      if (event != null) {
        listFriend.add(event);
        _getListFriend.sink.add(listFriend);
      } else {
        _getListFriend.sink.add([]);
      }
      showContent();
    });
  }

  void searchUser(String keySearch) {
    if (keySearch.isEmpty) {
      _getListFriend.sink.add(listFriend);
      return;
    }
    final data = listFriend
        .where((element) => element.nameDisplay == null
            ? false
            : element.nameDisplay!
                .toLowerCase()
                .vietNameseParse()
                .contains(keySearch.toLowerCase().vietNameseParse()))
        .toList();
    _getListFriend.sink.add(data);
  }
}
