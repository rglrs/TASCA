import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:developer' as developer;

import '../widgets/profile_settings/profile_image_widget.dart';
import '../widgets/profile_settings/profile_field_widget.dart';
import '../widgets/profile_settings/profile_buttons_widget.dart';

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

  // function fetch user profile
  Future<void> fetchUserProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

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

          if (data['picture'] != null &&
              data['picture'] is String &&
              data['picture'].isNotEmpty) {
            if (data['picture'].startsWith('http')) {
              profileImageUrl = data['picture'];
            } else {
              profileImageUrl =
                  'https://api.tascaid.com/storage/${data['picture']}';

              if (data['picture'].startsWith('/')) {
                profileImageUrl = 'https://api.tascaid.com${data['picture']}';
              } else {
                profileImageUrl =
                    'https://api.tascaid.com/storage/upload/${data['picture']}';
              }
            }
          } else {
            profileImageUrl = null;
            developer.log('No profile picture found in data');
          }

          originalPicture = profileImageUrl;
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

  // function update profile
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
        int fileSizeInBytes = await _selectedImage!.length();
        double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

        if (fileSizeInMB > 3) {
          setState(() {
            isLoading = false;
          });
          _showErrorDialog(
            'Ukuran file tidak boleh lebih dari 3MB. Ukuran file Anda: ${fileSizeInMB.toStringAsFixed(2)} MB',
          );
          return;
        }

        String extension = _selectedImage!.path.split('.').last.toLowerCase();
        final allowedExtensions = [
          'jpg',
          'jpeg',
          'png',
          'heic',
          'webp',
          'bmp',
          'tiff',
        ];

        if (!allowedExtensions.contains(extension)) {
          setState(() {
            isLoading = false;
          });
          _showErrorDialog(
            'Format file tidak didukung. Gunakan format: ${allowedExtensions.join(", ")}',
          );
          return;
        }

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
            String pictureUrl = responseData['picture'];
            if (pictureUrl.startsWith('http')) {
              profileImageUrl = pictureUrl;
            } else {
              profileImageUrl = 'https://api.tascaid.com/storage/$pictureUrl';
            }
            originalPicture = profileImageUrl;
          }

          isEdited = false;
        });
      } else {
        final errorData = json.decode(response.body);
        _showErrorDialog(
          errorData['error'] ??
              'Gagal memperbarui profil. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Error updating profile: $e');
    }
  }

  // function untuk button reset form
  void resetForm() {
    setState(() {
      usernameController.text = originalUsername ?? '';
      nameController.text = originalName ?? '';
      phoneController.text = originalPhone ?? '';
      _selectedImage = null;
      isEdited = false;
    });
  }

  // function untuk check form diedit
  void checkIfEdited() {
    setState(() {
      isEdited =
          usernameController.text != originalUsername ||
          nameController.text != originalName ||
          phoneController.text != originalPhone ||
          _selectedImage != null;
    });
  }

  // function untuk memilih image
  Future<void> _pickImage() async {
    try {
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Pilih Sumber Foto',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B7DFA).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Color(0xFF8B7DFA),
                    ),
                  ),
                  title: const Text('Kamera'),
                  subtitle: const Text('Ambil foto baru dengan kamera'),
                  onTap: () {
                    Navigator.of(context).pop(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B7DFA).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_library,
                      color: Color(0xFF8B7DFA),
                    ),
                  ),
                  title: const Text('Galeri'),
                  subtitle: const Text('Pilih foto dari galeri'),
                  onTap: () {
                    Navigator.of(context).pop(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      );

      if (source == null) {
        return;
      }

      setState(() {
        isLoading = true;
      });

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
        preferredCameraDevice:
            source == ImageSource.camera
                ? CameraDevice.front
                : CameraDevice.rear,
      );

      setState(() {
        isLoading = false;
      });

      if (image == null) {
        return;
      }

      await Future.delayed(const Duration(milliseconds: 500));

      try {
        CroppedFile? croppedFile = await _safeCropImage(image.path);

        if (croppedFile != null) {
          File file = File(croppedFile.path);

          await _validateImageFile(file);

          setState(() {
            _selectedImage = file;
            isEdited = true;
          });
        }
      } catch (cropError) {
        _showErrorDialog('Gagal memproses gambar: ${cropError.toString()}');
      }
    } on PlatformException catch (e) {
      setState(() {
        isLoading = false;
      });

      if (e.code == 'photo_access_denied') {
        _showErrorDialog(
          'Akses galeri ditolak. Silakan izinkan akses foto di pengaturan.',
        );
      } else if (e.code == 'camera_access_denied') {
        _showErrorDialog(
          'Akses kamera ditolak. Silakan izinkan akses kamera di pengaturan.',
        );
      } else {
        _showErrorDialog('Gagal memilih gambar: ${e.message}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Gagal memilih gambar: ${e.toString()}');
    }
  }

  // function untuk crop image
  Future<CroppedFile?> _safeCropImage(String imagePath) async {
    try {
      return await ImageCropper().cropImage(
        sourcePath: imagePath,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Foto Profil',
            toolbarColor: const Color(0xFF8B7DFA),
            toolbarWidgetColor: Colors.white,
            backgroundColor: Colors.black,
            activeControlsWidgetColor: const Color(0xFF8B7DFA),
            lockAspectRatio: false,
            showCropGrid: true,
            initAspectRatio: CropAspectRatioPreset.square,
            hideBottomControls: false,
            cropFrameStrokeWidth: 2,
            cropGridStrokeWidth: 1,
            cropFrameColor: Colors.white,
            cropGridColor: Colors.white54,
            statusBarColor: Colors.transparent,
          ),
          IOSUiSettings(
            title: 'Crop Foto Profil',
            doneButtonTitle: 'Selesai',
            cancelButtonTitle: 'Batal',
            aspectRatioLockEnabled: true,
            rotateButtonsHidden: false,
            resetButtonHidden: false,
            aspectRatioPickerButtonHidden: true,
          ),
        ],
        compressQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
    } catch (e) {
      throw Exception('Gagal melakukan crop gambar: $e');
    }
  }

  Future<void> _validateImageFile(File file) async {
    int fileSizeInBytes = await file.length();
    double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

    if (fileSizeInMB > 3) {
      throw Exception(
        'Ukuran file tidak boleh lebih dari 3MB. Ukuran file Anda: ${fileSizeInMB.toStringAsFixed(2)} MB',
      );
    }

    String extension = file.path.split('.').last.toLowerCase();
    final allowedExtensions = [
      'jpg',
      'jpeg',
      'png',
      'heic',
      'webp',
      'bmp',
      'tiff',
    ];

    if (!allowedExtensions.contains(extension)) {
      throw Exception(
        'Format file tidak didukung. Gunakan format: ${allowedExtensions.join(", ")}',
      );
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

  // function untuk menampilkan foto profile
  void _showFullScreenImage() {
    final imageToShow = _selectedImage ?? profileImageUrl;

    if (imageToShow == null) {
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withOpacity(0.8),
                  child:
                      _selectedImage != null
                          ? Image.file(_selectedImage!, fit: BoxFit.contain)
                          : Image.network(
                            profileImageUrl!,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              developer.log(
                                'Error loading image: $error',
                              ); // Debug log
                              return const Center(
                                child: Text(
                                  'Gagal memuat gambar',
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            },
                          ),
                ),
              ),

              // Tombol tutup
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
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
          onPressed: () {
            Navigator.of(context).pop(true);
          },
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
                  : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Avatar and Edit button
                        ProfileImageWidget(
                          selectedImage: _selectedImage,
                          profileImageUrl: profileImageUrl,
                          onTap: _showFullScreenImage,
                          onEditTap: _pickImage,
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
                                ProfileFieldWidget(
                                  label: 'Username',
                                  controller: usernameController,
                                  editable: true,
                                  onChanged: (_) => checkIfEdited(),
                                ),
                                const SizedBox(height: 16),
                                ProfileFieldWidget(
                                  label: 'Email',
                                  controller: emailController,
                                  editable: false,
                                ),
                                const SizedBox(height: 16),
                                ProfileFieldWidget(
                                  label: 'Phone Number',
                                  controller: phoneController,
                                  editable: true,
                                  onChanged: (_) => checkIfEdited(),
                                ),
                                const SizedBox(height: 16),
                                ProfileFieldWidget(
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
                        ProfileButtonsWidget(
                          isEdited: isEdited,
                          onReset: resetForm,
                          onSave: updateProfile,
                        ),

                        const SizedBox(height: 20), // Extra bottom padding
                      ],
                    ),
                  ),
        ),
      ),
    );
  }
}
