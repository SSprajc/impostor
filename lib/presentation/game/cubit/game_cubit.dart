import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:impostor/domain/model/game_phase.dart';
import 'package:impostor/domain/model/player.dart';
import 'package:impostor/domain/model/word_pair.dart';
import 'package:impostor/domain/service/round_feedback_service.dart';
import 'package:impostor/domain/service/word_service.dart';

part 'game_state.dart';

class GameCubit extends Cubit<GameState> {
  final bool isClueless;
  final WordService wordService;
  final RoundFeedbackService roundFeedbackService;

  GameCubit({
    required this.isClueless,
    WordService? wordService,
    RoundFeedbackService? roundFeedbackService,
  })  : wordService = wordService ?? GetIt.I<WordService>(),
        roundFeedbackService =
            roundFeedbackService ?? GetIt.I<RoundFeedbackService>(),
        super(const GameState());

  void showAddPlayerDialog() {
    if (state.phase != GamePhase.addingPlayers) return;
    emit(state.copyWith(dialogRequest: AddPlayerDialogRequest()));
  }

  void addPlayer(String name) {
    if (state.phase != GamePhase.addingPlayers) return;
    emit(state.copyWith(
      players: [...state.players, Player(name: name)],
      clearDialog: true,
    ));
  }

  void removePlayer(int index) {
    if (state.phase != GamePhase.addingPlayers) return;
    emit(state.copyWith(
      players: List<Player>.from(state.players)..removeAt(index),
      clearDialog: true,
    ));
  }

  void requestRemovePlayer(int index) {
    if (state.phase != GamePhase.addingPlayers) return;
    emit(state.copyWith(
      dialogRequest: RemovePlayerDialogRequest(
        playerName: state.players[index].name,
        playerIndex: index,
      ),
    ));
  }

  void clearDialog() {
    emit(state.copyWith(clearDialog: true));
  }

  Future<void> startGame() async {
    emit(state.copyWith(phase: GamePhase.loading, clearDialog: true));

    final WordPair wordPair;
    try {
      wordPair = await wordService.generateWordPair();
    } catch (_) {
      if (state.phase != GamePhase.loading) return;
      emit(state.copyWith(dialogRequest: GenerationErrorDialogRequest()));
      return;
    }

    // Round may have been abandoned while the word pair was generating.
    if (state.phase != GamePhase.loading) return;

    final impostorIndex = Random().nextInt(state.players.length);
    final updatedPlayers = [
      for (final (index, player) in state.players.indexed)
        player.copyWith(
          word: index == impostorIndex
              ? wordPair.impostorWord
              : wordPair.civilianWord,
          isImpostor: index == impostorIndex,
          isEliminated: false,
          hasSeenWord: false,
        ),
    ];

    emit(GameState(
      players: updatedPlayers,
      phase: GamePhase.dealingWords,
      wordPair: wordPair,
    ));
  }

  void showWord(int index) {
    if (state.phase != GamePhase.dealingWords) return;
    final player = state.players[index];
    if (player.hasSeenWord) return;

    if (!isClueless && player.isImpostor) {
      emit(state.copyWith(
        dialogRequest: InsidiousImpostorRevealDialogRequest(
          playerName: player.name,
          playerIndex: index,
        ),
      ));
    } else {
      emit(state.copyWith(
        dialogRequest: ShowWordDialogRequest(
          word: player.word,
          playerName: player.name,
          playerIndex: index,
        ),
      ));
    }
  }

  void confirmWordSeen(int playerIndex) {
    if (state.phase != GamePhase.dealingWords) return;

    final updatedPlayers = List<Player>.from(state.players);
    updatedPlayers[playerIndex] =
        updatedPlayers[playerIndex].copyWith(hasSeenWord: true);

    final allSeen = updatedPlayers.every((p) => p.hasSeenWord);

    emit(GameState(
      players: updatedPlayers,
      phase: allSeen ? GamePhase.voting : GamePhase.dealingWords,
      wordPair: state.wordPair,
    ));
  }

  void requestElimination(int index) {
    if (state.phase != GamePhase.voting) return;
    if (state.players[index].isEliminated) return;

    emit(state.copyWith(
      dialogRequest: ConfirmEliminationDialogRequest(
        playerName: state.players[index].name,
        playerIndex: index,
      ),
    ));
  }

  void confirmElimination(int index) {
    if (state.phase != GamePhase.voting) return;

    final updatedPlayers = List<Player>.from(state.players);
    updatedPlayers[index] = updatedPlayers[index].copyWith(isEliminated: true);

    final votedPlayer = updatedPlayers[index];
    final activeCount = updatedPlayers.where((p) => !p.isEliminated).length;

    if (votedPlayer.isImpostor) {
      emit(GameState(
        players: updatedPlayers,
        phase: GamePhase.roundOver,
        wordPair: state.wordPair,
        dialogRequest: RoundResultDialogRequest(
          message: '${votedPlayer.name} was the impostor!',
          players: updatedPlayers,
        ),
      ));
    } else if (activeCount == 2) {
      final impostorIndex = updatedPlayers.indexWhere((p) => p.isImpostor);
      final impostor = updatedPlayers[impostorIndex]
          .copyWith(points: updatedPlayers[impostorIndex].points + 1);
      updatedPlayers[impostorIndex] = impostor;

      emit(GameState(
        players: updatedPlayers,
        phase: GamePhase.roundOver,
        wordPair: state.wordPair,
        dialogRequest: RoundResultDialogRequest(
          message: '${impostor.name} wins this round!',
          players: updatedPlayers,
        ),
      ));
    } else {
      emit(GameState(
        players: updatedPlayers,
        phase: GamePhase.voting,
        wordPair: state.wordPair,
        dialogRequest: NonEndingEliminationDialogRequest(
          playerName: votedPlayer.name,
        ),
      ));
    }
  }

  void dismissRoundResult() {
    emit(state.copyWith(dialogRequest: QualityCheckDialogRequest()));
  }

  void submitQualityCheck({required bool isGood}) {
    final wordPair = state.wordPair;
    if (isGood && wordPair != null) {
      // In Insidious mode the impostor never sees a word, so the pair is
      // stored with the literal marker "impostor" instead.
      final savedPair = isClueless
          ? wordPair
          : WordPair(civilianWord: wordPair.civilianWord, impostorWord: 'impostor');
      roundFeedbackService
          .saveApprovedWordPair(
            wordPair: savedPair,
            gameMode: isClueless ? 'clueless' : 'insidious',
          )
          .catchError((_) {});
    }
    _resetToAddingPlayers();
  }

  void requestAbandonRound() {
    emit(state.copyWith(dialogRequest: AbandonRoundDialogRequest()));
  }

  void abandonRound() {
    _resetToAddingPlayers();
  }

  void _resetToAddingPlayers() {
    emit(GameState(
      players: [
        for (final p in state.players)
          Player(name: p.name, points: p.points),
      ],
    ));
  }
}
