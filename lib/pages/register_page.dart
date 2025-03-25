import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tasca_mobile1/pages/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool _isPasswordVisible = false;
  bool _isCheckboxChecked = false;
  bool _isLoading = false;

  Future<void> _register(BuildContext context) async {
    if (!_isCheckboxChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus menyetujui syarat dan ketentuan'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final String username = usernameController.text;
    final String name = nameController.text;
    final String email = emailController.text;
    final String phoneRaw = phoneController.text.trim();
    final String password = passwordController.text;
    final String confirmPassword = confirmPasswordController.text;

    // Validasi input
    if (username.length < 4) {
      _showError('Username harus minimal 4 karakter');
      return;
    }

    if (password.length < 8) {
      _showError('Password harus minimal 8 karakter');
      return;
    }

    if (password != confirmPassword) {
      _showError('Passwords tidak cocok');
      return;
    }

    // Proses nomor telepon - kirim null jika kosong
    String? phone;
    if (phoneRaw.isNotEmpty) {
      phone = _processPhoneNumber(phoneRaw);
    }

    try {
      final response = await http.post(
        Uri.parse('https://api.tascaid.com/api/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'username': username,
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'confirm_password': confirmPassword,
        }),
      );

      // Debug response
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        // Custom success message
        _showDialog(
          context,
          'Registrasi Berhasil',
          'Akun Anda telah berhasil didaftarkan. Silakan masuk.',
        );
      } else {
        // Custom error message
        _showDialog(
          context,
          'Registrasi Gagal',
          'Terjadi kesalahan saat mendaftarkan akun. Silakan coba lagi.',
        );
      }
    } catch (e) {
      _showDialog(
        context,
        'Kesalahan Koneksi',
        'Gagal terhubung ke server. Silakan periksa koneksi internet Anda.',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                if (title == 'Registrasi Berhasil') {
                  Navigator.of(
                    context,
                  ).pop(LoginPage()); // Kembali ke halaman login
                }
              },
            ),
          ],
        );
      },
    );
  }

  String _processPhoneNumber(String phoneNumber) {
    if (phoneNumber.startsWith('+62')) {
      return '0${phoneNumber.substring(3)}';
    }
    return phoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E8FF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(Icons.arrow_back, size: 24),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ternyata akun kamu belum terdaftar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Masuk di sini',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildTextField(
                          'Nama Lengkap*',
                          'Masukkan nama lengkap',
                          nameController,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          'Username*',
                          'Masukkan username min. 4 karakter',
                          usernameController,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          'Email*',
                          'alexantos@gmail.com',
                          emailController,
                        ),
                        const SizedBox(height: 16),
                        _buildWhatsAppField(),
                        const SizedBox(height: 16),
                        _buildPasswordField(
                          'Password*',
                          'Password minimum 8 karakter',
                          passwordController,
                        ),
                        const SizedBox(height: 16),
                        _buildPasswordField(
                          'Konfirmasi Password*',
                          'Harus sama dengan password di atas',
                          confirmPasswordController,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Checkbox(
                              value: _isCheckboxChecked,
                              onChanged: (value) {
                                setState(() {
                                  _isCheckboxChecked = value!;
                                });
                              },
                            ),
                            const Expanded(
                              child: Text(
                                'Saya Menyetujui Kebijakan Privasi serta Kondisi dan Ketentuan oleh Tim Tasca',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed:
                              _isLoading ? null : () => _register(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 130,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child:
                              _isLoading
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : const Text(
                                    'Daftar',
                                    style: TextStyle(color: Colors.white),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String placeholder,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: placeholder,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWhatsAppField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nomor WhatsApp',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 60,
              child: TextField(
                decoration: InputDecoration(
                  hintText: '+62',
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                ),
                readOnly: true,
              ),
            ),
            Expanded(
              child: TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  hintText: '8xx xxxx xxxx',
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    String label,
    String placeholder,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            hintText: placeholder,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
