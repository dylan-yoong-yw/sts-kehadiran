import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/validators.dart';
import '../../services/auth_service.dart';
import '../../services/sign_up_service.dart';
import '../../widgets/fill_scroll_view.dart';
import '../../widgets/form_error_banner.dart';

/// Teacher registration (FR-01), opened from the "Sign up" link on the
/// login screen.
///
/// On success the new teacher is signed in, the auth gate underneath has
/// already switched to the teacher interface, and this screen closes.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const SignUpScreen());

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _title;
  bool _obscurePasswords = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final signUp = context.read<SignUpService>();
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    try {
      await signUp.signUpTeacher(
        title: _title!,
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      // Signed in: reveal the teacher interface beneath this screen.
      if (mounted) navigator.popUntil((route) => route.isFirst);
    } on AuthException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = FirebaseAuthService.genericMessage);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final linkStyle = text.labelLarge?.copyWith(
      decoration: TextDecoration.underline,
    );
    return PopScope(
      // Stay put while the account is being created, so the result (or an
      // error) is never lost.
      canPop: !_busy,
      child: DecoratedBox(
        key: const Key('sign-up-background'),
        decoration: BoxDecoration(gradient: AppGradients.login),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.darkGreen,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: !_busy,
          ),
          body: SafeArea(
            top: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: FillScrollView(
                  scrollKey: const Key('sign-up-scroll'),
                  sections: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Theme(
                        data: AppTheme.loginForm(theme),
                        child: _buildForm(text),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.section,
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            textAlign: TextAlign.center,
                            style: text.bodyLarge,
                          ),
                          TextButton(
                            key: const Key('sign-up-login'),
                            onPressed: _busy
                                ? null
                                : () => Navigator.of(context).maybePop(),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.darkGreen,
                              textStyle: linkStyle,
                            ),
                            child: const Text('Log in'),
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
      ),
    );
  }

  Widget _buildForm(TextTheme text) {
    const gap = SizedBox(height: AppSpacing.section);
    final passwordToggle = IconButton(
      key: const Key('sign-up-toggle-password'),
      tooltip: _obscurePasswords ? 'Show password' : 'Hide password',
      onPressed: () => setState(() => _obscurePasswords = !_obscurePasswords),
      icon: Icon(
        _obscurePasswords
            ? Icons.visibility_outlined
            : Icons.visibility_off_outlined,
        color: AppColors.dateChipIcon,
      ),
    );
    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                'Create your account',
                key: const Key('sign-up-heading'),
                textAlign: TextAlign.center,
                style: text.headlineSmall?.copyWith(color: AppColors.darkGreen),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Teachers can sign up here. Your school admin will then '
              'assign your classes.',
              textAlign: TextAlign.center,
              style: text.bodyLarge?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 28),
            DropdownButtonFormField<String>(
              key: const Key('sign-up-title'),
              initialValue: _title,
              isExpanded: true,
              style: text.bodyLarge,
              decoration: const InputDecoration(labelText: 'Title'),
              items: [
                for (final title in teacherTitles)
                  DropdownMenuItem(value: title, child: Text(title)),
              ],
              onChanged: _busy ? null : (value) => _title = value,
              validator: validateTitle,
            ),
            gap,
            TextFormField(
              key: const Key('sign-up-name'),
              controller: _nameController,
              enabled: !_busy,
              style: text.bodyLarge,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              maxLength: maxNameLength,
              buildCounter: (
                _, {
                required currentLength,
                required isFocused,
                maxLength,
              }) => null,
              decoration: const InputDecoration(labelText: 'Full name'),
              validator: validateName,
            ),
            gap,
            TextFormField(
              key: const Key('sign-up-email'),
              controller: _emailController,
              enabled: !_busy,
              style: text.bodyLarge,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              autocorrect: false,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: validateEmail,
            ),
            gap,
            TextFormField(
              key: const Key('sign-up-password'),
              controller: _passwordController,
              enabled: !_busy,
              style: text.bodyLarge,
              obscureText: _obscurePasswords,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              decoration: InputDecoration(
                labelText: 'Password',
                helperText: 'At least $minPasswordLength characters',
                suffixIcon: passwordToggle,
              ),
              validator: validateNewPassword,
            ),
            gap,
            TextFormField(
              key: const Key('sign-up-confirm-password'),
              controller: _confirmController,
              enabled: !_busy,
              style: text.bodyLarge,
              // Follows the toggle on the password field above.
              obscureText: _obscurePasswords,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              onFieldSubmitted: (_) => _submit(),
              decoration: const InputDecoration(labelText: 'Confirm password'),
              validator: (value) =>
                  validateConfirmPassword(value, _passwordController.text),
            ),
            gap,
            if (_error case final error?) ...[
              FormErrorBanner(key: const Key('sign-up-error'), message: error),
              gap,
            ],
            FilledButton(
              key: const Key('sign-up-submit'),
              style: AppTheme.primaryButton,
              onPressed: _busy ? null : _submit,
              child: _busy
                  ? const SizedBox.square(
                      key: Key('sign-up-progress'),
                      dimension: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Create account'),
            ),
          ],
        ),
      ),
    );
  }
}
