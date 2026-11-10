import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

import "../../../../core/router/app_routes.dart";
import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_spacing.dart";
import "../../../../core/widgets/app_button.dart";
import "../../../../core/widgets/app_text_field.dart";
import "../auth_validators.dart";
import "../widgets/auth_links.dart";
import "../widgets/auth_scaffold.dart";
import "../widgets/or_divider.dart";

/// Sign in. UI-only for now; a successful submit is simulated locally and
/// lands on the journal shell.
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  String? _emailError;
  String? _passwordError;
  bool _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final emailError = AuthValidators.email(_email.text);
    final passwordError = AuthValidators.password(_password.text);
    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
    });
    if (emailError != null || passwordError != null) return;

    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _submitting = false);
    context.go(AppRoutes.home);
  }

  void _openCreateAccount() => context.push(AppRoutes.authCreateAccount);

  void _openRecovery() => context.push(AppRoutes.authRecover);

  void _google() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Google sign-in arrives in Phase 3.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return AuthScaffold(
      recordLabel: "Sign in",
      title: "Open your file",
      footer: AuthFooter(
        children: [
          AppButton(label: "Sign in", loading: _submitting, onPressed: _submit),
          AuthTextLink(
            label: "New here? Create account",
            onTap: _openCreateAccount,
          ),
        ],
      ),
      children: [
        Text(
          "Welcome back. Your register is exactly where you left it.",
          style: context.type.bodySmall.copyWith(color: c.inkMuted),
        ),
        const SizedBox(height: AppSpacing.xl),
        AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: "Email",
                controller: _email,
                focusNode: _emailFocus,
                hint: "amira@mail.com",
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                errorText: _emailError,
                onChanged: (_) {
                  if (_emailError != null) setState(() => _emailError = null);
                },
                onSubmitted: (_) => _passwordFocus.requestFocus(),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppTextField(
                label: "Password",
                controller: _password,
                focusNode: _passwordFocus,
                obscure: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                errorText: _passwordError,
                onChanged: (_) {
                  if (_passwordError != null) {
                    setState(() => _passwordError = null);
                  }
                },
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.s),
              AuthTextLink(
                label: "Forgot password?",
                alignment: Alignment.centerRight,
                onTap: _openRecovery,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        const OrDivider(),
        const SizedBox(height: AppSpacing.l),
        AppButton(
          label: "Sign in with Google",
          variant: AppButtonVariant.ghost,
          showArrow: false,
          onPressed: _google,
        ),
      ],
    );
  }
}
