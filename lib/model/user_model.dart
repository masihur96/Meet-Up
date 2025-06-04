import 'dart:convert';

class UserModel {
  final String id;
  final String name;
  final String avatarUrl;
  final String token;
  final String status;
  final List<String> pinnedUserIds; // New
  final int unseenMessageCount; // New

  UserModel({
    required this.id,
    required this.name,
    this.avatarUrl = 'https://i.pravatar.cc/100',
    this.token = '',
    this.status = 'offline',
    this.pinnedUserIds=const [], // New
    this.unseenMessageCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'token': token,
      'status': status,
      'pinnedUserIds': pinnedUserIds,
      'unseenMessageCount': unseenMessageCount,
    };
  }

  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      avatarUrl: map['avatarUrl'] ?? 'https://i.pravatar.cc/100',
      token: map['token'] ?? '',
      status: map['status'] ?? 'offline',
      pinnedUserIds: map['pinnedUserIds'] != null
          ? List<String>.from(map['pinnedUserIds'])
          : const [],
      unseenMessageCount: map['unseenMessageCount'] ?? 0,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(jsonDecode(source));
}
