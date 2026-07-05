import 'dart:convert';
import 'dart:math';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:impostor/domain/model/word_pair.dart';
import 'package:impostor/domain/service/word_service.dart';

class GeminiWordService implements WordService {
  static const _categories = [
    'animals',
    'fruits',
    'vegetables',
    'sea creatures',
    'birds',
    'insects',
    'dog breeds',
    'cat breeds',
    'flowers',
    'trees',
    'kitchen utensils',
    'musical instruments',
    'sports',
    'board games',
    'card games',
    'vehicles',
    'tools',
    'furniture',
    'clothing',
    'shoes',
    'desserts',
    'drinks',
    'cheeses',
    'pasta shapes',
    'spices',
    'gemstones',
    'metals',
    'planets',
    'weather phenomena',
    'dances',
    'martial arts',
    'fabrics',
    'currencies',
    'languages',
    'mythological creatures',
    'professions',
    'fairy tale characters',
    'horror monsters',
    'weapons',
    'castles and fortresses',
  ];

  final GenerativeModel _model;
  final Random _random;

  GeminiWordService({required String apiKey, Random? random})
      : _random = random ?? Random(),
        _model = GenerativeModel(
          model: 'gemini-2.5-flash',
          apiKey: apiKey,
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
            temperature: 1.0,
          ),
        );

  @override
  Future<WordPair> generateWordPair() async {
    final category = _categories[_random.nextInt(_categories.length)];

    final response = await _model.generateContent([
      Content.text(
        'Generate a word pair for a social deduction game. '
        'Both words must be from the category "$category". '
        'The words should be in English, plausible within the same category, '
        'but clearly distinct from each other (e.g. "shark" and "dolphin"). '
        'Avoid overly obscure words — players should recognize both.\n\n'
        'Respond with JSON: {"civilianWord": "...", "impostorWord": "..."}',
      ),
    ]);

    final text = response.text;
    if (text == null) {
      throw Exception('Gemini returned an empty response');
    }

    final json = jsonDecode(text) as Map<String, dynamic>;
    final civilianWord = json['civilianWord'] as String?;
    final impostorWord = json['impostorWord'] as String?;

    if (civilianWord == null || impostorWord == null) {
      throw Exception('Gemini response missing required fields: $text');
    }

    return WordPair(civilianWord: civilianWord, impostorWord: impostorWord);
  }

  // Same English word always maps to the same Croatian one, so the cache is
  // never invalidated — later players tapping the same round word hit it.
  final _translationCache = <String, String>{};

  @override
  Future<String> translateToCroatian(String word) async {
    final cached = _translationCache[word.toLowerCase()];
    if (cached != null) return cached;

    final response = await _model.generateContent(
      [
        Content.text(
          'Translate the English word "$word" into Croatian. '
          'It is a common noun from a party game (categories like animals, '
          'food, objects, professions). Give the single most natural '
          'everyday Croatian term a native speaker would use — if the '
          'English word is ambiguous, pick its most common noun meaning. '
          'No explanations.\n\n'
          'Respond with JSON: {"translation": "..."}',
        ),
      ],
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.1,
      ),
    );

    final text = response.text;
    if (text == null) {
      throw Exception('Gemini returned an empty response');
    }

    final json = jsonDecode(text) as Map<String, dynamic>;
    final translation = json['translation'] as String?;
    if (translation == null || translation.trim().isEmpty) {
      throw Exception('Gemini response missing translation: $text');
    }

    return _translationCache[word.toLowerCase()] = translation.trim();
  }
}
