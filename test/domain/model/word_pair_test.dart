import 'package:flutter_test/flutter_test.dart';
import 'package:impostor/domain/model/word_pair.dart';

void main() {
  group('WordPair', () {
    test('stores civilian and impostor words', () {
      const pair = WordPair(civilianWord: 'shark', impostorWord: 'dolphin');
      expect(pair.civilianWord, 'shark');
      expect(pair.impostorWord, 'dolphin');
    });

    test('equality by value', () {
      const a = WordPair(civilianWord: 'shark', impostorWord: 'dolphin');
      const b = WordPair(civilianWord: 'shark', impostorWord: 'dolphin');
      expect(a, equals(b));
    });
  });
}
