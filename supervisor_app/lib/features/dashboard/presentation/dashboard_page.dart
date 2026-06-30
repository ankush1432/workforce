import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supervisor_app/shared/widgets/glass_card.dart';
import 'package:supervisor_app/l10n/app_localizations.dart';

import '../../attendance/presentation/employee_attendance_flow.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Row(
        children: [
          Image.asset("assets/images/app_logo.png",width: 35,height: 35,),
          SizedBox(width: 24,),
          Text(l10n.home),
        ],
      )),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.workforceAttendance,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),

          // ── Check In / Check Out primary actions ──────────────
          _CheckInOutButtons(ref: ref,),

          const SizedBox(height: 20),
          _QuickTile(
            icon: Icons.people_rounded,
            title: l10n.employees,
            subtitle: l10n.viewTeamRecordAttendance,
            onTap: () => context.go('/employees'),
          ),
          const SizedBox(height: 10),
          _QuickTile(
            icon: Icons.event_rounded,
            title: l10n.events,
            subtitle: l10n.companyAnnouncementsSchedules,
            onTap: () => context.go('/events'),
          ),
          const SizedBox(height: 10),
          _QuickTile(
            icon: Icons.history_rounded,
            title: l10n.attendanceHistory,
            subtitle: l10n.pastCheckInsCheckOuts,
            onTap: () => context.push('/attendance-history'),
          ),
          const SizedBox(height: 20),
          GlassCard(
            child: Row(
              children: [
                Icon(Icons.info_outline, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.faceRegistrationInfo,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
class _CheckInOutButtons extends StatelessWidget {
  final WidgetRef ref;
  const _CheckInOutButtons({required this.ref});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Row(
      children: [
        // Check In
        Expanded(
          child: _AttendanceActionButton(
            label: l10n.checkIn,
            icon: Icons.login_rounded,
            color: const Color(0xFF1D9E75),
            onTap: () {
              startFaceAttendance(
                context: context,
                ref: ref,
                action: EmployeeAttendanceAction.checkIn,
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        // Check Out
        Expanded(
          child: _AttendanceActionButton(
            label: l10n.checkOut,
            icon: Icons.logout_rounded,
            color: const Color(0xFFD85A30),
            onTap: () {
              startFaceAttendance(
                context: context,
                ref: ref,
                action: EmployeeAttendanceAction.checkOut,
              );
            },
          ),
        ),
      ],
    ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.06);
  }
}
class _AttendanceActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AttendanceActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                l10n.scanFaceToMark,
                style: TextStyle(
                  color: Colors.white.withValues(alpha:0.75),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

