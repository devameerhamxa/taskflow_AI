import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_ai/features/auth/application/auth_providers.dart';
import 'package:taskflow_ai/features/auth/presentation/screens/login_screen.dart';
import 'package:taskflow_ai/features/auth/presentation/screens/splash_screen.dart';
import 'package:taskflow_ai/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:taskflow_ai/features/dashboard/presentation/screens/main_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          if (user.providerData.any((p) => p.providerId == 'password') &&
              !user.emailVerified) {
            return const VerifyEmailScreen();
          }
          // Navigate to MainScreen instead of TaskListScreen
          return const MainScreen();
        }
        return const LoginScreen();
      },
      loading: () => const SplashScreen(),
      error: (error, stackTrace) =>
          Scaffold(body: Center(child: Text('An error occurred: $error'))),
    );
  }
}
