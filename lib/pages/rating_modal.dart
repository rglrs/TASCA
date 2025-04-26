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
    // Mendapatkan lebar layar untuk menyesuaikan ukuran dialog
    final screenWidth = MediaQuery.of(context).size.width;
    final starSize = screenWidth < 360 ? 30.0 : 36.0; // Ukuran bintang yang responsif
    
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Berikan Rating',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Bagaimana pengalaman Anda menggunakan aplikasi ini?',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8.0,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRating = index + 1;
                        _canSubmit = true;
                      });
                    },
                    child: Icon(
                      index < _selectedRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: starSize,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canSubmit ? _saveRating : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B7DFA),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Kirim Rating'),
                ),
              ),
            ],
          ),
        ),
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
        barrierDismissible: false,
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