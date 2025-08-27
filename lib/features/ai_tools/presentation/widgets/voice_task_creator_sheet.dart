import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool _speechEnabled = false;
  String _lastWords = '';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isProcessing = true;
    });

    final parsedData = await ref
        .read(aiControllerProvider.notifier)
        .parseTextToTask(
          text: _lastWords,
          onError: (error) {
            // This check is important to prevent errors if the widget is disposed.
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: Could not process voice command.'),
                  backgroundColor: Colors.red,
                ),
              );
              // --- THIS IS THE CRITICAL CHANGE ---
              // Directly reset the processing state here to ensure the UI updates.
              setState(() {
                _isProcessing = false;
              });
              // --- END OF CHANGE ---
            }
          },
        );

    if (parsedData != null && mounted) {
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AddEditTaskScreen(parsedTaskData: parsedData),
        ),
      );
    }
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
                : _speechEnabled
                ? 'Tap the mic to start'
                : 'Speech not available',
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
          // Show a spinner if processing, otherwise show the mic button.
          if (_isProcessing)
            const CircularProgressIndicator()
          else
            FloatingActionButton(
              onPressed: _speechToText.isListening
                  ? _stopListening
                  : _startListening,
              tooltip: 'Listen',
              child: Icon(
                _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
              ),
            ),
        ],
      ),
    );
  }
}
