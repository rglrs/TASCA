import 'package:flutter/material.dart';

class TodoSelectionFAB extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onPressed;

  const TodoSelectionFAB({
    Key? key,
    required this.selectedCount,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 90.0),
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: Colors.red,
        icon: const Icon(Icons.delete_outline, color: Colors.white),
        label: Text(
          'Hapus ($selectedCount)',
          style: const TextStyle(color: Colors.white),
        ),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}