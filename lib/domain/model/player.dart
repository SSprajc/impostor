class Player {
  final String name;
  final int points;
  final String word;
  final bool isImpostor;
  final bool isEliminated;
  final bool hasSeenWord;

  const Player({
    required this.name,
    this.points = 0,
    this.word = '',
    this.isImpostor = false,
    this.isEliminated = false,
    this.hasSeenWord = false,
  });

  Player copyWith({
    String? name,
    int? points,
    String? word,
    bool? hasSeenWord,
    bool? isEliminated,
    bool? isImpostor,
  }) {
    return Player(
      name: name ?? this.name,
      points: points ?? this.points,
      word: word ?? this.word,
      isImpostor: isImpostor ?? this.isImpostor,
      isEliminated: isEliminated ?? this.isEliminated,
      hasSeenWord: hasSeenWord ?? this.hasSeenWord,
    );
  }
}
