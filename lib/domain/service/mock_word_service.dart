import 'package:impostor/domain/model/word_pair.dart';
import 'package:impostor/domain/service/word_service.dart';

class MockWordService implements WordService {
  @override
  Future<WordPair> generateWordPair() async {
    return const WordPair(civilianWord: 'Apple', impostorWord: 'Banana');
  }

  @override
  Future<String> translateToCroatian(String word) async {
    return word == 'Apple' ? 'Jabuka' : 'Banana';
  }
}
