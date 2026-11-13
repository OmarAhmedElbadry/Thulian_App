import "dart:async";

import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

import "../../../../core/di/injection.dart";
import "../../../../core/router/app_routes.dart";
import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_spacing.dart";
import "../../../../core/widgets/app_button.dart";
import "../../../../core/widgets/app_text_field.dart";
import "../auth_validators.dart";
import "../cubit/auth_cubit.dart";
import "../widgets/auth_links.dart";
import "../widgets/auth_notice.dart";
import "../widgets/auth_scaffold.dart";

/// Password recovery. The reset link is simulated locally and the notice
/// counts down to the next allowed resend.
class RecoveryPage extends StatefulWidget {
  const RecoveryPage({super.key});

  @override
  State<RecoveryPage> createState() => _RecoveryPageState();
}

class _RecoveryPageState extends State<RecoveryPage> {
  static const _resendCooldown = 42;

  final _email = TextEditingController();
  final _emailFocus = FocusNode();

  String? _emailError;
  bool _submitting = false;
  bool _sent = false;
  int _resendSeconds = _resendCooldown;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _email.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final error = AuthValidators.email(_email.text);
    setState(() => _emailError = error);
    if (error != null) return;

    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    if (sl.isRegistered<AuthCubit>()) {
      await sl<AuthCubit>().sendPasswordResetEmail(_email.text);
      if (!mounted) return;
      final result = sl<AuthCubit>().state;
      setState(() => _submitting = false);
      if (result.status == AuthActionStatus.success) {
        setState(() {
          _sent = true;
          _resendSeconds = _resendCooldown;
        });
        _startCountdown();
      } else if (result.message != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.message!)));
      }
      return;
    }

    // Keeps isolated presentation previews usable without app dependency setup.
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _sent = true;
      _resendSeconds = _resendCooldown;
    });
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_resendSeconds > 0) _resendSeconds--;
      });
      if (_resendSeconds == 0) timer.cancel();
    });
  }

  void _resend() {
    if (sl.isRegistered<AuthCubit>()) {
      _send();
      return;
    }
    setState(() => _resendSeconds = _resendCooldown);
    _startCountdown();
  }

  void _openMail() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Opening your mail app\u2026")),
    );
  }

  void _back() => context.go(AppRoutes.authSignIn);

  static String _two(int value) => value.toString().padLeft(2, "0");

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return AuthScaffold(
      recordLabel: "Recovery",
      title: "Recover your file",
      leading: AuthBackLink(label: "Sign in", onTap: _back),
      footer: AuthFooter(
        children: [
          AppButton(
            label: _sent ? "Open mail app" : "Send reset link",
            loading: _submitting,
            onPressed: _sent ? _openMail : _send,
          ),
        ],
      ),
      children: [
        Text(
          "Enter the email on your account and we will send a reset link.",
          style: context.type.bodySmall.copyWith(color: c.inkMuted),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppTextField(
          label: "Email",
          controller: _email,
          focusNode: _emailFocus,
          hint: "amira@mail.com",
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.email],
          errorText: _emailError,
          onChanged: (_) {
            if (_emailError != null) setState(() => _emailError = null);
          },
          onSubmitted: (_) => _send(),
        ),
        if (_sent) ...[
          const SizedBox(height: AppSpacing.xl),
          AuthNotice(
            label: "Link sent",
            children: [
              Text(
                "Check ${_email.text.trim()}.",
                style: context.type.bodySmall,
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                "It expires in 15:00.",
                style: context.type.metaSmall.copyWith(color: c.inkMuted),
              ),
              const SizedBox(height: AppSpacing.m),
              if (_resendSeconds > 0)
                Text(
                  "RESEND IN 00:${_two(_resendSeconds)}",
                  style: context.type.metaSmall,
                )
              else
                Semantics(
                  button: true,
                  label: "Resend link",
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _resend,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: ExcludeSemantics(
                        child: Text(
                          "RESEND LINK",
                          style: context.type.metaSmall.copyWith(
                            color: c.accent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
