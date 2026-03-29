class WordPair {
  final String civilianWord;
  final String impostorWord;

  const WordPair({required this.civilianWord, required this.impostorWord});

  @override
  bool operator ==(Object other) =>
      other is WordPair &&
      other.civilianWord == civilianWord &&
      other.impostorWord == impostorWord;

  @override
  int get hashCode => Object.hash(civilianWord, impostorWord);
}
