import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  final String? avatarUrl;
  final double radius;
  final String defaultAvatarUrl;
  final BoxBorder? border;

  const AvatarWidget({
    Key? key,
    this.avatarUrl,
    this.radius = 20,
    this.defaultAvatarUrl = 'https://i0.wp.com/sbcf.fr/wp-content/uploads/2018/03/sbcf-default-avatar.png?ssl=1',
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: border,
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[200],
        child: _buildAvatarContent(),
      ),
    );
  }

  Widget _buildAvatarContent() {
    if (avatarUrl == null || avatarUrl!.isEmpty) {
      // Nếu không có URL, dùng asset mặc định
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(defaultAvatarUrl),
      );
    }

    // Nếu có URL, thử load từ network
    return CircleAvatar(
      radius: radius,
      backgroundImage: NetworkImage(avatarUrl!),
      onBackgroundImageError: (exception, stackTrace) {
        print('Error loading avatar: $exception');
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(defaultAvatarUrl),
            onError: (exception, stackTrace) {
              print('Error loading default avatar: $exception');
            },
          ),
        ),
      ),
    );
  }
} 