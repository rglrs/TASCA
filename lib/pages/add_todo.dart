import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tasca_mobile1/widgets/add_todo/add_todo_coach_mark.dart';

class AddTodoPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onTodoAdded;

  const AddTodoPage({super.key, required this.onTodoAdded});

  @override
  _AddTodoPageState createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  final TextEditingController _titleController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Global keys untuk coach mark
  final GlobalKey _titleInputKey = GlobalKey();
  final GlobalKey _priorityColorKey = GlobalKey();
  final GlobalKey _prioritySelectionKey = GlobalKey();
  final GlobalKey _addTaskButtonKey = GlobalKey();

  // Coach mark manager
  AddTodoCoachMark? _coachMark;

  String? _selectedUrgency;
  String? _selectedImportance;
  
  // Tambahkan state untuk validation error
  bool _showValidationError = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi coach mark setelah build pertama selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initCoachMark();
    });
  }

  // Inisialisasi coach mark
  void _initCoachMark() {
    _coachMark = AddTodoCoachMark(
      context: context,
      titleInputKey: _titleInputKey,
      priorityColorKey: _priorityColorKey,
      prioritySelectionKey: _prioritySelectionKey,
      addTaskButtonKey: _addTaskButtonKey,
    );

    _coachMark?.showCoachMarkIfNeeded();
  }

  // Method untuk menampilkan coach mark saat tombol bantuan diklik
  void _showCoachMark() {
    if (_coachMark != null) {
      AddTodoCoachMark.resetCoachMarkStatus().then((_) {
        _coachMark!.showCoachMark();
      });
    }
  }

  // Fungsi untuk mendapatkan warna berdasarkan prioritas
  String _getColorBasedOnPriority() {
    if (_selectedUrgency == 'Urgently' && _selectedImportance == 'Important') {
      return "#FC0101"; // Merah
    } else if ((_selectedUrgency == 'Urgently' && _selectedImportance == 'Not important') ||
               (_selectedUrgency == 'Not urgently' && _selectedImportance == 'Important')) {
      return "#FFC107"; // Kuning
    } else if (_selectedUrgency == 'Not urgently' && _selectedImportance == 'Not important') {
      return "#28A745"; // Hijau
    } else {
      return "#808080"; // Abu-abu (default jika tidak memilih)
    }
  }

  // Fungsi untuk mendapatkan object Color dari string hex
  Color _getColorFromHex(String hexColor) {
    switch (hexColor) {
      case "#FC0101":
        return Colors.red;
      case "#FFC107":
        return Colors.amber;
      case "#28A745":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _addTodo() {
    if (_formKey.currentState!.validate()) {
      if (_selectedUrgency == null || _selectedImportance == null) {
        // Tampilkan error dalam form alih-alih SnackBar
        setState(() {
          _showValidationError = true;
        });
        return;
      }
      
      // Reset error state jika validasi berhasil
      setState(() {
        _showValidationError = false;
      });
      
      final task = {
        'title': _titleController.text.trim(),
        'urgency': _selectedUrgency,
        'importance': _selectedImportance,
        'color': _getColorBasedOnPriority(),
      };
      widget.onTodoAdded(task);
    }
  }

  // Fungsi untuk mendapatkan deskripsi prioritas
  String _getPriorityDescription() {
    if (_selectedUrgency == 'Urgently' && _selectedImportance == 'Important') {
      return "High Priority (Red)";
    } else if ((_selectedUrgency == 'Urgently' && _selectedImportance == 'Not important') ||
               (_selectedUrgency == 'Not urgently' && _selectedImportance == 'Important')) {
      return "Medium Priority (Yellow)";
    } else if (_selectedUrgency == 'Not urgently' && _selectedImportance == 'Not important') {
      return "Low Priority (Green)";
    } else {
      return "No Priority (Grey)";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mendapatkan warna saat ini berdasarkan prioritas
    String currentColor = _getColorBasedOnPriority();
    Color displayColor = _getColorFromHex(currentColor);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: _titleInputKey,
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'To Do title...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Preview warna berdasarkan prioritas
              Row(
                key: _priorityColorKey,
                children: [
                  Text(
                    'Priority Color: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: displayColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _getPriorityDescription(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              Text(
                'Prioritize',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _showValidationError ? Colors.red : Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 10),
              Column(
                key: _prioritySelectionKey,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Urgency',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _selectedUrgency == null && _showValidationError ? Colors.red : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _PriorityChip(
                        label: 'Urgently',
                        isSelected: _selectedUrgency == 'Urgently',
                        onSelected: () {
                          setState(() {
                            _selectedUrgency = _selectedUrgency == 'Urgently'
                                ? null
                                : 'Urgently';
                            // Reset validation error saat pilihan diubah
                            if (_selectedImportance != null && _selectedUrgency != null) {
                              _showValidationError = false;
                            }
                          });
                        },
                      ),
                      _PriorityChip(
                        label: 'Not urgently',
                        isSelected: _selectedUrgency == 'Not urgently',
                        onSelected: () {
                          setState(() {
                            _selectedUrgency = _selectedUrgency == 'Not urgently'
                                ? null
                                : 'Not urgently';
                            // Reset validation error saat pilihan diubah
                            if (_selectedImportance != null && _selectedUrgency != null) {
                              _showValidationError = false;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Importance',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _selectedImportance == null && _showValidationError ? Colors.red : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _PriorityChip(
                        label: 'Important',
                        isSelected: _selectedImportance == 'Important',
                        onSelected: () {
                          setState(() {
                            _selectedImportance =
                                _selectedImportance == 'Important'
                                    ? null
                                    : 'Important';
                            // Reset validation error saat pilihan diubah
                            if (_selectedImportance != null && _selectedUrgency != null) {
                              _showValidationError = false;
                            }
                          });
                        },
                      ),
                      _PriorityChip(
                        label: 'Not important',
                        isSelected: _selectedImportance == 'Not important',
                        onSelected: () {
                          setState(() {
                            _selectedImportance =
                                _selectedImportance == 'Not important'
                                    ? null
                                    : 'Not important';
                            // Reset validation error saat pilihan diubah
                            if (_selectedImportance != null && _selectedUrgency != null) {
                              _showValidationError = false;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  
                  // Pesan error untuk prioritas
                  if (_showValidationError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Please select both urgency and importance',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                key: _addTaskButtonKey,
                onPressed: _addTodo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Add Todo'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _PriorityChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: Colors.deepPurple.shade100,
      backgroundColor: Colors.grey.shade200,
      labelStyle: TextStyle(
        color: isSelected ? Colors.deepPurple : Colors.black54,
      ),
    );
  }
}