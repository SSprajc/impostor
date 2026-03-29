part of 'game_cubit.dart';

@immutable
sealed class DialogRequest {}

class AddPlayerDialogRequest extends DialogRequest {}

class RemovePlayerDialogRequest extends DialogRequest {
  final String playerName;
  final int playerIndex;
  RemovePlayerDialogRequest(this.playerName, this.playerIndex);
}

class ShowWordDialogRequest extends DialogRequest {
  final String word;
  final int index;
  ShowWordDialogRequest(this.word, this.index);
}

class InsidiousImpostorRevealDialogRequest extends DialogRequest {
  final int playerIndex;
  InsidiousImpostorRevealDialogRequest(this.playerIndex);
}

class ConfirmEliminationDialogRequest extends DialogRequest {
  final int playerIndex;
  final String playerName;
  ConfirmEliminationDialogRequest(this.playerName, this.playerIndex);
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
sealed class GameState {}

final class GameInitial extends GameState {}

final class GameInProgress extends GameState {
  final List<Player> players;
  final GamePhase phase;
  final WordPair? wordPair;
  final DialogRequest? dialogRequest;

  GameInProgress({
    required this.players,
    required this.phase,
    this.wordPair,
    this.dialogRequest,
  });

  GameInProgress copyWith({
    List<Player>? players,
    GamePhase? phase,
    WordPair? wordPair,
    DialogRequest? dialogRequest,
    bool clearDialog = false,
  }) {
    return GameInProgress(
      players: players ?? this.players,
      phase: phase ?? this.phase,
      wordPair: wordPair ?? this.wordPair,
      dialogRequest: clearDialog ? null : (dialogRequest ?? this.dialogRequest),
    );
  }
}
