import 'dart:async';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_ai/core/constants/app_theme.dart';
import 'package:taskflow_ai/core/services/config_service.dart'; // Import the new service
import 'package:taskflow_ai/features/auth/presentation/screens/auth_gate.dart';
import 'package:taskflow_ai/firebase_options.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize our new ConfigService to load all secret keys
      await ConfigService.instance.initialize();

      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Global Flutter error handler
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        log("🔥 Flutter Error: ${details.exceptionAsString()}");
      };

      runApp(const ProviderScope(child: MyApp()));
    },
    (error, stackTrace) {
      log("💥 Uncaught Error: $error");
      log("📌 Stack trace: $stackTrace");
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow AI',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}
