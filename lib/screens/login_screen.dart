import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/airy_logo.dart';
import '../widgets/gradient_button.dart';
import '../widgets/glass_card.dart';

class LoginScreen extends StatefulWidget {
  final AuthService authService;
  final VoidCallback onLoginSuccess;
  final VoidCallback onGoToSignup;

  const LoginScreen({
    super.key,
    required this.authService,
    required this.onLoginSuccess,
    required this.onGoToSignup,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _obscure = true;

  Future<void> _submit() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      setState(() => _error = 'Enter both email and password');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      widget.onLoginSuccess();
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.darkBgDeep,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.darkBgRadial,
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: GlassCard(
                padding: EdgeInsets.all(isMobile ? 24 : 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  const AiryLogo(showText: true, size: 36),
                  const SizedBox(height: 20),
                  Text(
                    'Welcome Back',
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sign in to ResearchAI Plagiarism Platform',
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: _emailController,
                    style: TextStyle(color: AppColors.textPrimary(context), fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Email address',
                      prefixIcon: Icon(Icons.mail_outline, size: 18),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    style: TextStyle(color: AppColors.textPrimary(context), fontSize: 13),
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 18,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.darkAccentRed.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.darkAccentRed.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: AppColors.darkAccentRed, fontSize: 12),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: GradientButton(
                      text: 'Sign In',
                      icon: Icons.login_rounded,
                      isLoading: _loading,
                      onPressed: _submit,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: widget.onGoToSignup,
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12.5),
                        children: [
                          const TextSpan(text: "Don't have an account? "),
                          TextSpan(
                            text: 'Sign up',
                            style: TextStyle(
                              color: AppColors.accentGreen(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
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
}
