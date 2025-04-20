import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_app/screens/note_list_screen.dart';
import 'package:note_app/screens/login_screen.dart';
import 'package:note_app/screens/note_detail_screen.dart';
import 'package:note_app/screens/note_edit_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(NoteApp());
}

// ✅ Đưa hàm check login ra ngoài
Future<bool> checkLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('userId');
  return userId != null;
}

class NoteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note App',
      debugShowCheckedModeBanner: false, // Tắt debug banner
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
      ),
      // 👇 Home là màn hình quyết định: đăng nhập hay danh sách ghi chú
      home: FutureBuilder<bool>(
        future: checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Lỗi: ${snapshot.error}')),
            );
          } else if (snapshot.data == true) {
            return NoteListScreen(); // Đã đăng nhập
          } else {
            return LoginScreen(); // Chưa đăng nhập
          }
        },
      ),
      routes: {
        '/noteDetail': (context) => NoteDetailScreen(),
        '/noteEdit': (context) => NoteEditScreen(),
        '/noteList': (context) => NoteListScreen(),
        '/login': (context) => LoginScreen(),
      },
    );
  }
}
