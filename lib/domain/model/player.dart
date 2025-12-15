class Player {
  final String name;
  final bool isImpostor;
  final bool isEliminated;
  final int points;

  Player({
    required this.name,
    required this.points,
    required this.isEliminated,
    required this.isImpostor,
  });

  Player.firstCreate({
    required this.name,
    this.points = 0,
    this.isEliminated = false,
    this.isImpostor = false,
  });

}
