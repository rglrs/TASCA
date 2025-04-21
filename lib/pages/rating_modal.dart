import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class RatingModal extends StatefulWidget {
  final String username;

  const RatingModal({super.key, required this.username});

  @override
  _RatingModalState createState() => _RatingModalState();
}

class _RatingModalState extends State<RatingModal> {
  int _selectedRating = 0;
  bool _canSubmit = false;

  void _showThankYouModal() {
    developer.log('Showing thank you modal', name: 'RatingModal');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Terima Kasih',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Terima kasih sudah memberikan rating',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B7DFA),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Tutup'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveRating() async {
    developer.log(
      'Saving rating: $_selectedRating for username: ${widget.username}',
      name: 'RatingModal',
    );
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('hasRated_${widget.username}', true);
    await prefs.setInt('userRating_${widget.username}', _selectedRating);

    _showThankYouModal();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Berikan Rating', textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Bagaimana pengalaman Anda menggunakan aplikasi ini?',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _selectedRating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 40,
                ),
                onPressed: () {
                  setState(() {
                    _selectedRating = index + 1;
                    _canSubmit = true;
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _canSubmit ? _saveRating : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B7DFA),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
            ),
            child: const Text('Kirim Rating'),
          ),
        ],
      ),
    );
  }
}

extension RatingModalExtension on BuildContext {
  Future<void> showRatingModal({required String username}) async {
    final prefs = await SharedPreferences.getInstance();
    final hasRated = prefs.getBool('hasRated_$username') ?? false;

    developer.log(
      'Has username $username rated: $hasRated',
      name: 'RatingModal',
    );

    if (!hasRated) {
      await showDialog(
        context: this,
        builder: (context) => RatingModal(username: username),
      );
    } else {
      developer.log(
        'Username $username already rated, skipping modal',
        name: 'RatingModal',
      );
    }
  }
}
