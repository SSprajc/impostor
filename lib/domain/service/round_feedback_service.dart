import 'package:impostor/domain/model/word_pair.dart';

abstract class RoundFeedbackService {
  Future<void> saveApprovedWordPair({
    required WordPair wordPair,
    required String gameMode,
  });
}
