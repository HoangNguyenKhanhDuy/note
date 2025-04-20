import 'package:flutter/material.dart';

class RegisterForm extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final String errorMessage;
  final VoidCallback onRegister;
  final VoidCallback onBackToLogin;

  const RegisterForm({
    required this.usernameController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.errorMessage,
    required this.onRegister,
    required this.onBackToLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Card(
          elevation: 12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_add_alt_1, size: 72, color: Colors.blueAccent),
                const SizedBox(height: 16),
                Text(
                  'Tạo tài khoản mới',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 24),

                // Tên đăng nhập
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Tên đăng nhập',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Mật khẩu
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Xác nhận mật khẩu
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Xác nhận mật khẩu',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                if (errorMessage.isNotEmpty)
                  Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                const SizedBox(height: 20),

                // Nút đăng ký
                ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Đăng ký'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.blueAccent,
                  ),
                  onPressed: onRegister,
                ),
                const SizedBox(height: 12),

                // Quay lại đăng nhập
                TextButton(
                  onPressed: onBackToLogin,
                  child: const Text(
                    '← Quay lại đăng nhập',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
