import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../services/auth_service.dart';
import '../widgets/dashboard_widgets.dart';
import '../widgets/fill_scroll_view.dart';

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.now});

  /// Clock used for the greeting; overridable in tests.
  final DateTime Function()? now;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String get _greeting {
    final hour = (widget.now ?? DateTime.now)().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Please enter your email.';
    if (!_emailPattern.hasMatch(email)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  Future<void> _signIn() async {
    if (_busy) return;
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    try {
      await AuthScope.of(context).signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // On success the auth gate replaces this screen with the dashboard.
    } on AuthException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resetPassword() async {
    final messenger = ScaffoldMessenger.of(context);
    void show(String message) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }

    final email = _emailController.text.trim();
    if (_validateEmail(email) != null) {
      show('Enter your email above, then tap “Forgot password?” again.');
      return;
    }
    try {
      await AuthScope.of(context).sendPasswordReset(email);
      show('If an account exists for $email, a reset link has been sent.');
    } on AuthException catch (error) {
      show(error.message);
    } catch (_) {
      show('Something went wrong. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            // Header at the top, footer at the bottom and the cards centred
            // between them; scrolls when the content is taller (short
            // phones, large system text, open keyboard).
            child: FillScrollView(
              scrollKey: const Key('login-scroll'),
              sections: [
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.section),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.school,
                        size: 28,
                        color: AppColors.darkGreen,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'STS Kehadiran',
                          style: text.titleLarge?.copyWith(
                            color: AppColors.darkGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _WelcomeCard(greeting: _greeting),
                      const SizedBox(height: AppSpacing.section),
                      DashboardCard(
                        key: const Key('login-form-card'),
                        color: Colors.white,
                        child: _buildForm(text),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.section),
                  child: Text(
                    'For registered teachers only. Contact your school admin '
                    'if you need an account.',
                    key: const Key('login-footer'),
                    textAlign: TextAlign.center,
                    style: text.bodySmall?.copyWith(color: AppColors.muted),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(TextTheme text) => Form(
    key: _formKey,
    child: AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Sign in', style: text.titleMedium),
          const SizedBox(height: AppSpacing.section),
          TextFormField(
            key: const Key('login-email'),
            controller: _emailController,
            enabled: !_busy,
            style: text.bodyLarge,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            autocorrect: false,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: _validateEmail,
          ),
          const SizedBox(height: AppSpacing.section),
          TextFormField(
            key: const Key('login-password'),
            controller: _passwordController,
            enabled: !_busy,
            style: text.bodyLarge,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onFieldSubmitted: (_) => _signIn(),
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.dateChipIcon,
                ),
              ),
            ),
            validator: (value) =>
                (value ?? '').isEmpty ? 'Please enter your password.' : null,
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _busy ? null : _resetPassword,
              style: TextButton.styleFrom(foregroundColor: AppColors.accent),
              child: const Text('Forgot password?'),
            ),
          ),
          const SizedBox(height: 8),
          if (_error != null) ...[
            Container(
              key: const Key('login-error'),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.errorBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _error!,
                      style: text.bodyMedium?.copyWith(
                        color: AppColors.errorText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.section),
          ],
          FilledButton(
            key: const Key('login-submit'),
            style: AppTheme.primaryButton,
            onPressed: _busy ? null : _signIn,
            child: _busy
                ? const SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(child: Text('Sign In')),
                      SizedBox(width: 8),
                      Icon(Icons.login_rounded, size: 22),
                    ],
                  ),
          ),
        ],
      ),
    ),
  );
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.greeting});

  final String greeting;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return DashboardCard(
      color: AppColors.attendanceCard,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting!',
                  style: text.titleSmall?.copyWith(color: AppColors.accent),
                ),
                const SizedBox(height: 6),
                Text(
                  'Welcome back, Teacher!',
                  style: text.headlineSmall?.copyWith(
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to take attendance, check your timetable and '
                  'manage your classes.',
                  style: text.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x4400DA9B),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.waving_hand_rounded,
              size: 32,
              color: AppColors.amber,
            ),
          ),
        ],
      ),
    );
  }
}
