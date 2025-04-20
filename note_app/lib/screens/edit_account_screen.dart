import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditAccountScreen extends StatefulWidget {
  @override
  _EditAccountScreenState createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _avatarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAccountInfo();
  }

  // Hàm tải thông tin tài khoản để chỉnh sửa
  Future<void> _loadAccountInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailController.text = prefs.getString('email') ?? '';
      _avatarController.text = prefs.getString('avatarUrl') ?? '';
    });
  }

  // Hàm lưu thông tin đã chỉnh sửa
  Future<void> _saveAccountInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', _emailController.text);
    await prefs.setString('avatarUrl', _avatarController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cập nhật thông tin thành công!')),
    );

    Navigator.pop(context);  // Quay lại màn hình trước đó
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sửa Avatar')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Avatar URL:', style: TextStyle(fontSize: 18)),
            TextField(
              controller: _avatarController,
              decoration: InputDecoration(hintText: 'Nhập URL avatar mới'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveAccountInfo,
              child: Text('Lưu Thông Tin'),
            ),
          ],
        ),
      ),
    );
  }
}
