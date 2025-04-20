import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:note_app/models/account.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountAPIService {
  static const String _baseUrl = 'https://6804641479cb28fb3f5ae6e7.mockapi.io/api/v1/accounts';

  // Đăng nhập
  Future<Account> login(String username, String password) async {
    final response = await http.get(
      Uri.parse('$_baseUrl?username=$username'),
    );

    if (response.statusCode == 200) {
      try {
        List jsonResponse = json.decode(response.body);

        // Kiểm tra nếu danh sách không trống
        if (jsonResponse.isNotEmpty) {
          var accountData = jsonResponse[0];

          // Kiểm tra mật khẩu
          if (accountData['password'] == password) {
            // Kiểm tra trạng thái tài khoản (status)
            if (accountData['status'] == false) {
              throw Exception('Tài khoản bị khóa');
            }

            // Lưu thông tin đăng nhập vào SharedPreferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('savedUsername', username);
            await prefs.setString('savedPassword', password);
            await prefs.setString('userId', accountData['id']); // Lưu userId

            return Account.fromMap(accountData);
          } else {
            throw Exception('Mật khẩu không đúng');
          }
        } else {
          throw Exception('Tài khoản không tồn tại');
        }
      } catch (e) {
        throw Exception('Lỗi khi xử lý dữ liệu đăng nhập: $e');
      }
    } else {
      throw Exception('Lỗi khi kết nối đến API: ${response.statusCode}');
    }
  }

  // Đăng ký
  Future<Account> register(String username, String password) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'username': username,
        'password': password,
        'status': true, // Tài khoản mới sẽ có status = true
        'lastLogin': DateTime.now().toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
        'id': DateTime.now().millisecondsSinceEpoch.toString(), // ID tự động tạo
      }),
    );

    if (response.statusCode == 201) {
      // Tạo tài khoản thành công, trả về tài khoản mới
      var accountData = json.decode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('savedUsername', username);
      await prefs.setString('savedPassword', password);
      await prefs.setString('userId', accountData['id']); // Lưu userId

      return Account.fromMap(accountData);
    } else {
      throw Exception('Lỗi khi tạo tài khoản: ${response.statusCode}');
    }
  }

  // Đăng xuất
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('savedUsername');
    await prefs.remove('savedPassword');
    await prefs.remove('userId');
    print("Đăng xuất thành công");
  }

  // Lấy tất cả tài khoản (dùng để kiểm tra)
  Future<List<Account>> getAllAccounts() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((account) => Account.fromMap(account)).toList();
      } else {
        throw Exception('Không thể tải danh sách tài khoản. Lỗi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi kết nối API để lấy danh sách tài khoản: $e');
    }
  }
}
