import 'package:flutter/material.dart';

class ProfileButtonsWidget extends StatelessWidget {
  final bool isEdited;
  final VoidCallback onReset;
  final VoidCallback onSave;

  const ProfileButtonsWidget({
    Key? key,
    required this.isEdited,
    required this.onReset,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: isEdited ? onReset : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              disabledBackgroundColor: Colors.white.withOpacity(0.7),
              disabledForegroundColor: Colors.grey.withOpacity(0.5),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: BorderSide(
                color: Colors.grey.withOpacity(0.2),
              ),
            ),
            child: const Text('Reset'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: isEdited ? onSave : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B7DFA),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFF8B7DFA).withOpacity(0.5),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Save'),
          ),
        ),
      ],
    );
  }
}