import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

import "../../../../core/router/app_routes.dart";
import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_spacing.dart";
import "../../../../core/widgets/app_button.dart";
import "../../../../core/widgets/app_text_field.dart";
import "../../../../core/widgets/square_checkbox.dart";
import "../auth_validators.dart";
import "../widgets/auth_links.dart";
import "../widgets/auth_scaffold.dart";
import "../widgets/or_divider.dart";
import "../widgets/password_strength.dart";

/// Create account. Local validation + a simulated save until Phase 3.
class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _termsError;
  bool _accepted = false;
  bool _submitting = false;
  String _passwordValue = "";

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final nameError = AuthValidators.name(_name.text);
    final emailError = AuthValidators.email(_email.text);
    final passwordError = AuthValidators.newPassword(_password.text);
    final termsError = _accepted ? null : "Accept the terms to continue";
    setState(() {
      _nameError = nameError;
      _emailError = emailError;
      _passwordError = passwordError;
      _termsError = termsError;
    });
    if (nameError != null ||
        emailError != null ||
        passwordError != null ||
        termsError != null) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _submitting = false);
    context.go(AppRoutes.home);
  }

  void _backToSignIn() => context.go(AppRoutes.authSignIn);

  void _google() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Google sign-in arrives in Phase 3.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return AuthScaffold(
      recordLabel: "New account",
      title: "Open a file",
      footer: AuthFooter(
        children: [
          AppButton(
            label: "Create account",
            variant: AppButtonVariant.strip,
            loading: _submitting,
            onPressed: _submit,
          ),
          AuthTextLink(label: "Have an account? Sign in", onTap: _backToSignIn),
        ],
      ),
      children: [
        AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: "Name",
                controller: _name,
                focusNode: _nameFocus,
                hint: "Amira Khalil",
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.name],
                errorText: _nameError,
                onChanged: (_) {
                  if (_nameError != null) setState(() => _nameError = null);
                },
                onSubmitted: (_) => _emailFocus.requestFocus(),
              ),
              const SizedBox(height: AppSpacing.xl),
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
                autofillHints: const [AutofillHints.newPassword],
                errorText: _passwordError,
                onChanged: (value) {
                  setState(() {
                    _passwordError = null;
                    _passwordValue = value;
                  });
                },
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.s),
              PasswordStrength(value: _passwordValue),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        SquareCheckbox(
          value: _accepted,
          label: "I accept the terms and privacy notice.",
          onChanged: (value) {
            setState(() {
              _accepted = value;
              if (value) _termsError = null;
            });
          },
        ),
        if (_termsError != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              _termsError!.toUpperCase(),
              style: context.type.metaSmall.copyWith(color: c.accent),
            ),
          ),
        const SizedBox(height: AppSpacing.xl),
        const OrDivider(),
        const SizedBox(height: AppSpacing.l),
        AppButton(
          label: "Create with Google",
          variant: AppButtonVariant.ghost,
          showArrow: false,
          onPressed: _google,
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}
