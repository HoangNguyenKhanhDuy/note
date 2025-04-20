import 'package:flutter/material.dart';
import 'package:note_app/screens/login_screen.dart';
import 'package:note_app/widgets/register_form.dart';
import 'package:note_app/api/account_api_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String errorMessage = '';

  final AccountAPIService apiService = AccountAPIService();

  Future<void> register() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() => errorMessage = 'Vui lòng điền đầy đủ thông tin');
      return;
    }

    if (password != confirmPassword) {
      setState(() => errorMessage = 'Mật khẩu không khớp');
      return;
    }

    try {
      await apiService.register(username, password);

      // Thành công → quay về đăng nhập
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      setState(() => errorMessage = 'Đăng ký thất bại: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text("Đăng ký tài khoản"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RegisterForm(
          usernameController: _usernameController,
          passwordController: _passwordController,
          confirmPasswordController: _confirmPasswordController,
          errorMessage: errorMessage,
          onRegister: register,
          onBackToLogin: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
