import 'package:impostor/domain/model/word_pair.dart';

abstract class WordService {
  Future<WordPair> generateWordPair();

  /// Translates a round word to Croatian for the reveal-screen toggle.
  /// Display-only — game state and Firestore always keep the English word.
  Future<String> translateToCroatian(String word);
}
