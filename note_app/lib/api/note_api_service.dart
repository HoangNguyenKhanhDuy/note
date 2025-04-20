import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:note_app/models/note.dart';

class NoteAPIService {
  static const String _baseUrl = 'https://6804641479cb28fb3f5ae6e7.mockapi.io/api/v1/notes';

  // Lấy tất cả ghi chú từ API
  Future<List<Note>> getNotes() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        print('📥 Dữ liệu nhận được từ API: ${response.body}');
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((note) => Note.fromMap(note)).toList();
      } else {
        throw Exception('🚫 Không thể tải ghi chú. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('❗ Lỗi kết nối: $e');
    }
  }

  // Cập nhật trạng thái hoàn thành của ghi chú
  Future<void> updateNoteCompletion(String noteId, bool isCompleted) async {
    try {
      final url = Uri.parse('$_baseUrl/$noteId');
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'isCompleted': isCompleted}),
      );

      if (response.statusCode == 200) {
        print('✅ Ghi chú đã được cập nhật trạng thái hoàn thành.');
      } else {
        print('❌ Không thể cập nhật. Mã lỗi: ${response.statusCode}');
        throw Exception('Failed to update note completion');
      }
    } catch (e) {
      throw Exception('❗ Lỗi khi cập nhật trạng thái ghi chú: $e');
    }
  }

  // Thêm mới ghi chú
  Future<Note> addNote(Note note) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(note.toMap()),
      );

      if (response.statusCode == 201) {
        return Note.fromMap(json.decode(response.body));
      } else {
        throw Exception('🚫 Không thể thêm ghi chú. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('❗ Lỗi khi thêm ghi chú: $e');
    }
  }

  // Cập nhật ghi chú
  Future<Note> updateNote(Note note) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/${note.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(note.toMap()),
      );

      if (response.statusCode == 200) {
        return Note.fromMap(json.decode(response.body));
      } else {
        throw Exception('🚫 Không thể cập nhật ghi chú. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('❗ Lỗi khi cập nhật ghi chú: $e');
    }
  }

  // Xóa ghi chú
  Future<void> deleteNote(String noteId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$noteId'),
      );

      if (response.statusCode == 200) {
        print("🗑️ Đã xóa ghi chú thành công.");
      } else {
        throw Exception('🚫 Không thể xóa ghi chú. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('❗ Lỗi khi xóa ghi chú: $e');
    }
  }
}
