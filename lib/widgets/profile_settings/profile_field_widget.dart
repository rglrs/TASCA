import 'package:flutter/material.dart';

class ProfileFieldWidget extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool editable;
  final Function(String)? onChanged;

  const ProfileFieldWidget({
    Key? key,
    required this.label,
    required this.controller,
    this.editable = false,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
        ),
        const SizedBox(height: 6),
        Container(
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(8),
            color: editable ? Colors.white : Colors.grey.shade50,
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: TextField(
                    controller: controller,
                    readOnly: !editable,
                    enabled: editable,
                    onChanged: onChanged,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(
                      fontSize: 15,
                      color: editable ? Colors.black : Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
              if (editable)
                const Padding(padding: EdgeInsets.only(right: 12.0)),
            ],
          ),
        ),
      ],
    );
  }
}