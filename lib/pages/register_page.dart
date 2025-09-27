import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../databases/user_database.dart';
import '../globals.dart';
import '../models/user.dart';
import '../services/secure_storage_service.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  final ValueNotifier<bool> _isSaving = ValueNotifier(false);

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    _isSaving.value = true;

    try {
      await SecureStorageService.addUser(username, password);

      await UserDatabase.insertUser(
        User(
          profilePictureFilePath: null,
          userName: username
        )
      );

      Fluttertoast.showToast(msg: "Registration successful");

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (_) => false,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }

    _isSaving.value = false;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _isSaving.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (val) =>
                    val == null || val.isEmpty ? "Username required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (val) =>
                    val == null || val.isEmpty ? "Password required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Confirm Password",
                  border: OutlineInputBorder(),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (val) {
                  if (val == null || val.isEmpty) return "Confirm password required";
                  if (val != _passwordController.text) return "Passwords do not match";
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ValueListenableBuilder<bool>(
                valueListenable: _isSaving,
                builder: (context, saving, _) {
                  if (saving) {
                    return const CircularProgressIndicator();
                  }
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryYellow,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _registerUser,
                    child: const Text("Register"),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
