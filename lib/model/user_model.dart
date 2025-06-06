import 'dart:convert';

class UserModel {
  final String id;
  final String name;
  final String avatarUrl;
  final String token;
  final String status;
  final String lastMessageTime; // New
  final String lastMessage; // New
  final List<String> pinnedUserIds; // New
  final int unseenMessageCount; // New
  final List<String> groups;

  UserModel({
    required this.id,
    required this.name,
    this.avatarUrl = 'https://i.pravatar.cc/100',
    this.token = '',
    this.status = 'offline',
    this.lastMessageTime = '18.31',
    this.lastMessage = 'Pls take a look at the images.',
    this.pinnedUserIds=const [], // New
    this.unseenMessageCount = 0,
    this.groups = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'token': token,
      'status': status,
      'lastMessageTime': lastMessageTime,
      'lastMessage': lastMessage,
      'pinnedUserIds': pinnedUserIds,
      'unseenMessageCount': unseenMessageCount,
      'groups': groups,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      avatarUrl: map['avatarUrl'] ?? 'https://i.pravatar.cc/100',
      token: map['token'] ?? '',
      status: map['status'] ?? 'offline',
      lastMessageTime: map['lastMessageTime'] ?? '18.31',
      lastMessage: map['lastMessage'] ?? 'Pls take a look at the images.',
      pinnedUserIds: map['pinnedUserIds'] != null
          ? List<String>.from(map['pinnedUserIds'])
          : const [],
      unseenMessageCount: map['unseenMessageCount'] ?? 0,
      groups: List<String>.from(map['groups']?.keys ?? []),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(jsonDecode(source));
}
