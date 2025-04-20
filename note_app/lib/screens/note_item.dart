import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:note_app/models/note.dart';

class NoteItem extends StatelessWidget {
  final Note note;
  final Function(bool?)? onCompletedChanged;

  NoteItem({required this.note, required this.onCompletedChanged});

  // Format thời gian cho dễ đọc
  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // TODO: Navigate to NoteDetail or Edit screen
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox cho trạng thái hoàn thành
              Checkbox(
                value: note.isCompleted,
                onChanged: onCompletedChanged,
              ),
              const SizedBox(width: 16),

              // Icon ưu tiên
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: note.priority == 1
                      ? Colors.green.shade100
                      : note.priority == 2
                      ? Colors.orange.shade100
                      : Colors.red.shade100,
                ),
                child: Icon(
                  note.priority == 1
                      ? Icons.low_priority
                      : note.priority == 2
                      ? Icons.priority_high
                      : Icons.star,
                  color: note.priority == 1
                      ? Colors.green
                      : note.priority == 2
                      ? Colors.orange
                      : Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Nội dung chính
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề
                    Text(
                      note.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Nội dung
                    Text(
                      note.content,
                      style: TextStyle(color: Colors.grey[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 10),

                    // Ngày tạo
                    Text(
                      'Tạo lúc: ${formatDate(note.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
