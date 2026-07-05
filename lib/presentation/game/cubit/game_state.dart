part of 'game_cubit.dart';

@immutable
sealed class DialogRequest {}

class AddPlayerDialogRequest extends DialogRequest {}

class RemovePlayerDialogRequest extends DialogRequest {
  final String playerName;
  final int playerIndex;
  RemovePlayerDialogRequest({required this.playerName, required this.playerIndex});
}

class ShowWordDialogRequest extends DialogRequest {
  final String word;
  final String playerName;
  final int playerIndex;
  ShowWordDialogRequest({
    required this.word,
    required this.playerName,
    required this.playerIndex,
  });
}

class InsidiousImpostorRevealDialogRequest extends DialogRequest {
  final String playerName;
  final int playerIndex;
  InsidiousImpostorRevealDialogRequest({
    required this.playerName,
    required this.playerIndex,
  });
}

class ConfirmEliminationDialogRequest extends DialogRequest {
  final String playerName;
  final int playerIndex;
  ConfirmEliminationDialogRequest({
    required this.playerName,
    required this.playerIndex,
  });
}

class NonEndingEliminationDialogRequest extends DialogRequest {
  final String playerName;
  NonEndingEliminationDialogRequest({required this.playerName});
}

class RoundResultDialogRequest extends DialogRequest {
  final String message;
  final List<Player> players;
  RoundResultDialogRequest({required this.message, required this.players});
}

class QualityCheckDialogRequest extends DialogRequest {}

class GenerationErrorDialogRequest extends DialogRequest {}

class AbandonRoundDialogRequest extends DialogRequest {}

@immutable
class GameState {
  final List<Player> players;
  final GamePhase phase;
  final WordPair? wordPair;
  final DialogRequest? dialogRequest;

  const GameState({
    this.players = const [],
    this.phase = GamePhase.addingPlayers,
    this.wordPair,
    this.dialogRequest,
  });

  GameState copyWith({
    List<Player>? players,
    GamePhase? phase,
    WordPair? wordPair,
    DialogRequest? dialogRequest,
    bool clearDialog = false,
  }) {
    return GameState(
      players: players ?? this.players,
      phase: phase ?? this.phase,
      wordPair: wordPair ?? this.wordPair,
      dialogRequest: clearDialog ? null : (dialogRequest ?? this.dialogRequest),
    );
  }
}
