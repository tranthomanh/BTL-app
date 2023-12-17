class FriendModel {
  String userId1 = '';
  String userId2 = '';
  int type = 1;

  FriendModel(this.userId1, this.userId2, this.type);

  FriendModel.fromJson(Map<String, dynamic> json) {
    userId1 = json['user_id1'] ?? '';
    userId2 = json['user_id2'] ?? '';
    type = json['type'] ?? 1;
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['user_id1'] = userId1;
    json['user_id2'] = userId2;
    json['type'] = type;
    json['create_at'] = DateTime.now().millisecondsSinceEpoch;
    json['update_at'] = DateTime.now().millisecondsSinceEpoch;
    return json;
  }
}
