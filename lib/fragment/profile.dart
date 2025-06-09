// File: fragment/profile.dart

import 'package:flutter/material.dart';

class ProfileFragment extends StatelessWidget {
  final String username;

  const ProfileFragment({
    super.key,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    // Fragment ini tidak memiliki AppBar sendiri karena AppBar utama dari MainScreen akan digunakan.
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/asik.jpeg'),
            ),
            const SizedBox(height: 20),
            Text(
              username,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'This is your profile page. Edit your details here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement edit profile logic
              },
              child: const Text('Edit Profile'),
            )
          ],
        ),
      ),
    );
  }
}
