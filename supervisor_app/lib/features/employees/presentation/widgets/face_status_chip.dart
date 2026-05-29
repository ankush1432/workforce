import 'package:flutter/material.dart';
import 'package:supervisor_app/features/employees/domain/face_registration_status.dart';

class FaceStatusChip extends StatelessWidget {
  const FaceStatusChip({
    super.key,
    required this.status,
    this.compact = false,
  });

  final FaceRegistrationStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (Color bg, Color fg, IconData icon) = switch (status) {
      FaceRegistrationStatus.registered => (
          theme.colorScheme.primaryContainer,
          theme.colorScheme.onPrimaryContainer,
          Icons.verified_rounded,
        ),
      FaceRegistrationStatus.pendingSync => (
          theme.colorScheme.tertiaryContainer,
          theme.colorScheme.onTertiaryContainer,
          Icons.cloud_sync_outlined,
        ),
      FaceRegistrationStatus.notRegistered => (
          theme.colorScheme.errorContainer.withValues(alpha: 0.85),
          theme.colorScheme.onErrorContainer,
          Icons.face_retouching_natural_outlined,
        ),
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 14 : 16, color: fg),
          SizedBox(width: compact ? 4 : 6),
          Text(
            status.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
              fontSize: compact ? 11 : 12,
            ),
          ),
        ],
      ),
    );
  }
}
