import 'package:flutter/material.dart';

class AddTodoPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onTaskAdded;

  const AddTodoPage({Key? key, required this.onTaskAdded}) : super(key: key);

  @override
  _AddTodoPageState createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  final TextEditingController _titleController = TextEditingController();
  String? _selectedUrgency;
  String? _selectedImportance;

  void _addTask() {
    if (_titleController.text.isNotEmpty) {
      final task = {
        'title': _titleController.text,
        'urgency': _selectedUrgency,
        'importance': _selectedImportance,
      };
      widget.onTaskAdded(task);
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'To Do title...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
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
              _PriorityChip(
                label: 'Important',
                isSelected: _selectedImportance == 'Important',
                onSelected: () {
                  setState(() {
                    _selectedImportance = _selectedImportance == 'Important' 
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
                    _selectedImportance = _selectedImportance == 'Not important' 
                      ? null 
                      : 'Not important';
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _addTask,
            child: Text('Add Task'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _PriorityChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  }) : super(key: key);

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