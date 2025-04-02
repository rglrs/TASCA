import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tasca_mobile1/pages/login_page.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

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
  
  // Error text states
  String? usernameError;
  String? nameError;
  String? emailError;
  String? phoneError;
  String? passwordError;
  String? confirmPasswordError;
  
  bool _isPasswordVisible = false;
  bool _isCheckboxChecked = false;
  bool _isLoading = false;

  // Clear all form errors
  void _clearErrors() {
    setState(() {
      usernameError = null;
      nameError = null;
      emailError = null;
      phoneError = null;
      passwordError = null;
      confirmPasswordError = null;
    });
  }

  // Launch URL function
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak dapat membuka $url')),
      );
    }
  }

  // Validate the form
  bool _validateForm() {
    bool isValid = true;
    _clearErrors();
    
    // Name validation
    if (nameController.text.isEmpty) {
      setState(() {
        nameError = 'Nama lengkap tidak boleh kosong';
      });
      isValid = false;
    }
    
    // Username validation
    if (usernameController.text.isEmpty) {
      setState(() {
        usernameError = 'Username tidak boleh kosong';
      });
      isValid = false;
    } else if (usernameController.text.length < 4) {
      setState(() {
        usernameError = 'Username harus minimal 4 karakter';
      });
      isValid = false;
    } else if (!RegExp(r'^[a-zA-Z]+$').hasMatch(usernameController.text)) {
      setState(() {
        usernameError = 'Username hanya boleh mengandung huruf';
      });
      isValid = false;
    }
    
    // Email validation
    if (emailController.text.isEmpty) {
      setState(() {
        emailError = 'Email tidak boleh kosong';
      });
      isValid = false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailController.text)) {
      setState(() {
        emailError = 'Format email tidak valid';
      });
      isValid = false;
    }
    
    // Password validation
    if (passwordController.text.isEmpty) {
      setState(() {
        passwordError = 'Password tidak boleh kosong';
      });
      isValid = false;
    } else if (passwordController.text.length < 8) {
      setState(() {
        passwordError = 'Password harus minimal 8 karakter';
      });
      isValid = false;
    }
    
    // Confirm password validation
    if (confirmPasswordController.text.isEmpty) {
      setState(() {
        confirmPasswordError = 'Konfirmasi password tidak boleh kosong';
      });
      isValid = false;
    } else if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        confirmPasswordError = 'Password tidak cocok';
      });
      isValid = false;
    }
    
    return isValid;
  }

  Future<void> _register(BuildContext context) async {
    if (!_isCheckboxChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus menyetujui syarat dan ketentuan'),
        ),
      );
      return;
    }
    
    // Validate form before proceeding
    if (!_validateForm()) {
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
    if (!_isValidUsername(username)) {
      _showError(
        'Username harus minimal 4 huruf dan tidak boleh mengandung spasi atau simbol',
      );
      return;
    }

    if (!_isValidPassword(password)) {
      _showError(
        'Password harus minimal 8 karakter dan terdiri dari huruf kecil, huruf besar, dan angka',
      );
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
      
      // Tambahkan log raw response
      String rawResponse = response.body;
      print('Raw response body: $rawResponse');

      if (response.statusCode == 201) {
        // Custom success message
        _showDialog(
          context,
          'Registrasi Berhasil',
          'Akun Anda telah berhasil didaftarkan. Silakan masuk.',
        );
      } else {
        // Cek dulu untuk pesan SQL error langsung
        if (rawResponse.contains("idx_users_email") || 
            rawResponse.contains("duplicate key") && rawResponse.contains("email")) {
          setState(() {
            emailError = 'Email sudah terdaftar, silakan gunakan email lain';
          });
        } else if (rawResponse.contains("idx_users_username") || 
                  (rawResponse.contains("duplicate key") && rawResponse.contains("username"))) {
          setState(() {
            usernameError = 'Username sudah terdaftar, silakan gunakan username lain';
          });
        } else {
          // Jika bukan error SQL langsung, coba parse sebagai JSON
          try {
            final Map<String, dynamic> errorResponse = jsonDecode(response.body);
            
            // Log the full error response untuk debugging
            print('Full error response: $errorResponse');
            
            // Check for specific error messages in the top-level response
            if (errorResponse.containsKey('message')) {
              String message = errorResponse['message'].toString().toLowerCase();
              
              // Check if the error message directly indicates username or email already exists
              if (message.contains('username') && 
                  (message.contains('sudah ada') || message.contains('exists') || 
                   message.contains('taken') || message.contains('duplicate'))) {
                setState(() {
                  usernameError = 'Username sudah terdaftar, silakan gunakan username lain';
                });
                return;
              }
              
              if (message.contains('email') && 
                  (message.contains('sudah ada') || message.contains('exists') || 
                   message.contains('taken') || message.contains('duplicate'))) {
                setState(() {
                  emailError = 'Email sudah terdaftar, silakan gunakan email lain';
                });
                return;
              }
            }
            
            // Continue with normal error handling
            if (errorResponse.containsKey('errors')) {
              _handleServerValidationErrors(errorResponse['errors']);
            } else if (errorResponse.containsKey('message') && errorResponse.containsKey('errors')) {
              _handleServerValidationErrors(errorResponse['errors']);
            } else if (errorResponse.containsKey('error')) {
              Map<String, dynamic> errors = {};
              final errorMap = errorResponse['error'];
              if (errorMap is Map) {
                errorMap.forEach((key, value) {
                  errors[key] = [value];
                });
                _handleServerValidationErrors(errors);
              } else {
                _showDialog(
                  context,
                  'Registrasi Gagal',
                  errorMap.toString(),
                );
              }
            } else if (errorResponse.containsKey('message')) {
              _showDialog(
                context,
                'Registrasi Gagal',
                errorResponse['message'],
              );
            } else {
              _showDialog(
                context,
                'Registrasi Gagal',
                'Terjadi kesalahan saat mendaftarkan akun. Silakan coba lagi.',
              );
            }
          } catch (e) {
            print('Error parsing response: $e');
            
            // Jika gagal parse JSON, periksa string mentah sekali lagi
            String responseBody = response.body.toLowerCase();
            if (responseBody.contains("email") && 
                (responseBody.contains("sudah") || responseBody.contains("duplicate") || 
                 responseBody.contains("exist") || responseBody.contains("taken"))) {
              setState(() {
                emailError = 'Email sudah terdaftar, silakan gunakan email lain';
              });
            } else if (responseBody.contains("username") && 
                      (responseBody.contains("sudah") || responseBody.contains("duplicate") || 
                       responseBody.contains("exist") || responseBody.contains("taken"))) {
              setState(() {
                usernameError = 'Username sudah terdaftar, silakan gunakan username lain';
              });
            } else {
              _showDialog(
                context,
                'Registrasi Gagal',
                'Terjadi kesalahan saat mendaftarkan akun. Silakan coba lagi.',
              );
            }
          }
        }
      }
    } on SocketException catch (_) {
      _showDialog(
        context,
        'Kesalahan Koneksi',
        'Gagal terhubung ke server. Silakan periksa koneksi internet Anda.',
      );
    } catch (e) {
      print('Exception during registration: $e');
      _showDialog(
        context,
        'Kesalahan Koneksi',
        'Gagal terhubung ke server. Silakan periksa koneksi internet Anda.',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _isValidUsername(String username) {
    final RegExp usernameRegExp = RegExp(r'^[a-zA-Z]{4,}$');
    return usernameRegExp.hasMatch(username);
  }

  bool _isValidPassword(String password) {
    final RegExp passwordRegExp = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$',
    );
    return passwordRegExp.hasMatch(password);
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
                    'Ternyata akun kamu sudah terdaftar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
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
                          errorText: nameError,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          'Username*',
                          'Masukkan username min. 4 huruf tanpa spasi atau simbol',
                          usernameController,
                          errorText: usernameError,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          'Email*',
                          'alexantos@gmail.com',
                          emailController,
                          errorText: emailError,
                        ),
                        const SizedBox(height: 16),
                        _buildWhatsAppField(),
                        const SizedBox(height: 16),
                        _buildPasswordField(
                          'Password*',
                          'Password minimal 8 karakter, terdiri dari huruf kecil, huruf besar, dan angka',
                          passwordController,
                          errorText: passwordError,
                        ),
                        const SizedBox(height: 16),
                        _buildPasswordField(
                          'Konfirmasi Password*',
                          'Harus sama dengan password di atas',
                          confirmPasswordController,
                          errorText: confirmPasswordError,
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
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(fontSize: 12, color: Colors.black),
                                  children: [
                                    const TextSpan(text: 'Saya Menyetujui '),
                                    TextSpan(
                                      text: 'Kebijakan Privasi',
                                      style: const TextStyle(color: Colors.blue),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          _launchURL('https://tascaid.site/privacypolicy');
                                        },
                                    ),
                                    const TextSpan(text: ' serta '),
                                    TextSpan(
                                      text: 'Kondisi dan Ketentuan',
                                      style: const TextStyle(color: Colors.blue),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          _launchURL('https://tascaid.site/terms');
                                        },
                                    ),
                                    const TextSpan(text: ' oleh Tim Tasca'),
                                  ],
                                ),
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
    {String? errorText}
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
            errorText: errorText,
            // Add red border if there's an error
            enabledBorder: errorText != null 
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red),
                  )
                : null,
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  // Update border color if phone error exists
                  enabledBorder: phoneError != null 
                      ? const OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                          borderSide: BorderSide(color: Colors.red),
                        )
                      : null,
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
                  errorText: phoneError,
                  errorStyle: const TextStyle(height: 0.5),
                  // Update border color if phone error exists
                  enabledBorder: phoneError != null 
                      ? const OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                          borderSide: BorderSide(color: Colors.red),
                        )
                      : null,
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
    {String? errorText}
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
            errorText: errorText,
            enabledBorder: errorText != null 
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}