import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/dashboard_widgets.dart';

// Same palette as the main screen.
const _green = Color(0xFF00C58B);
const _darkGreen = Color(0xFF064C3D);
const _background = Color(0xFFF2FFFA);
const _accent = Color(0xFF29A884);
const _muted = Color(0xFF63796F);

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
        ..showSnackBar(
          SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
        );
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

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: width),
        );
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _accent),
      suffixIcon: suffix,
      filled: true,
      fillColor: _background,
      enabledBorder: border(const Color(0xFFD5EDE4)),
      focusedBorder: border(_green, 2),
      errorBorder: border(const Color(0xFFB3261E)),
      focusedErrorBorder: border(const Color(0xFFB3261E), 2),
      disabledBorder: border(const Color(0xFFE2ECE8)),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _background,
    body: SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            key: const Key('login-scroll'),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    Icon(Icons.school, size: 25, color: _darkGreen),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'STS Kehadiran',
                        style: TextStyle(
                          color: _darkGreen,
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                DashboardCard(
                  color: const Color(0xFFCFF2E7),
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_greeting!',
                              style: const TextStyle(
                                color: _accent,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Welcome back, Teacher!',
                              style: TextStyle(
                                color: _darkGreen,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Sign in to take attendance, check your '
                              'timetable and manage your classes.',
                              style: TextStyle(fontSize: 13, height: 1.35),
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
                          size: 30,
                          color: Color(0xFFDCAB4D),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                DashboardCard(
                  color: Colors.white,
                  padding: const EdgeInsets.all(18),
                  child: Form(
                    key: _formKey,
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Sign in',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            key: const Key('login-email'),
                            controller: _emailController,
                            enabled: !_busy,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            autocorrect: false,
                            decoration: _fieldDecoration(
                              label: 'Email',
                              icon: Icons.email_outlined,
                            ),
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            key: const Key('login-password'),
                            controller: _passwordController,
                            enabled: !_busy,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            onFieldSubmitted: (_) => _signIn(),
                            decoration: _fieldDecoration(
                              label: 'Password',
                              icon: Icons.lock_outline,
                              suffix: IconButton(
                                tooltip: _obscurePassword
                                    ? 'Show password'
                                    : 'Hide password',
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: const Color(0xFF6A7973),
                                ),
                              ),
                            ),
                            validator: (value) => (value ?? '').isEmpty
                                ? 'Please enter your password.'
                                : null,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _busy ? null : _resetPassword,
                              style: TextButton.styleFrom(
                                foregroundColor: _accent,
                              ),
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          if (_error != null) ...[
                            Container(
                              key: const Key('login-error'),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDECEA),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Color(0xFFB3261E),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _error!,
                                      style: const TextStyle(
                                        color: Color(0xFF8C1D18),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          FilledButton(
                            key: const Key('login-submit'),
                            style: FilledButton.styleFrom(
                              backgroundColor: _green,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(0xFF7FDFC2),
                              disabledForegroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(50),
                              elevation: 2,
                              shadowColor: const Color(0x5500A67D),
                            ),
                            onPressed: _busy ? null : _signIn,
                            child: _busy
                                ? const SizedBox.square(
                                    dimension: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'Sign In',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.login_rounded, size: 19),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'For registered teachers only. Contact your school admin '
                  'if you need an account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: _muted),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
