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
    id = json['id'] != null ? int.tryParse(json['id'].toString()) : null;
    title = json['title']?.toString();
    content = json['content']?.toString();
    signature = json['signature']?.toString();
    signedAt = json['signed_at']?.toString();
    status = json['status'] != null ? int.tryParse(json['status'].toString()) : null;
    deliveryManId = json['delivery_man_id'] != null ? int.tryParse(json['delivery_man_id'].toString()) : null;
    createdAt = json['created_at']?.toString();
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
