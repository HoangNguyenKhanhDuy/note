import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/note.dart';

class NoteBackupService {
  /// Lấy đường dẫn tới file sao lưu
  static Future<String> _getBackupFilePath() async {
    // Đường dẫn tùy chỉnh trên Windows
    String customPath = 'C:\\LuuNote\\backup_notes.json';

    // Kiểm tra xem thư mục có tồn tại không, nếu không thì tạo mới
    final directory = Directory('C:\\LuuNote');
    if (!(await directory.exists())) {
      await directory.create(recursive: true); // Tạo thư mục nếu chưa có
    }

    return customPath;
  }

  /// Sao lưu ghi chú vào file JSON (lọc theo userId)
  static Future<void> backupNotes(BuildContext context, List<Note> notes) async {
    try {
      final filePath = await _getBackupFilePath();
      final file = File(filePath);

      // Chuyển tất cả các ghi chú thành JSON mà không lọc theo userId
      final notesJson = jsonEncode(notes.map((note) => note.toJson()).toList());

      // Kiểm tra và in ra nội dung JSON để debug
      print("Nội dung JSON: $notesJson");

      // Ghi dữ liệu vào file
      await file.writeAsString(notesJson);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("📂 Đã sao lưu ${notes.length} ghi chú thành công!")),
      );
    } catch (e) {
      print("Lỗi sao lưu: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Đã xảy ra lỗi khi sao lưu!")),
      );
    }
  }

  /// Khôi phục ghi chú từ file JSON (trả về tất cả, lọc ở ngoài nếu muốn)
  static Future<List<Note>> restoreNotes(BuildContext context) async {
    try {
      final filePath = await _getBackupFilePath();
      final file = File(filePath);

      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> notesJson = jsonDecode(contents);

        final List<Note> restoredNotes = notesJson
            .map((e) => Note.fromJson(e as Map<String, dynamic>))
            .toList();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("🔄 Đã khôi phục ghi chú thành công!")),
        );

        return restoredNotes;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Không tìm thấy file sao lưu.")),
        );
        return [];
      }
    } catch (e) {
      print("Lỗi khôi phục: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Đã xảy ra lỗi khi khôi phục!")),
      );
      return [];
    }
  }
}
