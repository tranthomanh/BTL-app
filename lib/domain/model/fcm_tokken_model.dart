class FcmTokenModel {
  String? userId;
  String? tokenFcm;
  int? createAt;
  int? updateAt;

  FcmTokenModel.empty();

  FcmTokenModel({
    required this.userId,
    required this.tokenFcm,
    required this.createAt,
    required this.updateAt,
  });

  FcmTokenModel.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'] as String?;
    tokenFcm = json['token_fcm'] as String?;
    createAt = json['create_at'] as int?;
    updateAt = json['update_at'] as int?;
  }

  Map<String, dynamic> toJson(FcmTokenModel model) => <String, dynamic>{
    'user_id' : model.userId,
    'token_fcm' : model.tokenFcm,
    'create_at' : model.createAt,
    'update_at' : model.updateAt,
  };
}
