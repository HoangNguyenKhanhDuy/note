import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:note_app/screens/edit_account_screen.dart'; // Đảm bảo đường dẫn chính xác

class AccountInfoScreen extends StatefulWidget {
  @override
  _AccountInfoScreenState createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  String? username;
  String? email;
  String? avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadAccountInfo();
  }

  // Hàm tải thông tin tài khoản từ SharedPreferences
  Future<void> _loadAccountInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
      email = prefs.getString('email');
      avatarUrl = prefs.getString('avatarUrl');
    });
  }

  // Hàm để sửa thông tin tài khoản (chuyển đến màn hình sửa)
  void _editAccountInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditAccountScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thông Tin Tài Khoản')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            avatarUrl != null
                ? CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(avatarUrl!),
            )
                : Icon(Icons.account_circle, size: 100),
            SizedBox(height: 16),
            Text('Tên đăng nhập: $username', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Email: $email', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _editAccountInfo,
              child: Text('Sửa Thông Tin Tài Khoản'),
            ),
          ],
        ),
      ),
    );
  }
}
