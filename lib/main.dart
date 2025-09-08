import 'dart:async';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskflow_ai/core/constants/app_theme.dart';
import 'package:taskflow_ai/core/providers/theme_provider.dart';
import 'package:taskflow_ai/core/services/config_service.dart';
import 'package:taskflow_ai/features/auth/presentation/screens/auth_gate.dart';
import 'package:taskflow_ai/firebase_options.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      final prefs = await SharedPreferences.getInstance();

      await ConfigService.instance.initialize();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        log("🔥 Flutter Error: ${details.exceptionAsString()}");
      };

      runApp(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const MyApp(),
        ),
      );
    },
    (error, stackTrace) {
      log("💥 Uncaught Error: $error");
      log("📌 Stack trace: $stackTrace");
    },
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp(
      title: 'TaskFlow AI',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}
