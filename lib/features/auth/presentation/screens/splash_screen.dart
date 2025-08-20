import 'package:flutter/material.dart';
import 'package:taskflow_ai/core/constants/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: Theme.of(context).brightness == Brightness.light
            ? AppTheme.lightBackgroundGradient
            : AppTheme.darkBackgroundGradient,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Replace with your app's logo
              Icon(Icons.task_alt, size: 80, color: AppTheme.primaryColor),
              SizedBox(height: 20),
              Text(
                'TaskFlow AI',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 40),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}