import 'package:impostor/domain/model/word_pair.dart';

abstract class WordService {
  Future<WordPair> generateWordPair();
}
