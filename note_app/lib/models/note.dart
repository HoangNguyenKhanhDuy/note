import 'package:flutter/material.dart';

class Note {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String priority; // Kiểu String
  final DateTime createdAt;
  final DateTime modifiedAt;
  final List<String> tags;
  final String color;
  bool isCompleted;

  Note({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.priority,
    required this.createdAt,
    required this.modifiedAt,
    required this.tags,
    required this.color,
    this.isCompleted = true,
  });

  // Chuyển từ Map (dùng cho JSON hoặc DB) sang Note
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      content: map['content'],
      priority: map['priority'].toString(),
      createdAt: map['createdAt'] is int
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] * 1000)
          : DateTime.tryParse(map['createdAt']) ?? DateTime.now(),
      modifiedAt: map['modifiedAt'] is int
          ? DateTime.fromMillisecondsSinceEpoch(map['modifiedAt'] * 1000)
          : DateTime.tryParse(map['modifiedAt']) ?? DateTime.now(),
      tags: map['tags'] != null ? List<String>.from(map['tags']) : [],
      color: map['color'],
      isCompleted: map['isCompleted'] ?? true,
    );
  }

  // Chuyển Note thành Map (dùng cho JSON hoặc DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'priority': priority,
      'createdAt': createdAt.millisecondsSinceEpoch ~/ 1000,
      'modifiedAt': modifiedAt.millisecondsSinceEpoch ~/ 1000,
      'tags': tags,
      'color': color,
      'isCompleted': isCompleted,
    };
  }

  // Chuyển thành JSON (dùng jsonEncode)
  Map<String, dynamic> toJson() => toMap();

  // Tạo từ JSON (dùng jsonDecode)
  factory Note.fromJson(Map<String, dynamic> json) => Note.fromMap(json);

  // Đổi chuỗi màu thành đối tượng Color
  Color getColor() {
    try {
      return Color(int.parse(color.replaceAll('#', '0xFF')));
    } catch (e) {
      print('Lỗi chuyển đổi màu: $e');
      return Colors.black;
    }
  }
}
