import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taskflow_ai/core/constants/app_theme.dart';
import 'package:taskflow_ai/features/auth/application/auth_providers.dart';
import 'package:taskflow_ai/features/tasks/application/task_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- THIS IS THE FIX ---
    // Watch the new StreamProvider instead of the old FutureProvider.
    final userProfileAsync = ref.watch(userProfileStreamProvider);
    // --- END OF FIX ---

    final tasksAsync = ref.watch(tasksStreamProvider);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: isDarkMode
            ? AppTheme.darkBackgroundGradient
            : AppTheme.lightBackgroundGradient,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              // Header
              userProfileAsync.when(
                data: (user) => Text(
                  'Hello, ${user?.name.split(' ').first ?? 'User'}!',
                  style: GoogleFonts.lato(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                loading: () => const SizedBox(height: 34),
                error: (_, __) => const Text('Hello, User!'),
              ),
              Text(
                'Let\'s make today productive.',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 30),

              // Task Summary Card
              tasksAsync.when(
                data: (tasks) {
                  final dueToday = tasks
                      .where(
                        (t) =>
                            !t.isCompleted &&
                            DateUtils.isSameDay(t.dueDate, DateTime.now()),
                      )
                      .length;
                  return _buildSummaryCard(
                    context: context,
                    icon: Icons.today,
                    title: 'Tasks Due Today',
                    value: dueToday.toString(),
                    color: AppTheme.primaryColor,
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox(),
              ),
              const SizedBox(height: 20),

              // AI Insight Card (Placeholder)
              _buildSummaryCard(
                context: context,
                icon: Icons.lightbulb_outline,
                title: 'AI Insight',
                value: 'Coming Soon',
                color: Colors.amber.shade700,
              ),
              const SizedBox(height: 20),

              // Gamification Card (Placeholder)
              _buildSummaryCard(
                context: context,
                icon: Icons.star_border_purple500_outlined,
                title: 'Points',
                value: '0',
                color: Colors.deepPurple.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.lato(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
