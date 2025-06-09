// File: fragment/settings.dart

import 'package:flutter/material.dart';

class SettingsFragment extends StatelessWidget {
  const SettingsFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // Agar tombol kembali terlihat
        elevation: 1,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive updates and offers'),
            value: true, // Ini adalah nilai sementara
            onChanged: (bool value) {
              // TODO: Implementasikan logika untuk menyimpan pengaturan notifikasi
            },
            secondary: const Icon(Icons.notifications),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Switch to dark theme'),
            value: false, // Ini adalah nilai sementara
            onChanged: (bool value) {
              // TODO: Implementasikan logika untuk mengubah tema aplikasi
            },
            secondary: const Icon(Icons.dark_mode),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Account'),
            onTap: () {
              // TODO: Navigasi ke halaman detail akun
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: const Text('English'),
            onTap: () {
              // TODO: Navigasi ke halaman pemilihan bahasa
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Online Shop',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 Your Company',
              );
            },
          ),
        ],
      ),
    );
  }
}
