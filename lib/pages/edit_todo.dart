import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditTodoScreen extends StatefulWidget {
  final Map<String, dynamic> todoToEdit;

  const EditTodoScreen({super.key, required this.todoToEdit});

  @override
  _EditTodoScreenState createState() => _EditTodoScreenState();
}

class _EditTodoScreenState extends State<EditTodoScreen> {
  late TextEditingController _titleController;
  String _selectedColor = "#FC0101"; // Default red

  // Color options
  final List<String> _colorOptions = [
    "#FC0101", // Red
    "#007BFF", // Blue
    "#FFC107", // Yellow
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the title controller with the existing todo title
    _titleController = TextEditingController(
      text: widget.todoToEdit['title'] ?? '',
    );

    // If the todo has a color, use it. Otherwise, keep the default
    if (widget.todoToEdit['color'] != null) {
      _selectedColor = widget.todoToEdit['color'];
    }
  }

  @override
  void dispose() {
    // Always dispose of controllers
    _titleController.dispose();
    super.dispose();
  }

  // Convert color string to Color widget
  Color _getColorFromString(String colorString) {
    switch (colorString) {
      case "#FC0101":
        return const Color(0xFFFC0101);
      case "#007BFF":
        return const Color(0xFF007BFF);
      case "#FFC107":
        return const Color(0xFFFFC107);
      default:
        return const Color(0xFF808080);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F1FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Edit Todo',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Input
            Text(
              'Title',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Enter todo title',
                hintStyle: GoogleFonts.poppins(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 16),

            // Color Selection
            Text(
              'Color',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _colorOptions.map((colorString) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = colorString;
                    });
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getColorFromString(colorString),
                      shape: BoxShape.circle,
                      border: _selectedColor == colorString
                          ? Border.all(color: Colors.black, width: 3)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const Spacer(),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Validate and return updated todo
                  if (_titleController.text.trim().isNotEmpty) {
                    // Create a new map with updated information
                    final updatedTodo = {
                      ...widget.todoToEdit,
                      'title': _titleController.text.trim(),
                      'color': _selectedColor,
                    };

                    // Return the updated todo back to the previous screen
                    Navigator.of(context).pop(updatedTodo);
                  } else {
                    // Show error if title is empty
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Please enter a title',
                          style: GoogleFonts.poppins(),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Save Changes',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}