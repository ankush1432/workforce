import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supervisor_app/core/config/app_config.dart';
import 'package:supervisor_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:supervisor_app/shared/widgets/glass_card.dart';
import 'package:supervisor_app/l10n/app_localizations.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController(text: 'supervisor@acme.com');
  final _password = TextEditingController(text: 'password');

  Future<void> _submit() async {
    await ref.read(authStateProvider.notifier).login(_email.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final loading = auth.isLoading;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF111827), Color(0xFF070B14)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: GlassCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset("assets/images/app_logo.png",width:  96,height: 96,)
                      .animate()
                      .fadeIn()
                      .scale(),
                  const SizedBox(height: 16),
                  Text(l10n.supervisorLogin, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _email,
                    decoration: InputDecoration(labelText: l10n.email, border: const OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    decoration: InputDecoration(labelText: l10n.password, border: const OutlineInputBorder()),
                  ),
                  if (auth.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        _friendlyAuthError(auth.error, l10n),
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: loading ? null : _submit,
                      child: loading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(l10n.signIn),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
          ),
        ),
      ),
    );
  }

  String _friendlyAuthError(Object? error, AppLocalizations l10n) {
    final text = error.toString();
    if (text.contains('SocketException') || text.contains('Connection refused')) {
      return l10n.cannotReachApi(AppConfig.apiBaseUrl);
    }
    return text;
  }
}
