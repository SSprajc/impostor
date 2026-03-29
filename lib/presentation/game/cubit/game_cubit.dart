import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:impostor/domain/model/game_phase.dart';
import 'package:impostor/domain/model/player.dart';
import 'package:impostor/domain/model/word_pair.dart';
import 'package:meta/meta.dart';

part 'game_state.dart';

class GameCubit extends Cubit<GameState> {
  final bool isClueless;

  GameCubit({required this.isClueless}) : super(GameInitial());

  void showAddPlayerDialog() {
    if (state is GameInitial) {
      emit(
        GameInProgress(
          players: [],
          phase: GamePhase.addingPlayers,
          dialogRequest: AddPlayerDialogRequest(),
        ),
      );
    } else {
      final current = state as GameInProgress;
      emit(current.copyWith(dialogRequest: AddPlayerDialogRequest()));
    }
  }

  void addPlayer(String name) {
    if (state is GameInitial) {
      emit(
        GameInProgress(
          players: [Player.firstCreate(name: name)],
          phase: GamePhase.addingPlayers,
        ),
      );
    } else if (state is GameInProgress) {
      final current = state as GameInProgress;
      final updatedPlayers = List<Player>.from(current.players)
        ..add(Player.firstCreate(name: name));
      emit(current.copyWith(players: updatedPlayers, clearDialog: true));
    }
  }

  void clearDialog() {
    if (state is GameInProgress) {
      final current = state as GameInProgress;
      emit(current.copyWith(clearDialog: true));
    }
  }

  void startGame() {
    if (state is! GameInProgress) return;
    final current = state as GameInProgress;

    final impostorIndex = Random().nextInt(current.players.length);
    final normalWord = 'Apple';
    final impostorWord = 'Banana';

    final updatedPlayers = current.players.asMap().entries.map((entry) {
      final isImpostor = entry.key == impostorIndex;
      return entry.value.copyWith(
        word: isImpostor ? impostorWord : normalWord,
        isImpostor: isImpostor,
        isEliminated: false,
        hasSeenWord: false,
      );
    }).toList();

    emit(
      GameInProgress(players: updatedPlayers, phase: GamePhase.dealingWords),
    );
  }

  void showWord(int index) {
    if (state is! GameInProgress) return;
    final current = state as GameInProgress;
    if (current.phase != GamePhase.dealingWords) return;
    if (current.players[index].hasSeenWord) return;

    final player = current.players[index];
    emit(
      current.copyWith(
        dialogRequest: ShowWordDialogRequest(player.word, index),
      ),
    );
  }

  void confirmWordSeen(int playerIndex) {
    if (state is! GameInProgress) return;
    final current = state as GameInProgress;

    final updatedPlayers = List<Player>.from(current.players);
    updatedPlayers[playerIndex] = updatedPlayers[playerIndex].copyWith(
      hasSeenWord: true,
    );

    final allSeen = updatedPlayers.every((p) => p.hasSeenWord);

    emit(
      GameInProgress(
        players: updatedPlayers,
        phase: allSeen ? GamePhase.voting : GamePhase.dealingWords,
      ),
    );
  }

  void requestElimination(int index) {
    if (state is! GameInProgress) return;
    final current = state as GameInProgress;
    if (current.phase != GamePhase.voting) return;
    if (current.players[index].isEliminated) return;

    emit(
      current.copyWith(
        dialogRequest: ConfirmEliminationDialogRequest(
          current.players[index].name,
          index,
        ),
      ),
    );
  }

  void confirmElimination(int index) {
    if (state is! GameInProgress) return;
    final current = state as GameInProgress;

    final updatedPlayers = List<Player>.from(current.players);
    updatedPlayers[index] = updatedPlayers[index].copyWith(isEliminated: true);

    final votedPlayer = updatedPlayers[index];
    final activePlayers = updatedPlayers.where((p) => !p.isEliminated).toList();

    if (votedPlayer.isImpostor) {
      emit(
        GameInProgress(
          players: updatedPlayers,
          phase: GamePhase.roundOver,
          dialogRequest: RoundResultDialogRequest(
            message: '${votedPlayer.name} is the impostor',
            players: updatedPlayers,
          ),
        ),
      );
    } else if (activePlayers.length == 2) {
      final impostorIndex = updatedPlayers.indexWhere((p) => p.isImpostor);
      final newPoints = updatedPlayers[impostorIndex].points + 1;
      updatedPlayers[impostorIndex] = updatedPlayers[impostorIndex].copyWith(
        points: newPoints,
      );
      final winner = updatedPlayers[impostorIndex];

      emit(GameInProgress(
        players: updatedPlayers,
        phase: GamePhase.roundOver,
        dialogRequest: RoundResultDialogRequest(
          message: '${winner.name} is the fcking impostor! \n${winner.name}: $newPoints',
          players: updatedPlayers,
        ),
      ));
    } else {
      emit(
        GameInProgress(
          players: updatedPlayers,
          phase: GamePhase.voting,
          dialogRequest: NonEndingEliminationDialogRequest(playerName: votedPlayer.name),
        ),
      );
    }
  }
}
