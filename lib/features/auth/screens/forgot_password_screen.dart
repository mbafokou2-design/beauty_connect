import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

enum _Step { email, resetCode, success }

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();

  _Step _step = _Step.email;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendResetCode() async {
    if (!_emailFormKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.forgotPassword(
      _emailController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      // Dev mode: backend returns resetToken directly in authProvider.lastResetToken
      if (authProvider.lastResetToken != null) {
        _codeController.text = authProvider.lastResetToken!;
      }
      setState(() => _step = _Step.resetCode);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Request failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmReset() async {
    if (!_resetFormKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.resetPassword(
      token: _codeController.text.trim(),
      password: _newPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      setState(() => _step = _Step.success);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Reset failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      if (_step == _Step.resetCode) {
                        setState(() => _step = _Step.email);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: switch (_step) {
                  _Step.email => _buildEmailStep(authProvider),
                  _Step.resetCode => _buildResetCodeStep(authProvider),
                  _Step.success => _buildSuccessStep(),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailStep(AuthProvider authProvider) {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Forgot Password?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              fontFamily: 'Georgia',
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Enter the email address associated with your account and we\'ll send you a code to reset your password.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textGrey,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'EMAIL ADDRESS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textGrey,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'e.g. julia.vane@luxury.com',
              suffixIcon: Icon(
                Icons.email_outlined,
                color: AppColors.textGrey,
              ),
            ),
            validator: (v) {
              if (v!.isEmpty) return 'Email required';
              if (!v.contains('@')) return 'Invalid email';
              return null;
            },
          ),
          const SizedBox(height: 24),
          authProvider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.pinkRose),
                )
              : ElevatedButton(
                  onPressed: _sendResetCode,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Send Reset Code',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
          const SizedBox(height: 32),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Remember your password? ',
                  style: TextStyle(color: AppColors.textGrey, fontSize: 14),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    'Log in',
                    style: TextStyle(
                      color: AppColors.pinkRose,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildResetCodeStep(AuthProvider authProvider) {
    return Form(
      key: _resetFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Enter Reset Code',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              fontFamily: 'Georgia',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'We sent a reset code for ${_emailController.text}. In development mode, it has been pre-filled below.',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textGrey,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'RESET CODE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textGrey,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _codeController,
            decoration: const InputDecoration(
              hintText: 'Reset token',
              prefixIcon: Icon(Icons.vpn_key_outlined, color: AppColors.textGrey),
            ),
            validator: (v) => v!.isEmpty ? 'Code required' : null,
          ),
          const SizedBox(height: 16),
          const Text(
            'NEW PASSWORD',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textGrey,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _newPasswordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textGrey),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textGrey,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) {
              if (v!.isEmpty) return 'Password required';
              if (v.length < 6) return 'Minimum 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 24),
          authProvider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.pinkRose),
                )
              : ElevatedButton(
                  onPressed: _confirmReset,
                  child: const Text(
                    'Reset Password',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: _sendResetCode,
              child: const Text(
                'Resend code',
                style: TextStyle(color: AppColors.pinkRose, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSuccessStep() {
    return Column(
      children: [
        const SizedBox(height: 60),
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: AppColors.white, size: 40),
        ),
        const SizedBox(height: 24),
        const Text(
          'Password Reset!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
            fontFamily: 'Georgia',
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Your password has been changed successfully. You can now log in with your new password.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.textGrey, height: 1.6),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
          child: const Text(
            'Back to Login',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}