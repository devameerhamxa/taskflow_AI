import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taskflow_ai/core/constants/app_theme.dart';
import 'package:taskflow_ai/features/auth/application/auth_providers.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Periodically check if the user has verified their email.
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _checkEmailVerified());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerified() async {
    final user = ref.read(authControllerProvider.notifier).currentUser;
    await user?.reload();
    if (user?.emailVerified ?? false) {
      _timer?.cancel();
      // The AuthGate will automatically navigate to the main app.
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
  
  void _resendVerificationEmail() {
    ref.read(authControllerProvider.notifier).sendEmailVerification(_showErrorSnackbar);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification email sent!'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userEmail = ref.watch(authControllerProvider.notifier).currentUser?.email ?? 'your email';

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Your Email')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.email_outlined, size: 80, color: AppTheme.primaryColor),
              const SizedBox(height: 24),
              Text(
                'Check Your Inbox',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  textStyle: theme.textTheme.headlineMedium,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'We have sent a verification link to\n$userEmail',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(textStyle: theme.textTheme.bodyMedium),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _resendVerificationEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Resend Email', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
                child: const Text('Cancel', style: TextStyle(color: AppTheme.primaryColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}