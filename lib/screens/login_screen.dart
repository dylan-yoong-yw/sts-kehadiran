import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../services/auth_service.dart';
import '../widgets/fill_scroll_view.dart';

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

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

  void _openSignUp() {}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final linkStyle = text.labelLarge?.copyWith(
      decoration: TextDecoration.underline,
    );
    return DecoratedBox(
      key: const Key('login-background'),
      decoration: BoxDecoration(gradient: AppGradients.login),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              // The form is centred in the space above the pinned sign-up
              // line; it scrolls when the content is taller (short phones,
              // large system text, open keyboard).
              child: FillScrollView(
                scrollKey: const Key('login-scroll'),
                sections: [
                  const SizedBox(height: AppSpacing.section),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Theme(
                      data: AppTheme.loginFields(theme),
                      child: _buildForm(text, linkStyle),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.section),
                    child: Wrap(
                      key: const Key('login-footer'),
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Don’t have an account yet?',
                          style: text.bodyLarge,
                        ),
                        TextButton(
                          key: const Key('login-sign-up'),
                          onPressed: _busy ? null : _openSignUp,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.darkGreen,
                            textStyle: linkStyle,
                          ),
                          child: const Text('Sign up'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(TextTheme text, TextStyle? linkStyle) => Form(
    key: _formKey,
    child: AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'STS KEHADIRAN',
            key: const Key('login-title'),
            textAlign: TextAlign.center,
            style: text.displaySmall?.copyWith(color: AppColors.darkGreen),
          ),
          const SizedBox(height: 32),
          TextFormField(
            key: const Key('login-email'),
            controller: _emailController,
            enabled: !_busy,
            style: text.bodyLarge,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            autocorrect: false,
            decoration: const InputDecoration(labelText: 'Email'),
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
          const SizedBox(height: AppSpacing.section),
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
                : const Text('Login'),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              key: const Key('login-forgot-password'),
              onPressed: _busy ? null : _resetPassword,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.darkGreen,
                textStyle: linkStyle,
              ),
              child: const Text('Forgot password?'),
            ),
          ),
        ],
      ),
    ),
  );
}
