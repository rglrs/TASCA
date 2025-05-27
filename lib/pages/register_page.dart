import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tasca_mobile1/pages/login_page.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tasca_mobile1/pages/sliding_pages.dart'; // Perbaikan nama file import

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Tidak dapat membuka $url')));
    }
  }

  // Show error message in SnackBar
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
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
    if (usernameController.text.trim().isEmpty) {
      setState(() {
        usernameError = 'Username tidak boleh kosong';
      });
      isValid = false;
    } else if (!RegExp(
      r'^[A-Za-z0-9 ]{4,}$',
    ).hasMatch(usernameController.text)) {
      setState(() {
        usernameError =
            'Username harus minimal 4 karakter dan hanya mengandung huruf dan angka';
      });
      isValid = false;
    }

    // Email validation
    if (emailController.text.isEmpty) {
      setState(() {
        emailError = 'Email tidak boleh kosong';
      });
      isValid = false;
    } else if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(emailController.text)) {
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
    } else if (!RegExp(r'[A-Z]').hasMatch(passwordController.text)) {
      setState(() {
        passwordError = 'Password harus mengandung huruf kapital';
      });
      isValid = false;
    } else if (!RegExp(r'[a-z]').hasMatch(passwordController.text)) {
      setState(() {
        passwordError = 'Password harus mengandung huruf kecil';
      });
      isValid = false;
    } else if (!RegExp(r'[0-9]').hasMatch(passwordController.text)) {
      setState(() {
        passwordError = 'Password harus mengandung angka';
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

  // Detects common "already exists" patterns in error messages
  bool _containsExistsPattern(String text) {
    final lowerText = text.toLowerCase();
    return lowerText.contains('sudah diambil') ||
        lowerText.contains('sudah ada') ||
        lowerText.contains('already') ||
        lowerText.contains('taken') ||
        lowerText.contains('exists') ||
        lowerText.contains('duplicate');
  }

  // Process error from server response
  void _processErrorField(
    Map<String, dynamic> errors,
    String field,
    void Function(String?) setError,
    String? existsMessage,
  ) {
    if (errors.containsKey(field)) {
      var fieldErrors = errors[field];
      String errorMsg;

      if (fieldErrors is List) {
        errorMsg = fieldErrors.isNotEmpty ? fieldErrors[0].toString() : '';

        // Check for common "already exists" patterns in list items
        for (var error in fieldErrors) {
          if (_containsExistsPattern(error.toString())) {
            setError(existsMessage);
            return;
          }
        }
      } else {
        errorMsg = fieldErrors.toString();

        // Check string directly for "already exists" patterns
        if (_containsExistsPattern(errorMsg)) {
          setError(existsMessage);
          return;
        }
      }

      setError(errorMsg);
    }
  }

  // Improved error handling for server validation
  void _handleServerValidationErrors(Map<String, dynamic> errors) {
    print('Processing server validation errors: $errors');

    setState(() {
      // Handle each field with the common pattern
      _processErrorField(
        errors,
        'username',
        (val) => usernameError = val,
        'Username sudah terdaftar, silakan gunakan username lain',
      );

      _processErrorField(
        errors,
        'email',
        (val) => emailError = val,
        'Email sudah terdaftar, silakan gunakan email lain',
      );

      _processErrorField(errors, 'name', (val) => nameError = val, null);

      _processErrorField(errors, 'phone', (val) => phoneError = val, null);

      _processErrorField(
        errors,
        'password',
        (val) => passwordError = val,
        null,
      );

      _processErrorField(
        errors,
        'confirm_password',
        (val) => confirmPasswordError = val,
        null,
      );
    });

    // Log final error states for debugging
    print('Final error states - Username: $usernameError, Email: $emailError');
  }

  // Process registration response
  void _processRegistrationResponse(http.Response response) {
    final int statusCode = response.statusCode;
    final String rawResponse = response.body;

    print('Response status: $statusCode');
    print('Raw response body: $rawResponse');

    if (statusCode == 201) {
      // Success handled in calling method
      return;
    }

    // Handle direct SQL error case first
    if (rawResponse.contains("idx_users_email") ||
        (rawResponse.contains("duplicate key") &&
            rawResponse.contains("email"))) {
      setState(() {
        emailError = 'Email sudah terdaftar, silakan gunakan email lain';
      });
      return;
    }

    if (rawResponse.contains("idx_users_username") ||
        (rawResponse.contains("duplicate key") &&
            rawResponse.contains("username"))) {
      setState(() {
        usernameError =
            'Username sudah terdaftar, silakan gunakan username lain';
      });
      return;
    }

    // Try to parse as JSON
    try {
      final Map<String, dynamic> errorResponse = jsonDecode(response.body);
      print('Full error response: $errorResponse');

      // Check for specific error messages in the top-level response
      if (errorResponse.containsKey('message')) {
        String message = errorResponse['message'].toString().toLowerCase();

        if (message.contains('username') && _containsExistsPattern(message)) {
          setState(() {
            usernameError =
                'Username sudah terdaftar, silakan gunakan username lain';
          });
          return;
        }

        if (message.contains('email') && _containsExistsPattern(message)) {
          setState(() {
            emailError = 'Email sudah terdaftar, silakan gunakan email lain';
          });
          return;
        }
      }

      // Continue with structured error handling
      if (errorResponse.containsKey('errors')) {
        _handleServerValidationErrors(errorResponse['errors']);
      } else if (errorResponse.containsKey('message') &&
          errorResponse.containsKey('errors')) {
        _handleServerValidationErrors(errorResponse['errors']);
      } else if (errorResponse.containsKey('error')) {
        final errorMap = errorResponse['error'];
        if (errorMap is Map) {
          Map<String, dynamic> errors = {};
          errorMap.forEach((key, value) {
            errors[key] = [value];
          });
          _handleServerValidationErrors(errors);
        } else {
          // No specific dialog here since we'll show a SnackBar in the calling method
          print('Error from server: ${errorMap.toString()}');
        }
      } else if (errorResponse.containsKey('message')) {
        // No specific dialog here since we'll show a SnackBar in the calling method
        print('Error message from server: ${errorResponse['message']}');
      }
    } catch (e) {
      print('Error parsing response: $e');

      // If JSON parsing fails, check raw string once more
      String responseBody = response.body.toLowerCase();

      if (responseBody.contains("email") &&
          _containsExistsPattern(responseBody)) {
        setState(() {
          emailError = 'Email sudah terdaftar, silakan gunakan email lain';
        });
      } else if (responseBody.contains("username") &&
          _containsExistsPattern(responseBody)) {
        setState(() {
          usernameError =
              'Username sudah terdaftar, silakan gunakan username lain';
        });
      }
    }
  }

  Future<void> _register(BuildContext context) async {
    if (!_isCheckboxChecked) {
      _showErrorMessage('Anda harus menyetujui syarat dan ketentuan');
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

    // Process phone number - send null if empty
    String? phone;
    if (phoneRaw.isNotEmpty) {
      phone =
          phoneRaw.startsWith('+62') ? '0${phoneRaw.substring(3)}' : phoneRaw;
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

      if (response.statusCode == 201) {
        // Success
        _showDialog(
          context,
          'Registrasi Berhasil',
          'Akun Anda telah berhasil didaftarkan. Silakan masuk.',
        );
      } else {
        // Handle errors
        _processRegistrationResponse(response);
        _showErrorMessage(
          'Registrasi gagal: Periksa kembali data yang dimasukkan.',
        );
      }
    } on SocketException catch (_) {
      _showDialog(
        context,
        'Kesalahan Koneksi',
        'Gagal terhubung ke server. Silakan periksa koneksi internet Anda.',
      );
      _showErrorMessage('Kesalahan Koneksi: Periksa koneksi internet Anda.');
    } catch (e) {
      print('Exception during registration: $e');
      _showDialog(
        context,
        'Kesalahan Koneksi',
        'Gagal terhubung ke server. Silakan periksa koneksi internet Anda.',
      );
      _showErrorMessage('Terjadi kesalahan: Silakan coba lagi nanti.');
    } finally {
      setState(() => _isLoading = false);
    }
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
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Build form field with common styling
  Widget _buildFormField({
    required String label,
    required String placeholder,
    required TextEditingController controller,
    String? errorText,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    InputBorder? border,
  }) {
    final hasError = errorText != null;

    final defaultBorder = OutlineInputBorder(
      borderRadius:
          border != null
              ? (border as OutlineInputBorder).borderRadius
              : BorderRadius.circular(8),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius:
          border != null
              ? (border as OutlineInputBorder).borderRadius
              : BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.red),
    );

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
          obscureText: isPassword && !_isPasswordVisible,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: placeholder,
            border: border ?? defaultBorder,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            errorText: errorText,
            errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
            errorMaxLines: 5,
            enabledBorder: hasError ? errorBorder : null,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
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
                        // Navigasi yang benar ke SlicingScreen dengan initialPage 3
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SlicingScreen(initialPage: 3),
                          ),
                          (route) => false,
                        );
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
                        _buildFormField(
                          label: 'Nama Lengkap*',
                          placeholder: 'Masukkan nama lengkap',
                          controller: nameController,
                          errorText: nameError,
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          label: 'Username*',
                          placeholder: 'Masukkan username min. 4 karakter',
                          controller: usernameController,
                          errorText: usernameError,
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          label: 'Email*',
                          placeholder: 'alexantos@gmail.com',
                          controller: emailController,
                          errorText: emailError,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        // WhatsApp field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Nomor WhatsApp',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 12,
                                          ),
                                      enabledBorder:
                                          phoneError != null
                                              ? const OutlineInputBorder(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(8),
                                                  bottomLeft: Radius.circular(
                                                    8,
                                                  ),
                                                ),
                                                borderSide: BorderSide(
                                                  color: Colors.red,
                                                ),
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 16,
                                          ),
                                      errorText: phoneError,
                                      errorStyle: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                      errorMaxLines: 5,
                                      enabledBorder:
                                          phoneError != null
                                              ? const OutlineInputBorder(
                                                borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(8),
                                                  bottomRight: Radius.circular(
                                                    8,
                                                  ),
                                                ),
                                                borderSide: BorderSide(
                                                  color: Colors.red,
                                                ),
                                              )
                                              : null,
                                    ),
                                    keyboardType: TextInputType.phone,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          label: 'Password*',
                          placeholder: 'Password minimum 8 karakter',
                          controller: passwordController,
                          errorText: passwordError,
                          isPassword: true,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          label: 'Konfirmasi Password*',
                          placeholder: 'Harus sama dengan password di atas',
                          controller: confirmPasswordController,
                          errorText: confirmPasswordError,
                          isPassword: true,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
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
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Saya Menyetujui '),
                                    TextSpan(
                                      text: 'Kebijakan Privasi',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                      ),
                                      recognizer:
                                          TapGestureRecognizer()
                                            ..onTap = () {
                                              _launchURL(
                                                'https://tascaid.com/privacypolicy',
                                              );
                                            },
                                    ),
                                    const TextSpan(text: ' serta '),
                                    TextSpan(
                                      text: 'Kondisi dan Ketentuan',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                      ),
                                      recognizer:
                                          TapGestureRecognizer()
                                            ..onTap = () {
                                              _launchURL(
                                                'https://tascaid.com/terms',
                                              );
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
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                _isLoading ? null : () => _register(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child:
                                _isLoading
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                    : const Text(
                                      'Daftar',
                                      style: TextStyle(color: Colors.white),
                                    ),
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
}