import 'package:flutter/material.dart';
import 'package:note_app/models/note.dart';
import 'package:note_app/api/note_api_service.dart';
import 'note_edit_screen.dart';

class NoteDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Lấy đối tượng Note từ arguments
    final Note note = ModalRoute.of(context)!.settings.arguments as Note;

    // Hàm xóa ghi chú
    Future<void> _deleteNote() async {
      try {
        // Gọi API để xóa ghi chú
        await NoteAPIService().deleteNote(note.id);

        // Quay lại màn hình danh sách ghi chú sau khi xóa
        Navigator.pop(context);
      } catch (e) {
        print('Lỗi khi xóa ghi chú: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa ghi chú')),
        );
      }
    }

    // Hàm sửa ghi chú
    void _editNote() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NoteEditScreen(noteToEdit: note),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Chi Tiết Ghi Chú"),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _editNote,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Xóa ghi chú'),
                  content: Text('Bạn có chắc chắn muốn xóa ghi chú này không?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () {
                        _deleteNote();
                        Navigator.pop(context);
                      },
                      child: Text('Xóa'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề Ghi Chú
              Card(
                margin: EdgeInsets.only(bottom: 12),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    note.title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ),
              // Nội dung Ghi Chú
              Card(
                margin: EdgeInsets.only(bottom: 12),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    note.content,
                    style: TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ),
              // Mức độ ưu tiên
              Card(
                margin: EdgeInsets.only(bottom: 12),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.priority_high, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        'Mức độ ưu tiên: ${note.priority}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Ngày tạo và ngày sửa
              Card(
                margin: EdgeInsets.only(bottom: 12),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ngày tạo: ${note.createdAt}',
                        style: TextStyle(fontSize: 14, color: Colors.blueGrey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Ngày sửa: ${note.modifiedAt}',
                        style: TextStyle(fontSize: 14, color: Colors.blueGrey),
                      ),
                    ],
                  ),
                ),
              ),
              // Tags
              Card(
                margin: EdgeInsets.only(bottom: 12),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Tags: ${note.tags.join(', ')}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
              // Màu sắc
              Card(
                margin: EdgeInsets.only(bottom: 12),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Màu sắc: ${note.color}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.purple,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
