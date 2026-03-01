import 'package:authproject/features/Auth/models/user_model.dart';
import 'package:authproject/features/Auth/services/user_service.dart';
import 'package:flutter/material.dart';

class UserList extends StatelessWidget {
  UserList({super.key});

  final UserService userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User List")),
      body: FutureBuilder<List<UserModel>>(
        future: userService.fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found'));
          } else {
            final users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 1,
                          child: user.isVerified
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                              : const Icon(Icons.cancel, color: Colors.red),
                        ),
                        Expanded(flex: 2, child: Text(user.email)),
                        Expanded(flex: 1, child: Text(user.username)),
                        Expanded(flex: 1, child: Text(user.role)),
                        Expanded(
                          flex: 1,
                          child: user.isBlocked
                              ? const Icon(Icons.block, color: Colors.red)
                              : const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
