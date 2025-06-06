class GroupModel {
  final String id;
  final String name;
  final String purpose;
  final String lastMessage;
 final int lastMessageTime;
  final String createdBy;
  final int createdAt;
  final List<String> members;

  GroupModel({
    required this.id,
    required this.name,
    required this.purpose,
    this.lastMessage = '',
    this.lastMessageTime = 0,
    required this.createdBy,
    required this.createdAt,
    required this.members,
  });

  factory GroupModel.fromMap(Map<String, dynamic> map, String id) {
    return GroupModel(
      id: id,
      name: map['name'] ?? '',
      purpose: map['purpose'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: map['lastMessageTime'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdAt: map['createdAt'] ?? 0,
      members: List<String>.from(map['members'] ?? []),
    );
  }
}
