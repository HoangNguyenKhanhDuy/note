import 'package:flutter/material.dart';
import 'package:note_app/api/account_api_service.dart';
import 'package:note_app/models/account.dart';
import 'package:note_app/screens/note_list_screen.dart';
import 'package:note_app/screens/register_screen.dart'; // Đăng ký
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true; // Hiển thị/ẩn mật khẩu
  bool _rememberMe = false; // Nhớ mật khẩu
  String errorMessage = ''; // Thông báo lỗi

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials(); // Tải thông tin đăng nhập đã lưu (nếu có)
  }

  // Tải thông tin đăng nhập đã lưu (tên đăng nhập và mật khẩu)
  Future<void> _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('savedUsername');
    String? savedPassword = prefs.getString('savedPassword');

    if (savedUsername != null && savedPassword != null) {
      setState(() {
        _usernameController.text = savedUsername;
        _passwordController.text = savedPassword;
        _rememberMe = true;
      });
    }
  }

  // Hàm đăng nhập
  Future<void> login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Vui lòng điền đủ thông tin';
      });
      return;
    }

    try {
      AccountAPIService accountAPIService = AccountAPIService();
      Account account = await accountAPIService.login(username, password);

      // Lưu thông tin đăng nhập nếu chọn "Nhớ mật khẩu"
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString('savedUsername', username);
        await prefs.setString('savedPassword', password);
      } else {
        await prefs.remove('savedUsername');
        await prefs.remove('savedPassword');
      }

      // Lưu userId để xác định đã đăng nhập
      await prefs.setString('userId', account.id);
      await prefs.setString('username', username);

      // Chuyển sang màn hình danh sách ghi chú sau khi đăng nhập thành công
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NoteListScreen()),
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Đăng nhập thất bại: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Đăng nhập"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.lock_outline, size: 80, color: Colors.blueAccent),
            SizedBox(height: 16),
            Text(
              'Chào mừng bạn quay lại!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 32),

            // Tên đăng nhập
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Tên đăng nhập',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 16),

            // Mật khẩu
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 8),

            // Lỗi nếu có
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),

            // Checkbox
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value!;
                    });
                  },
                ),
                Text('Nhớ mật khẩu'),
              ],
            ),
            SizedBox(height: 16),

            // Nút đăng nhập
            ElevatedButton(
              onPressed: login,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                child: Text('Đăng nhập', style: TextStyle(fontSize: 16)),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                backgroundColor: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 12),

            // Đăng ký
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterScreen()),
                );
              },
              child: Text(
                'Chưa có tài khoản? Đăng ký ngay',
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}