import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

import "../../../../core/di/injection.dart";
import "../../../../core/router/app_routes.dart";
import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_spacing.dart";
import "../../../../core/widgets/app_button.dart";
import "../../domain/repositories/auth_repository.dart";
import "../cubit/auth_cubit.dart";
import "../widgets/auth_links.dart";
import "../widgets/auth_notice.dart";
import "../widgets/auth_scaffold.dart";

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool _checking = false;
  bool _resending = false;

  String get _email => sl<AuthRepository>().currentUser?.email ?? "your email";

  Future<void> _checkVerification() async {
    setState(() => _checking = true);
    await sl<AuthCubit>().checkEmailVerification();
    if (!mounted) return;
    final result = sl<AuthCubit>().state;
    setState(() => _checking = false);
    if (result.status == AuthActionStatus.success) {
      context.go(AppRoutes.home);
    } else {
      _showMessage(result.message);
    }
  }

  Future<void> _resendVerification() async {
    setState(() => _resending = true);
    await sl<AuthCubit>().sendEmailVerification();
    if (!mounted) return;
    final result = sl<AuthCubit>().state;
    setState(() => _resending = false);
    _showMessage(
      result.status == AuthActionStatus.success
          ? "Verification email sent. Check your inbox and spam folder."
          : result.message,
    );
  }

  Future<void> _useAnotherAccount() async {
    await sl<AuthCubit>().signOut();
    if (mounted) context.go(AppRoutes.authSignIn);
  }

  void _showMessage(String? message) {
    if (message == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AuthScaffold(
      recordLabel: "Verify email",
      title: "One last step",
      footer: AuthFooter(
        children: [
          AppButton(
            label: "I've verified my email",
            loading: _checking,
            onPressed: _checking || _resending ? null : _checkVerification,
          ),
          AppButton(
            label: _resending ? "Sending email…" : "Resend verification email",
            variant: AppButtonVariant.ghost,
            showArrow: false,
            loading: _resending,
            onPressed: _checking || _resending ? null : _resendVerification,
          ),
          AuthTextLink(label: "Use another account", onTap: _useAnotherAccount),
        ],
      ),
      children: [
        Text(
          "We sent a verification link to $_email. Open it to confirm your address, then come back here.",
          style: context.type.bodySmall.copyWith(color: c.inkMuted),
        ),
        const SizedBox(height: AppSpacing.xl),
        AuthNotice(
          label: "Check your inbox",
          children: [
            Text(
              "After you tap the link, return to Thulian and choose “I've verified my email.” If you don't see the message, check your spam folder.",
              style: context.type.bodySmall.copyWith(color: c.inkMuted),
            ),
          ],
        ),
      ],
    );
  }
}
