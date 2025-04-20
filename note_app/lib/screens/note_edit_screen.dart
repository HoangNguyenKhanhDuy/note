import 'package:flutter/material.dart';
import 'package:note_app/models/note.dart';
import 'package:note_app/api/note_api_service.dart';

class NoteEditScreen extends StatefulWidget {
  final Note? noteToEdit; // Có thể là null nếu là tạo mới

  NoteEditScreen({this.noteToEdit});

  @override
  _NoteEditScreenState createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _priorityController = TextEditingController();
  final _tagsController = TextEditingController();
  final _colorController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Nếu là chỉnh sửa, load dữ liệu ghi chú vào các controller
    if (widget.noteToEdit != null) {
      _titleController.text = widget.noteToEdit!.title;
      _contentController.text = widget.noteToEdit!.content;
      _priorityController.text = widget.noteToEdit!.priority.toString();
      _tagsController.text = widget.noteToEdit!.tags.join(', ');
      _colorController.text = widget.noteToEdit!.color;
    }
  }

  // Lưu ghi chú
  Future<void> saveNote() async {
    final newNote = Note(
      id: widget.noteToEdit?.id ?? '',  // Nếu là tạo mới, id sẽ tự tạo, nếu là chỉnh sửa, giữ lại id cũ
      userId: 'someUserId', // Đảm bảo bạn cung cấp userId hợp lệ
      title: _titleController.text,
      content: _contentController.text,
      priority: _priorityController.text.trim(), // priority là kiểu int, sử dụng giá trị số
      createdAt: widget.noteToEdit?.createdAt ?? DateTime.now(),  // Giữ nguyên kiểu DateTime
      modifiedAt: DateTime.now(),  // Giữ nguyên kiểu DateTime
      tags: _tagsController.text.split(',').map((tag) => tag.trim()).toList(),
      color: _colorController.text.isEmpty ? Colors.white.value.toString() : _colorController.text,  // Lưu màu dưới dạng String (hex)
    );

    // Tiến hành lưu hoặc gửi request API
    try {
      if (widget.noteToEdit == null) {
        // Nếu là tạo mới, gọi API thêm ghi chú
        await NoteAPIService().addNote(newNote);
      } else {
        // Nếu là chỉnh sửa, gọi API chỉnh sửa ghi chú
        await NoteAPIService().updateNote(newNote);
      }

      // Quay lại màn hình danh sách ghi chú sau khi lưu
      Navigator.pop(context, true); // Trả về true để thông báo danh sách ghi chú cần reload
    } catch (e) {
      // Xử lý lỗi nếu có
      print('Lỗi khi lưu ghi chú: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Lỗi khi lưu ghi chú!'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.noteToEdit == null ? 'Thêm Ghi Chú' : 'Chỉnh Sửa Ghi Chú',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,  // Màu nền AppBar
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: saveNote,  // Lưu khi nhấn nút save
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_titleController, 'Tiêu đề', Icons.title),
              SizedBox(height: 16.0),
              _buildTextField(_contentController, 'Nội dung', Icons.text_fields, maxLines: null),
              SizedBox(height: 16.0),
              _buildTextField(_priorityController, 'Mức độ ưu tiên', Icons.priority_high, keyboardType: TextInputType.number),
              SizedBox(height: 16.0),
              _buildTextField(_tagsController, 'Tags (cách nhau bởi dấu phẩy)', Icons.tag),
              SizedBox(height: 16.0),
              _buildTextField(_colorController, 'Màu sắc (mã màu hex)', Icons.color_lens),
            ],
          ),
        ),
      ),
    );
  }

  // Widget giúp tạo TextField với icon, decoration đẹp mắt
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int? maxLines, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.teal),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.teal, width: 2),
        ),
      ),
      maxLines: maxLines ?? 1,
      keyboardType: keyboardType ?? TextInputType.text,
    );
  }
}
