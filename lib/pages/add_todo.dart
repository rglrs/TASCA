import 'package:flutter/material.dart';

class AddTodoPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onTodoAdded;

  const AddTodoPage({super.key, required this.onTodoAdded});

  @override
  _AddTodoPageState createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  final TextEditingController _titleController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _selectedUrgency;
  String? _selectedImportance;

  void _addTodo() {
    if (_formKey.currentState!.validate()) {
      final task = {
        'title': _titleController.text.trim(),
        'urgency': _selectedUrgency,
        'importance': _selectedImportance,
      };
      widget.onTodoAdded(task);
      Navigator.of(context).pop(); // Tutup halaman setelah berhasil
    }
  }

  @override
  Widget build(BuildContext context) {
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
              SizedBox(height: 20),
              Text(
                'Prioritize',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Urgency',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
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
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Importance',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
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
                      });
                    },
                  ),
                  _PriorityChip(
                    label: 'Not important',
                    isSelected: _selectedImportance == 'Not important',
                    onSelected: () {
                      setState(() {
                        _selectedImportance ==
                                'Not important'
                            ? _selectedImportance = null
                            : _selectedImportance = 'Not important';
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addTodo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Add Task'),
              ),
              SizedBox(height: 20),
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
    super.key,
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
