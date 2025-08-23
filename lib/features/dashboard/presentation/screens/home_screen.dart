import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taskflow_ai/core/constants/app_theme.dart';
import 'package:taskflow_ai/features/auth/application/auth_providers.dart';
import 'package:taskflow_ai/features/tasks/presentation/screens/task_list_screen.dart';

final pageIndexProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const List<Widget> _pages = <Widget>[
    DashboardView(),
    TaskListScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageIndex = ref.watch(pageIndexProvider);

    return Scaffold(
      body: IndexedStack(index: pageIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: pageIndex,
        onTap: (index) => ref.read(pageIndexProvider.notifier).state = index,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt_outlined),
            label: 'Tasks',
          ),
        ],
      ),
    );
  }
}

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Watch the new user profile provider
    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Use .when to handle loading/error states gracefully
          userProfileAsync.when(
            data: (userProfile) {
              final userName = userProfile?.name ?? 'User';
              return Text(
                'Good morning, $userName!',
                style: GoogleFonts.lato(
                  textStyle: theme.textTheme.headlineSmall,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (err, stack) => const Text('Could not load user data.'),
          ),
          const SizedBox(height: 24),
          _buildInfoCard(
            context: context,
            icon: Icons.lightbulb_outline,
            title: 'AI Insight',
            subtitle: 'Weekly progress report coming soon.',
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            context: context,
            icon: Icons.auto_awesome_outlined,
            title: 'AI Suggestion',
            subtitle: 'Personalized suggestions will appear here.',
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            context: context,
            icon: Icons.star_border_outlined,
            title: 'Gamification',
            subtitle: 'Track your points and streaks here.',
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDarkMode ? Colors.white24 : Colors.black12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
