import 'package:impostor/domain/model/word_pair.dart';
import 'package:impostor/domain/service/word_service.dart';

class MockWordService implements WordService {
  @override
  Future<WordPair> generateWordPair() async {
    return const WordPair(civilianWord: 'Apple', impostorWord: 'Banana');
  }
}
