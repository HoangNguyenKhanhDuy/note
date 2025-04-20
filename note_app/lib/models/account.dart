class Account {
  final String id;
  final String username;
  final String password;
  final bool status; // Cập nhật loại dữ liệu status thành bool
  final String lastLogin; // Thêm thuộc tính lastLogin
  final String createdAt; // Thêm thuộc tính createdAt

  Account({
    required this.id,
    required this.username,
    required this.password,
    required this.status,
    required this.lastLogin,
    required this.createdAt,
  });

  // Hàm chuyển đổi từ Map (JSON) thành đối tượng Account
  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] ?? '', // Nếu không có id, trả về chuỗi rỗng
      username: map['username'] ?? '', // Nếu không có username, trả về chuỗi rỗng
      password: map['password'] ?? '', // Nếu không có password, trả về chuỗi rỗng
      status: map['status'] ?? false, // Nếu không có status, mặc định là false
      lastLogin: map['lastLogin'] ?? '', // Nếu không có lastLogin, trả về chuỗi rỗng
      createdAt: map['createdAt'] ?? '', // Nếu không có createdAt, trả về chuỗi rỗng
    );
  }

  // Chuyển đối tượng Account thành Map để gửi đi (trong trường hợp đăng ký)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'status': status,
      'lastLogin': lastLogin,
      'createdAt': createdAt,
    };
  }
}
