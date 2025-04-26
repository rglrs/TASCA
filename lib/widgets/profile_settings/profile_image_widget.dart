import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:developer' as developer;

class ProfileImageWidget extends StatelessWidget {
  final File? selectedImage;
  final String? profileImageUrl;
  final VoidCallback onTap;
  final VoidCallback onEditTap;

  const ProfileImageWidget({
    Key? key,
    this.selectedImage,
    this.profileImageUrl,
    required this.onTap,
    required this.onEditTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              if (selectedImage != null ||
                  (profileImageUrl != null && profileImageUrl!.isNotEmpty)) {
                onTap();
              }
            },
            child: Stack(
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
                selectedImage != null
                    ? ClipOval(
                        child: Image.file(
                          selectedImage!,
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
                                developer.log(
                                  'Error loading avatar: $error',
                                );
                                return Container(
                                  width: 60,
                                  height: 60,
                                  decoration: const BoxDecoration(
                                    color: Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 38,
                                  ),
                                );
                              },
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                            ),
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 38,
                            ),
                          ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          TextButton.icon(
            onPressed: onEditTap,
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
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}