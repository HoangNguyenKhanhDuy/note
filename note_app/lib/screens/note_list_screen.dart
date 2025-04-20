import 'package:flutter/material.dart';
import 'package:note_app/api/note_api_service.dart';
import 'package:note_app/models/note.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'note_edit_screen.dart';
import 'edit_account_screen.dart';
import 'package:share_plus/share_plus.dart'; // Import thư viện chia sẻ
import 'package:note_app/api/note_backup_service.dart';

class NoteListScreen extends StatefulWidget {
  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  bool _isGrid = false;
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  bool _isLoading = false;
  String? _userId;
  String? _username;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initUserAndLoadNotes();
    _searchController.addListener(_filterNotes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _shareNote(Note note) async {
    final String noteContent = '${note.title}\n\n${note.content}';
    // Chia sẻ tiêu đề và nội dung ghi chú
    await Share.share(noteContent);
  }

  Future<void> _initUserAndLoadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? username = prefs.getString('username');

    if (userId == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      return;
    }

    setState(() {
      _userId = userId;
      _username = username;
    });

    if (username != null) {
      Future.delayed(Duration(milliseconds: 500), () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Chào mừng quay lại, $username!'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      });
    }

    await _loadNotes(userId);
  }

  Future<void> _loadNotes(String userId) async {
    setState(() => _isLoading = true);
    try {
      List<Note> allNotes = await NoteAPIService().getNotes();
      setState(() {
        _notes = allNotes;
        _filteredNotes = allNotes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải ghi chú: $e')),
      );
    }
  }

  void _filterNotes() {
    String keyword = _searchController.text.toLowerCase();
    setState(() {
      _filteredNotes = _notes.where((note) {
        return note.title.toLowerCase().contains(keyword) ||
            note.content.toLowerCase().contains(keyword);
      }).toList();
    });
  }

  Future<void> _reloadNotes() async {
    setState(() {
      _isLoading = true;
    });
    await _loadNotes(_userId!);
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Future<void> _confirmDeleteNote(String noteId) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('❗Xác nhận xoá'),
        content: Text('Bạn có chắc chắn muốn xoá ghi chú này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Xoá', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteNote(noteId);
    }
  }

  Future<void> _backupNotes() async {
    try {
      // Lưu tất cả các ghi chú mà không phân biệt userId
      await NoteBackupService.backupNotes(context, _notes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Đã sao lưu ghi chú thành công!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Lỗi khi sao lưu: $e')),
      );
    }
  }

  Future<void> _restoreNotes() async {
    try {
      List<Note> restored = await NoteBackupService.restoreNotes(context);

      setState(() {
        // Cập nhật lại danh sách ghi chú từ dữ liệu khôi phục
        _notes = restored;  // Thay thế toàn bộ danh sách ghi chú bằng danh sách đã khôi phục
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🔁 Đã khôi phục ghi chú thành công!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Lỗi khi khôi phục: $e')),
      );
    }
  }
  Future<void> _deleteNote(String noteId) async {
    try {
      await NoteAPIService().deleteNote(noteId);
      _reloadNotes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi xóa ghi chú")),
      );
    }
  }

  Widget _buildNoteItem(Note note) {
    return ListTile(
      leading: Checkbox(
        value: note.isCompleted,
        onChanged: (value) async {
          setState(() {
            note.isCompleted = value!;
          });
          // Gửi request cập nhật trạng thái isCompleted lên server
          await NoteAPIService().updateNoteCompletion(note.id ?? '', value!);
        },
      ),
      title: Text(
        note.title,
        style: TextStyle(
          decoration: note.isCompleted ? TextDecoration.lineThrough : null,
          color: note.isCompleted ? Colors.grey : null,
        ),
      ),
      subtitle: Text(note.content),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => _shareNote(note), // Gọi hàm chia sẻ khi nhấn
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmDeleteNote(note.id ?? ''), // Gọi hàm xác nhận xóa khi nhấn
          ),
        ],
      ),
    );
  }


  Widget _buildUserAvatar() {
    return FutureBuilder<String?>(  // Mỗi lần cần load lại avatar của người dùng
      future: _getAvatarUrl(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircleAvatar(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, color: Colors.white),
            ),
            onSelected: _handleAvatarMenu,
            itemBuilder: _buildAvatarMenu,
          );
        }

        return PopupMenuButton<String>(
          icon: CircleAvatar(
            backgroundImage: NetworkImage(snapshot.data!),
          ),
          onSelected: _handleAvatarMenu,
          itemBuilder: _buildAvatarMenu,
        );
      },
    );
  }

  List<PopupMenuEntry<String>> _buildAvatarMenu(BuildContext context) {
    return [
      PopupMenuItem(
        value: 'profile',
        child: Text('Sửa Avatar'),
      ),
      PopupMenuItem(
        value: 'logout',
        child: Text('Đăng xuất'),
      ),
    ];
  }

  void _handleAvatarMenu(String value) {
    if (value == 'logout') {
      _logout();
    } else if (value == 'profile') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EditAccountScreen()),
      );
    }
  }

  Future<String?> _getAvatarUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('avatarUrl');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _username != null ? '👋 Xin chào, $_username!' : 'Ghi chú của bạn',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.backup),
            onPressed: _backupNotes, // Sao lưu khi nhấn nút
            tooltip: 'Sao lưu ghi chú',
          ),
          IconButton(
            icon: Icon(Icons.restore),
            onPressed: _restoreNotes, // Khôi phục khi nhấn nút
            tooltip: 'Khôi phục ghi chú',
          ),
          IconButton(icon: Icon(Icons.refresh), onPressed: _reloadNotes),
          IconButton(
            icon: Icon(_isGrid ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGrid = !_isGrid;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/noteEdit');
            },
          ),
          _buildUserAvatar(),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber.shade100, Colors.lightBlue.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '🔍 Tìm kiếm ghi chú...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _filteredNotes.isEmpty
                  ? Center(child: Text("📭 Không có ghi chú nào."))
                  : _isGrid
                  ? GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 12),
                gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.2,
                ),
                itemCount: _filteredNotes.length,
                itemBuilder: (context, index) {
                  final note = _filteredNotes[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/noteDetail',
                        arguments: note,
                      );
                    },
                    child: Card(
                      color: note.getColor().withOpacity(0.8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8),
                            Expanded(
                              child: Text(
                                note.content,
                                style: TextStyle(fontSize: 14),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: IconButton(
                                icon: Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () =>
                                    _deleteNote(note.id ?? ''),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.share),
                              onPressed: () => _shareNote(note),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
                  : ListView.builder(
                itemCount: _filteredNotes.length,
                itemBuilder: (context, index) {
                  final note = _filteredNotes[index];
                  return Card(
                    color: note.getColor().withOpacity(0.8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text(
                        note.title,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        note.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/noteDetail',
                          arguments: note,
                        );
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.share),
                            onPressed: () => _shareNote(note),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete,
                                color: Colors.red),
                            onPressed: () =>
                                _confirmDeleteNote(note.id ?? ''),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent, // Để áp dụng gradient trong footer
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.amber, Colors.lightBlue],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Người sáng tạo: Hoàng Nguyễn Khánh Duy',
                  style: TextStyle(
                    color: Colors.white, // Text màu trắng cho dễ đọc
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}