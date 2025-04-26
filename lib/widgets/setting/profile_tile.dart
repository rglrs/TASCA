import 'package:flutter/material.dart';

class ProfileTile extends StatelessWidget {
  final dynamic userProfile;
  final VoidCallback onTap;

  const ProfileTile({
    Key? key,
    this.userProfile,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textColor = Colors.black87;
    final subtitleColor = Colors.grey.shade600;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red.withOpacity(0.2),
          child:
              userProfile?.picture == null || userProfile!.picture.isEmpty
                  ? const Icon(Icons.person, color: Colors.red)
                  : ClipOval(
                      child: Image.network(
                        userProfile!.picture,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.person, color: Colors.red);
                        },
                      ),
                    ),
        ),
        title: Text(
          userProfile?.name ?? '',
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        subtitle: Text(
          userProfile?.email ?? '',
          style: TextStyle(color: subtitleColor),
        ),
        trailing: Icon(Icons.chevron_right, color: subtitleColor),
        onTap: onTap,
      ),
    );
  }
}