import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supervisor_app/core/localization/language_selection_page.dart';
import 'package:supervisor_app/features/attendance/presentation/attendance_history_page.dart';
import 'package:supervisor_app/features/attendance/presentation/face_verification_page.dart';
import 'package:supervisor_app/features/auth/presentation/login_page.dart';
import 'package:supervisor_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:supervisor_app/features/dashboard/presentation/dashboard_page.dart';
import 'package:supervisor_app/features/employees/domain/employee_model.dart';
import 'package:supervisor_app/features/employees/presentation/employee_detail_page.dart';
import 'package:supervisor_app/features/employees/presentation/employees_list_page.dart';
import 'package:supervisor_app/features/events/presentation/event_detail_page.dart';
import 'package:supervisor_app/features/events/presentation/events_list_page.dart';
import 'package:supervisor_app/features/face/presentation/face_register_page.dart';
import 'package:supervisor_app/features/notifications/presentation/notifications_page.dart';
import 'package:supervisor_app/features/profile/presentation/profile_page.dart';
import 'package:supervisor_app/features/settings/presentation/settings_page.dart';
import 'package:supervisor_app/features/wages/presentation/wage_summary_page.dart';
import 'package:supervisor_app/shared/widgets/main_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final loggedIn = authState.valueOrNull?.isAuthenticated ?? false;
      final loggingIn = state.matchedLocation == '/login';

      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      ShellRoute(
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (_, __) => const DashboardPage()),
          GoRoute(path: '/employees', builder: (_, __) => const EmployeesListPage()),
          GoRoute(
            path: '/employees/:id',
            builder: (_, state) {
              final employee = state.extra as EmployeeModel?;
              return EmployeeDetailPage(
                id: int.parse(state.pathParameters['id']!),
                employee: employee,
              );
            },
          ),
          GoRoute(
            path: '/employees/:id/register-face',
            builder: (_, state) => FaceRegisterPage(
              employeeId: int.parse(state.pathParameters['id']!),
              returnTo: state.uri.queryParameters['returnTo'],
            ),
          ),
          GoRoute(
            path: '/employees/:id/verify-face',
            builder: (_, state) => FaceVerificationPage(
              employeeId: int.parse(state.pathParameters['id']!),
              action: state.uri.queryParameters['action'] ?? 'check_in',
            ),
          ),
          GoRoute(
            path: '/face-scan',
            builder: (_, state) => FaceVerificationPage(
              employeeId: null,
              action: state.uri.queryParameters['action'] ?? 'check_in',
            ),
          ),
          GoRoute(path: '/events', builder: (_, __) => const EventsListPage()),
          GoRoute(
            path: '/events/:id',
            builder: (_, state) => EventDetailPage(id: int.parse(state.pathParameters['id']!)),
          ),
          GoRoute(path: '/attendance-history', builder: (_, __) => const AttendanceHistoryPage()),
          GoRoute(path: '/wages', builder: (_, __) => const WageSummaryPage()),
          GoRoute(path: '/notifications', builder: (_, __) => const NotificationsPage()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
          GoRoute(path: '/language', builder: (_, __) => const LanguageSelectionPage()),
        ],
      ),
    ],
  );
});
