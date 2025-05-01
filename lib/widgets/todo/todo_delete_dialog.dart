import 'package:flutter/material.dart';

class TodoDeleteDialog extends StatelessWidget {
  final bool isSingleTodo;
  final int? count;
  final VoidCallback onDelete;

  const TodoDeleteDialog({
    Key? key,
    required this.isSingleTodo,
    this.count,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Hapus Todo'),
      content: Text(
        isSingleTodo
            ? 'Apakah Anda yakin ingin menghapus todo ini?'
            : 'Apakah Anda yakin ingin menghapus $count todo yang dipilih?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: onDelete,
          child: const Text(
            'Hapus',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}