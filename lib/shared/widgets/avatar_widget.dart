import 'package:flutter/material.dart';
import '../../core/theme/app_typography.dart';

/// Rounded avatar widget with fallback initials or placeholder icon.
class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    super.key,
    this.imageUrl,
    this.name,
    this.radius = 20.0,
    this.backgroundColor,
  });

  final String? imageUrl;
  final String? name;
  final double radius;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = backgroundColor ?? theme.colorScheme.primaryContainer;
    final fg = theme.colorScheme.onPrimaryContainer;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: bg,
        backgroundImage: NetworkImage(imageUrl!),
      );
    }

    String initials = '';
    if (name != null && name!.trim().isNotEmpty) {
      final parts = name!.trim().split(' ');
      if (parts.length > 1) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else {
        initials = parts[0][0].toUpperCase();
      }
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      child: initials.isNotEmpty
          ? Text(
              initials,
              style: AppTypography.labelMedium.copyWith(
                color: fg,
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.8,
              ),
            )
          : Icon(Icons.person, size: radius * 1.1, color: fg),
    );
  }
}
