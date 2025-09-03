import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taskflow_ai/core/constants/app_theme.dart';
import 'package:taskflow_ai/core/providers/theme_provider.dart';
import 'package:taskflow_ai/features/auth/application/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- THIS IS THE FIX ---
    // Watch the new StreamProvider instead of the old FutureProvider.
    final userProfileAsync = ref.watch(userProfileStreamProvider);
    // --- END OF FIX ---

    final theme = Theme.of(context);
    final currentTheme = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          userProfileAsync.when(
            data: (user) => user != null
                ? Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: AppTheme.primaryColor,
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: GoogleFonts.lato(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email,
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  )
                : const Center(child: Text('User not found')),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
          ),
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: Text('Theme', style: GoogleFonts.lato(fontSize: 16)),
            trailing: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_outlined),
                ),
              ],
              selected: {currentTheme},
              onSelectionChanged: (newSelection) {
                ref
                    .read(themeNotifierProvider.notifier)
                    .setTheme(newSelection.first);
              },
            ),
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(authControllerProvider.notifier).signOut();
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
