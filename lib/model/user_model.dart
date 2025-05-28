import 'dart:convert';

class UserModel {
  final String id;
  final String name;
  final String avatarUrl;
  final String token;
  final String status;

  UserModel({
    required this.id,
    required this.name,
    this.avatarUrl = 'https://i.pravatar.cc/100',
    this.token = '',
    this.status = 'offline',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'token': token,
      'status': status,
    };
  }

  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      avatarUrl: map['avatarUrl'] ?? 'https://i.pravatar.cc/100',
      token: map['token'] ?? '',
      status: map['status'] ?? 'offline',
    );
  }

  String toJson() => jsonEncode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(jsonDecode(source));
}
