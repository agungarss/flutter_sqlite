import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

import 'login.dart';
import 'main_screen.dart';
import 'database/database_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Inisialisasi database di awal
  final dbHelper = DatabaseHelper();
  await dbHelper.database; // Ini akan memastikan database dibuat dengan benar

  runApp(MaterialApp(
    title: 'Online Shop',
    theme: ThemeData(
      primarySwatch: Colors.blue,
      useMaterial3: true,
    ),
    initialRoute: '/login',
    routes: {
      '/login': (context) => const LoginScreen(),
      '/home': (context) => const MainScreen(),
    },
  ));
}
