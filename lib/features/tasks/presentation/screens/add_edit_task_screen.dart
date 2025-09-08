import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:taskflow_ai/core/constants/app_theme.dart';
import 'package:taskflow_ai/features/ai_tools/domain/parsed_task_data_model.dart';
import 'package:taskflow_ai/features/tasks/application/task_providers.dart';
import 'package:taskflow_ai/features/tasks/domain/task_model.dart';

class AddEditTaskScreen extends ConsumerStatefulWidget {
  final Task? task;
  final ParsedTaskData? parsedTaskData;

  const AddEditTaskScreen({super.key, this.task, this.parsedTaskData});

  @override
  ConsumerState<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends ConsumerState<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _dueDate;
  late TaskPriority _priority;

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.parsedTaskData?.title ?? widget.task?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _dueDate =
        widget.parsedTaskData?.dueDate ??
        widget.task?.dueDate ??
        DateTime.now().add(const Duration(days: 1));
    _priority =
        widget.parsedTaskData?.priority ??
        widget.task?.priority ??
        TaskPriority.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final taskNotifier = ref.read(taskControllerProvider.notifier);
      if (isEditing) {
        final updatedTask = widget.task!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dueDate: _dueDate,
          priority: _priority,
        );
        taskNotifier.updateTask(
          updatedTask: updatedTask,
          onError: _showErrorSnackbar,
        );
      } else {
        taskNotifier.createTask(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dueDate: _dueDate,
          priority: _priority,
          onError: _showErrorSnackbar,
        );
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(taskControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Task' : 'Add Task',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                ref
                    .read(taskControllerProvider.notifier)
                    .deleteTask(
                      taskId: widget.task!.id,
                      onError: _showErrorSnackbar,
                    );
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: GoogleFonts.poppins(),
                ),
                style: GoogleFonts.poppins(),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: GoogleFonts.poppins(),
                ),
                style: GoogleFonts.poppins(),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Text(
                'Due Date',
                style: GoogleFonts.poppins(
                  textStyle: theme.textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDueDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat.yMMMd().format(_dueDate),
                        style: GoogleFonts.poppins(),
                      ),
                      const Icon(Icons.calendar_today_outlined),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Priority',
                style: GoogleFonts.poppins(
                  textStyle: theme.textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<TaskPriority>(
                segments: [
                  ButtonSegment(
                    value: TaskPriority.low,
                    label: Text('Low', style: GoogleFonts.poppins()),
                  ),
                  ButtonSegment(
                    value: TaskPriority.medium,
                    label: Text('Medium', style: GoogleFonts.poppins()),
                  ),
                  ButtonSegment(
                    value: TaskPriority.high,
                    label: Text('High', style: GoogleFonts.poppins()),
                  ),
                ],
                selected: {_priority},
                onSelectionChanged: (Set<TaskPriority> newSelection) {
                  setState(() {
                    _priority = newSelection.first;
                  });
                },
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: AppTheme.priorityColor(_priority),
                  selectedForegroundColor: Colors.white,
                  textStyle: GoogleFonts.poppins(),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: isLoading ? null : _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isEditing ? 'Save Changes' : 'Add Task',
                        style: GoogleFonts.poppins(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
