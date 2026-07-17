class ContractModel {
  int? id;
  String? title;
  String? content;
  String? signature;
  String? signedAt;
  int? status;
  int? deliveryManId;
  String? createdAt;

  ContractModel({
    this.id,
    this.title,
    this.content,
    this.signature,
    this.signedAt,
    this.status,
    this.deliveryManId,
    this.createdAt,
  });

  ContractModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    content = json['content'];
    signature = json['signature'];
    signedAt = json['signed_at'];
    status = json['status'];
    deliveryManId = json['delivery_man_id'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['content'] = content;
    data['signature'] = signature;
    data['signed_at'] = signedAt;
    data['status'] = status;
    data['delivery_man_id'] = deliveryManId;
    data['created_at'] = createdAt;
    return data;
  }
}
