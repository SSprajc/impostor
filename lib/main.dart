import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:impostor/domain/service/firebase_round_feedback_service.dart';
import 'package:impostor/domain/service/gemini_word_service.dart';
import 'package:impostor/domain/service/round_feedback_service.dart';
import 'package:impostor/domain/service/word_service.dart';
import 'package:impostor/firebase_options.dart';
import 'package:impostor/presentation/common/impostor_theme.dart';
import 'package:impostor/presentation/menu/menu_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  const apiKey = String.fromEnvironment('GEMINI_API_KEY');
  if (apiKey.isEmpty) {
    throw StateError(
      'GEMINI_API_KEY not set. '
      'Run with: flutter run --dart-define=GEMINI_API_KEY=your_key',
    );
  }
  GetIt.I.registerSingleton<WordService>(GeminiWordService(apiKey: apiKey));
  GetIt.I.registerSingleton<RoundFeedbackService>(
    FirebaseRoundFeedbackService(),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Impostor',
      theme: ImpTheme.themeData,
      home: const MenuView(),
    );
  }
}