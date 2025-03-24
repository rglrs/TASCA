import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final int id;
  final String username;
  final String email;
  final String? name;
  final String? phone;
  final String? picture;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    this.name,
    this.phone,
    this.picture,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      picture: json['picture'],
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controllers for text fields
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  String? originalUsername;
  String? originalName;
  String? originalPhone;
  String? originalPicture;

  bool isLoading = true;
  bool isEdited = false;
  File? _selectedImage;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      print('Token for profile request: $token');

      if (token.isEmpty) {
        setState(() {
          isLoading = false;
        });
        _showErrorDialog('Token tidak ditemukan. Silakan login kembali.');
        return;
      }

      final response = await http.get(
        Uri.parse('https://api.tascaid.com/api/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          usernameController.text = data['username'] ?? '';
          emailController.text = data['email'] ?? '';
          nameController.text = data['name'] ?? '';
          phoneController.text = data['phone'] ?? '';

          originalUsername = data['username'];
          originalName = data['name'];
          originalPhone = data['phone'];
          originalPicture = data['picture'];

          profileImageUrl = data['picture'];

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showErrorDialog('Failed to load profile data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Network error: $e');
    }
  }

  Future<void> updateProfile() async {
    try {
      setState(() {
        isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      if (token.isEmpty) {
        setState(() {
          isLoading = false;
        });
        _showErrorDialog('Token tidak ditemukan. Silakan login kembali.');
        return;
      }

      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse('https://api.tascaid.com/api/profile/update'),
      );

      request.headers.addAll({'Authorization': 'Bearer $token'});

      if (usernameController.text != originalUsername) {
        request.fields['username'] = usernameController.text;
      }

      if (nameController.text != originalName) {
        request.fields['name'] = nameController.text;
      }

      if (phoneController.text != originalPhone) {
        request.fields['phone'] = phoneController.text;
      }

      if (_selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('picture', _selectedImage!.path),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );

        setState(() {
          originalUsername = usernameController.text;
          originalName = nameController.text;
          originalPhone = phoneController.text;

          if (responseData['picture'] != null) {
            originalPicture = responseData['picture'];
            profileImageUrl = responseData['picture'];
          }

          isEdited = false;
        });
      } else {
        final errorData = json.decode(response.body);
        _showErrorDialog(errorData['error'] ?? 'Failed to update profile');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Error updating profile: $e');
    }
  }

  void resetForm() {
    setState(() {
      usernameController.text = originalUsername ?? '';
      nameController.text = originalName ?? '';
      phoneController.text = originalPhone ?? '';
      _selectedImage = null;
      isEdited = false;
    });
  }

  void checkIfEdited() {
    setState(() {
      isEdited =
          usernameController.text != originalUsername ||
          nameController.text != originalName ||
          phoneController.text != originalPhone ||
          _selectedImage != null;
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        isEdited = true;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child:
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        // Avatar and Edit button
                        Center(
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.grey.withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                  // Profile picture or placeholder
                                  _selectedImage != null
                                      ? ClipOval(
                                        child: Image.file(
                                          _selectedImage!,
                                          width: 72,
                                          height: 72,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                      : profileImageUrl != null
                                      ? ClipOval(
                                        child: Image.network(
                                          profileImageUrl!,
                                          width: 72,
                                          height: 72,
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Container(
                                              width: 60,
                                              height: 60,
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.mood,
                                                color: Colors.white,
                                                size: 38,
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                      : Container(
                                        width: 60,
                                        height: 60,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.mood,
                                          color: Colors.white,
                                          size: 38,
                                        ),
                                      ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              TextButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(
                                  Icons.edit,
                                  size: 14,
                                  color: Colors.black54,
                                ),
                                label: const Text(
                                  'Edit',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  minimumSize: Size.zero,
                                  padding: EdgeInsets.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Profile Information Card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                _buildProfileField(
                                  label: 'Username',
                                  controller: usernameController,
                                  editable: true,
                                  onChanged: (_) => checkIfEdited(),
                                ),
                                const SizedBox(height: 16),
                                _buildProfileField(
                                  label: 'Email',
                                  controller: emailController,
                                  editable: false,
                                ),
                                const SizedBox(height: 16),
                                _buildProfileField(
                                  label: 'Phone Number',
                                  controller: phoneController,
                                  editable: true,
                                  onChanged: (_) => checkIfEdited(),
                                ),
                                const SizedBox(height: 16),
                                _buildProfileField(
                                  label: 'Fullname',
                                  controller: nameController,
                                  editable: true,
                                  onChanged: (_) => checkIfEdited(),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Buttons Row
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isEdited ? resetForm : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  disabledBackgroundColor: Colors.white
                                      .withOpacity(0.7),
                                  disabledForegroundColor: Colors.grey
                                      .withOpacity(0.5),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  side: BorderSide(
                                    color: Colors.grey.withOpacity(0.2),
                                  ),
                                ),
                                child: const Text('Reset'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isEdited ? updateProfile : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8B7DFA),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: const Color(
                                    0xFF8B7DFA,
                                  ).withOpacity(0.5),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Save'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    bool editable = false,
    Function(String)? onChanged,
  }) {
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
            // Tambahkan background berbeda untuk yang tidak bisa diedit
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
                    enabled:
                        editable, // Tambahkan ini agar benar-benar tidak bisa diklik
                    onChanged: onChanged,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(
                      fontSize: 15,
                      // Warna teks berbeda untuk yang tidak bisa diedit
                      color: editable ? Colors.black : Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
              if (editable)
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Icon(
                    Icons.edit,
                    size: 18,
                    color: Colors.grey.shade400,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
