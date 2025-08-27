import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taskflow_ai/core/constants/app_theme.dart';
import 'package:taskflow_ai/features/ai_tools/presentation/widgets/voice_task_creator_sheet.dart';
import 'package:taskflow_ai/features/tasks/application/task_providers.dart';
import 'package:taskflow_ai/features/tasks/presentation/screens/add_edit_task_screen.dart';
import 'package:taskflow_ai/features/tasks/presentation/widgets/task_tile.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsyncValue = ref.watch(tasksStreamProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Tasks',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
        // We removed the logout button from here since it's on the dashboard
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: tasksAsyncValue.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 80,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tasks yet!',
                    style: GoogleFonts.lato(
                      textStyle: theme.textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add a task manually,\nor the microphone to add by voice.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      textStyle: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskTile(task: task);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      // Use a Row to have two FloatingActionButtons
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'manualAddTaskBtn', // Hero tags must be unique
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
              );
            },
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'voiceAddTaskBtn',
            onPressed: () {
              // Show the voice input bottom sheet
              showModalBottomSheet(
                context: context,
                builder: (context) => const VoiceTaskCreatorSheet(),
              );
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.mic, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
