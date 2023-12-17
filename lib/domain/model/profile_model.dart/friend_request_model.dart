class FriendRequestModel {
  String receiverId = '';
  String senderId = '';
  int createAt = 0;
  int updateAt = 0;

  FriendRequestModel.fromJson(Map<String, dynamic> json) {
    receiverId = json['receiver'] ?? '';
    senderId = json['sender'] ?? '';
    createAt = json['create_at'] ?? 0;
    updateAt = json['update_at'] ?? 0;
  }
}
