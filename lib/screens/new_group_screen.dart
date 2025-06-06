import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:meet_check/model/user_model.dart';
import 'package:meet_check/service/local_storage_service.dart';

class NewGroupScreen extends StatefulWidget {
  const NewGroupScreen({super.key});

  @override
  State<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupPurposeController = TextEditingController();

  List<UserModel> allUsers = [];
  List<UserModel> selectedUsers = [];
  UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadUsers();
  }

  Future<void> _loadCurrentUser() async {
    currentUser = await LocalUserStorage.getUser();
  }

  void _loadUsers() {
    _database.child('users').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        final usersMap = Map<String, dynamic>.from(data as Map);
        final usersList = usersMap.entries.map((entry) {
          final userMap = Map<String, dynamic>.from(entry.value);
          return UserModel.fromMap(userMap);
        }).toList();

        setState(() {
          allUsers = usersList;
        });
      }
    });
  }

  Future<void> _createGroup() async {
    if (_groupNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a group name')),
      );
      return;
    }

    if (selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one member')),
      );
      return;
    }

    try {
      // Create a new group in the database
      final groupRef = _database.child('groups').push();
      final groupId = groupRef.key!;

      // Add current user to selected users if not already included
      if (currentUser != null && !selectedUsers.contains(currentUser)) {
        selectedUsers.add(currentUser!);
      }

      // Create group data
      final groupData = {
        'name': _groupNameController.text,
        'purpose': _groupPurposeController.text,
        'createdBy': currentUser?.id,
        'createdAt': ServerValue.timestamp,
        'members': selectedUsers.map((user) => user.id).toList(),
        'lastMessage': '',
        'lastMessageTime': ServerValue.timestamp,
      };

      // Save group data
      await groupRef.set(groupData);

      // Add group reference to each member's groups
      for (var user in selectedUsers) {
        await _database
            .child('users')
            .child(user.id)
            .child('groups')
            .child(groupId)
            .set(true);
      }

      if (mounted) {
        Navigator.pop(context, groupId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating group: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Group'),
        actions: [
          TextButton(
            onPressed: _createGroup,
            child: const Text('Create'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _groupPurposeController,
              decoration: const InputDecoration(
                labelText: 'Group Purpose',
                border: OutlineInputBorder(),
              ),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 12),
          if (selectedUsers.isNotEmpty)
            Container(
              height: 100,
              padding: const EdgeInsets.all(8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: selectedUsers.length,
                itemBuilder: (context, index) {
                  final user = selectedUsers[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(user.avatarUrl),
                            ),
                            Positioned(
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    selectedUsers.remove(user);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        Text(user.name, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                },
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: allUsers.length,
              itemBuilder: (context, index) {
                final user = allUsers[index];
                final isSelected = selectedUsers.contains(user);

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user.avatarUrl),
                  ),
                  title: Text(user.name),
                  trailing: Checkbox(
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedUsers.add(user);
                        } else {
                          selectedUsers.remove(user);
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _groupPurposeController.dispose();
    super.dispose();
  }
}