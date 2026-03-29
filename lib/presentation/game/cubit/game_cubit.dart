import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:impostor/domain/model/game_phase.dart';
import 'package:impostor/domain/model/player.dart';
import 'package:impostor/domain/model/word_pair.dart';
import 'package:impostor/domain/service/word_service.dart';
import 'package:flutter/foundation.dart';

part 'game_state.dart';

class GameCubit extends Cubit<GameState> {
  final bool isClueless;
  final WordService wordService;

  GameCubit({
    required this.isClueless,
    WordService? wordService,
  })  : wordService = wordService ?? GetIt.I<WordService>(),
        super(GameInitial());

  void showAddPlayerDialog() {
    if (state is GameInitial) {
      emit(GameInProgress(
        players: [],
        phase: GamePhase.addingPlayers,
        dialogRequest: AddPlayerDialogRequest(),
      ));
    } else {
      final current = state as GameInProgress;
      emit(current.copyWith(dialogRequest: AddPlayerDialogRequest()));
    }
  }

  void addPlayer(String name) {
    if (state is GameInitial) {
      emit(GameInProgress(
        players: [Player.firstCreate(name: name)],
        phase: GamePhase.addingPlayers,
      ));
    } else if (state is GameInProgress) {
      final current = state as GameInProgress;
      final updatedPlayers = List<Player>.from(current.players)
        ..add(Player.firstCreate(name: name));
      emit(current.copyWith(players: updatedPlayers, clearDialog: true));
    }
  }

  void removePlayer(int index) {
    if (state is! GameInProgress) return;
    final current = state as GameInProgress;
    if (current.phase != GamePhase.addingPlayers) return;
    final updatedPlayers = List<Player>.from(current.players)..removeAt(index);
    emit(current.copyWith(players: updatedPlayers, clearDialog: true));
  }

  void requestRemovePlayer(int index) {
    if (state is! GameInProgress) return;
    final current = state as GameInProgress;
    if (current.phase != GamePhase.addingPlayers) return;
    emit(current.copyWith(
      dialogRequest: RemovePlayerDialogRequest(
        current.players[index].name,
        index,
      ),
    ));
  }

  void clearDialog() {
    if (state is GameInProgress) {
      final current = state as GameInProgress;
      emit(current.copyWith(clearDialog: true));
    }
  }

  Future<void> startGame() async {
    if (state is! GameInProgress) return;
    final current = state as GameInProgress;

    emit(current.copyWith(phase: GamePhase.loading, clearDialog: true));

    late final WordPair wordPair;
    try {
      wordPair = await wordService.generateWordPair();
    } catch (_) {
      emit((state as GameInProgress).copyWith(
        dialogRequest: GenerationErrorDialogRequest(),
      ));
      return;
    }

    final impostorIndex = Random().nextInt(current.players.length);
    final updatedPlayers = current.players.asMap().entries.map((entry) {
      final isImpostor = entry.key == impostorIndex;
      return entry.value.copyWith(
        word: isImpostor ? wordPair.impostorWord : wordPair.civilianWord,
        isImpostor: isImpostor,
        isEliminated: false,
        hasSeenWord: false,
      );
    }).toList();

    emit(GameInProgress(
      players: updatedPlayers,
      phase: GamePhase.dealingWords,
      wordPair: wordPair,
    ));
  }

  void showWord(int index) {
    if (state is! GameInProgress) return;
    final current = state as GameInProgress;
    if (current.phase != GamePhase.dealingWords) return;
    if (current.players[index].hasSeenWord) return;

    final player = current.players[index];

    if (!isClueless && player.isImpostor) {
      emit(current.copyWith(
        dialogRequest: InsidiousImpostorRevealDialogRequest(index),
      ));
    } else {
      emit(current.copyWith(
        dialogRequest: ShowWordDialogRequest(player.word, index),
      ));
    }
  }

  void confirmWordSeen(int playerIndex) {
    if (state is! GameInProgress) return;
    final current = state as GameInProgress;

    final updatedPlayers = List<Player>.from(current.players);
    updatedPlayers[playerIndex] =
        updatedPlayers[playerIndex].copyWith(hasSeenWord: true);

    final allSeen = updatedPlayers.every((p) => p.hasSeenWord);

    emit(GameInProgress(
      players: updatedPlayers,
      phase: allSeen ? GamePhase.voting : GamePhase.dealingWords,
      wordPair: current.wordPair,
    ));
  }

  void requestElimination(int index) {
    if (state is! GameInProgress) return;
    final current = state as GameInProgress;
    if (current.phase != GamePhase.voting) return;
    if (current.players[index].isEliminated) return;

    emit(current.copyWith(
      dialogRequest: ConfirmEliminationDialogRequest(
        current.players[index].name,
        index,
      ),
    ));
  }

  void confirmElimination(int index) {
    if (state is! GameInProgress) return;
    final current = state as GameInProgress;

    final updatedPlayers = List<Player>.from(current.players);
    updatedPlayers[index] =
        updatedPlayers[index].copyWith(isEliminated: true);

    final votedPlayer = updatedPlayers[index];
    final activePlayers =
        updatedPlayers.where((p) => !p.isEliminated).toList();

    if (votedPlayer.isImpostor) {
      emit(GameInProgress(
        players: updatedPlayers,
        phase: GamePhase.roundOver,
        wordPair: current.wordPair,
        dialogRequest: RoundResultDialogRequest(
          message: '${votedPlayer.name} was the impostor!',
          players: updatedPlayers,
        ),
      ));
    } else if (activePlayers.length == 2) {
      final impostorIndex = updatedPlayers.indexWhere((p) => p.isImpostor);
      final newPoints = updatedPlayers[impostorIndex].points + 1;
      updatedPlayers[impostorIndex] =
          updatedPlayers[impostorIndex].copyWith(points: newPoints);
      final winner = updatedPlayers[impostorIndex];

      emit(GameInProgress(
        players: updatedPlayers,
        phase: GamePhase.roundOver,
        wordPair: current.wordPair,
        dialogRequest: RoundResultDialogRequest(
          message: '${winner.name} wins this round!',
          players: updatedPlayers,
        ),
      ));
    } else {
      emit(GameInProgress(
        players: updatedPlayers,
        phase: GamePhase.voting,
        wordPair: current.wordPair,
        dialogRequest: NonEndingEliminationDialogRequest(
          playerName: votedPlayer.name,
        ),
      ));
    }
  }

  void dismissRoundResult() {
    if (state is! GameInProgress) return;
    final current = state as GameInProgress;
    emit(current.copyWith(dialogRequest: QualityCheckDialogRequest()));
  }

  void submitQualityCheck({required bool isGood}) {
    // Plan 3: if isGood, write wordPair to Firebase
    _resetToAddingPlayers();
  }

  void requestAbandonRound() {
    if (state is! GameInProgress) return;
    final current = state as GameInProgress;
    emit(current.copyWith(dialogRequest: AbandonRoundDialogRequest()));
  }

  void abandonRound() {
    _resetToAddingPlayers();
  }

  void _resetToAddingPlayers() {
    if (state is! GameInProgress) return;
    final current = state as GameInProgress;
    final resetPlayers = current.players
        .map((p) => p.copyWith(
              word: '',
              isImpostor: false,
              isEliminated: false,
              hasSeenWord: false,
            ))
        .toList();
    emit(GameInProgress(
      players: resetPlayers,
      phase: GamePhase.addingPlayers,
    ));
  }
}
