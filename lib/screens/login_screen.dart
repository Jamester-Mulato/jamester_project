import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../routes/app_routes.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

/// Activity 8 sign-in screen, preserved for Activity 9.
///
/// The form reuses AppTextField and AppButton so the report form can share the
/// same visual language.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController(
    text: AppConstants.demoEmail,
  );
  final TextEditingController _passwordController = TextEditingController(
    text: AppConstants.demoPassword,
  );

  bool _isSigningIn = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSigningIn = true);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  void _skipToDashboard() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFF082F2B),
              Color(0xFF0F766E),
              Color(0xFF134E4A),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final bool wide = constraints.maxWidth >= 820;
                    final Widget brand = _BrandPanel(compact: !wide);
                    final Widget card = _buildLoginCard(context);

                    if (!wide) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          brand,
                          const SizedBox(height: 32),
                          card,
                        ],
                      );
                    }

                    return Row(
                      children: <Widget>[
                        Expanded(child: brand),
                        const SizedBox(width: 56),
                        SizedBox(width: 410, child: card),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 40,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Sign in',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Use your campus account to continue.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            AppTextField(
              key: const Key('login-email'),
              controller: _emailController,
              label: 'Campus email',
              hintText: 'name@campuscare.edu',
              prefixIcon: Icons.alternate_email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const <String>[AutofillHints.email],
              validator: (String? value) {
                final String email = value?.trim() ?? '';
                if (email.isEmpty) return 'Enter your campus email.';
                final bool valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                    .hasMatch(email);
                if (!valid) return 'Use a valid email address.';
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              key: const Key('login-password'),
              controller: _passwordController,
              label: 'Password',
              hintText: 'Enter your password',
              prefixIcon: Icons.lock_outline,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const <String>[AutofillHints.password],
              onFieldSubmitted: (_) => _signIn(),
              suffixIcon: IconButton(
                tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                ),
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Enter your password.';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters.';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            AppButton(
              key: const Key('login-submit'),
              label: 'Sign in',
              loadingLabel: 'Signing in...',
              icon: Icons.login,
              isLoading: _isSigningIn,
              onPressed: _signIn,
            ),
            const SizedBox(height: 10),
            AppButton(
              label: 'Skip to dashboard (demo)',
              variant: AppButtonVariant.ghost,
              icon: Icons.arrow_forward,
              onPressed: _isSigningIn ? null : _skipToDashboard,
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Demo credentials',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${AppConstants.demoEmail}\n${AppConstants.demoPassword}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: const Icon(
                Icons.verified_user_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              AppConstants.appName,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        SizedBox(height: compact ? 28 : 64),
        Text(
          'A safer campus starts with a clear report.',
          style:
              (compact
                      ? theme.textTheme.headlineMedium
                      : theme.textTheme.displaySmall)
                  ?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1.08,
                    letterSpacing: -1.2,
                  ),
        ),
        const SizedBox(height: 18),
        Text(
          AppConstants.tagline,
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.78),
            height: 1.55,
          ),
        ),
        if (!compact) ...<Widget>[
          const SizedBox(height: 40),
          const _FeatureRow(
            icon: Icons.edit_note_outlined,
            text: 'File a concern with guided, validated fields.',
          ),
          const SizedBox(height: 16),
          const _FeatureRow(
            icon: Icons.hourglass_top_outlined,
            text: 'See clear loading, success, empty, and error feedback.',
          ),
          const SizedBox(height: 16),
          const _FeatureRow(
            icon: Icons.shield_outlined,
            text: 'Built on the same Activity 8 project and shared widgets.',
          ),
        ],
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, color: const Color(0xFF99F6E4), size: 21),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
