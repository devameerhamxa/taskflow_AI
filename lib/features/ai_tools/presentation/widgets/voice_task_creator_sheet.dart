// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:taskflow_ai/features/ai_tools/application/ai_providers.dart';
import 'package:taskflow_ai/features/tasks/presentation/screens/add_edit_task_screen.dart';

class VoiceTaskCreatorSheet extends ConsumerStatefulWidget {
  const VoiceTaskCreatorSheet({super.key});

  @override
  ConsumerState<VoiceTaskCreatorSheet> createState() =>
      _VoiceTaskCreatorSheetState();
}

class _VoiceTaskCreatorSheetState extends ConsumerState<VoiceTaskCreatorSheet> {
  final SpeechToText _speechToText = SpeechToText();
  String _lastWords = '';
  bool _isProcessing = false;
  bool _permissionsGranted = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      _permissionsGranted = true;
    } else {
      _permissionsGranted = false;
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _startListening() async {
    if (!_permissionsGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required.')),
      );
      return;
    }
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();

    // Only proceed if we have captured some words
    if (_lastWords.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No speech detected. Please try again.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Set the UI to processing immediately
    setState(() {
      _isProcessing = true;
    });

    // Call the AI processing logic and wait for it to complete.

    ref
        .read(aiControllerProvider.notifier)
        .parseTextToTask(
          text: _lastWords,
          onError: (error) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $error'),
                  backgroundColor: Colors.red,
                ),
              );
              log("'Error: $error'");

              // On error, ensure we stop the processing state.
              setState(() {
                _isProcessing = false;
              });
            }
          },
        )
        .then((parsedData) {
          // This block runs only after the async operation is fully complete.
          if (parsedData != null && mounted) {
            // If successful, navigate away.
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AddEditTaskScreen(parsedTaskData: parsedData),
              ),
            );
          } else if (mounted) {
            // If it fails for any other reason, ensure we stop the processing state.
            setState(() {
              _isProcessing = false;
            });
          }
        });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24.0),
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            _isProcessing
                ? 'Processing...'
                : _speechToText.isListening
                ? 'Listening...'
                : _permissionsGranted
                ? 'Tap the mic to start'
                : 'Microphone permission needed',
            style: GoogleFonts.lato(textStyle: theme.textTheme.headlineSmall),
          ),
          Expanded(
            child: Center(
              child: Text(
                _lastWords,
                style: GoogleFonts.lato(textStyle: theme.textTheme.bodyLarge),
              ),
            ),
          ),
          if (_isProcessing)
            const CircularProgressIndicator()
          else
            FloatingActionButton(
              onPressed: _speechToText.isListening
                  ? _stopListening
                  : _startListening,
              tooltip: 'Listen',
              backgroundColor: _permissionsGranted
                  ? theme.primaryColor
                  : Colors.grey,
              child: Icon(
                _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
              ),
            ),
        ],
      ),
    );
  }
}
