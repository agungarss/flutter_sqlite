import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart'; // DIHAPUS: Tidak lagi diperlukan
import 'database/db_helper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  DateTime? _selectedDate;
  // PlatformFile? _selectedFile; // DIHAPUS: Variabel untuk file tidak diperlukan
  String? _selectedGender;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // DIHAPUS: Fungsi _pickFile() tidak lagi diperlukan
  // Future<void> _pickFile() async { ... }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      try {
        print('Preparing user data for registration');
        final Map<String, dynamic> userData = {
          'username': _usernameController.text.trim(),
          'password': _passwordController.text,
          'email': _emailController.text.trim(),
          'birthDate': _selectedDate?.toIso8601String(),
          'gender': _selectedGender,
        };
        print('User data prepared: $userData');

        final dbHelper = DatabaseHelper();
        final id = await dbHelper.insertUser(userData);
        print('Registration successful with id: $id');

        if (id > 0) {
          if (!mounted) return;
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Registration Successful'),
              content: const Text(
                'Your account has been created successfully.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Return to login screen
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          throw Exception('Failed to insert user');
        }
      } catch (e) {
        print('Registration error: $e');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Registration Failed'),
            content: Text('Error: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePasswordMatch(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please repeat your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // DIHAPUS: Fungsi _validateFile() tidak lagi diperlukan
  // String? _validateFile(PlatformFile? file) { ... }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Register',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person),
                          labelText: 'Username',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email),
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _repeatPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          labelText: 'Repeat Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        validator: _validatePasswordMatch,
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.calendar_today),
                              labelText: _selectedDate == null
                                  ? 'Tanggal Lahir'
                                  : _selectedDate!
                                      .toLocal()
                                      .toString()
                                      .split(' ')[0],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            validator: (value) {
                              if (_selectedDate == null) {
                                return 'Please select your birth date';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // DIGANTI: Menggunakan DropdownButtonFormField untuk Jenis Kelamin
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.wc), // Ikon untuk gender
                          labelText: 'Jenis Kelamin',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        hint: const Text('Pilih Jenis Kelamin'),
                        items: const [
                          DropdownMenuItem(
                            value: 'L',
                            child: Text('Laki-laki'),
                          ),
                          DropdownMenuItem(
                            value: 'P',
                            child: Text('Perempuan'),
                          ),
                        ],
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedGender = newValue;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Pilih jenis kelamin' : null,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Register',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
