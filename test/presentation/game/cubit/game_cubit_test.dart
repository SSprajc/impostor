import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impostor/domain/model/game_phase.dart';
import 'package:impostor/domain/model/player.dart';
import 'package:impostor/domain/model/word_pair.dart';
import 'package:impostor/domain/service/mock_word_service.dart';
import 'package:impostor/domain/service/round_feedback_service.dart';
import 'package:impostor/domain/service/word_service.dart';
import 'package:impostor/presentation/game/cubit/game_cubit.dart';

class _FakeRoundFeedbackService implements RoundFeedbackService {
  @override
  Future<void> saveApprovedWordPair({
    required WordPair wordPair,
    required String gameMode,
  }) async {}
}

class _ControlledWordService implements WordService {
  final completer = Completer<WordPair>();

  @override
  Future<WordPair> generateWordPair() => completer.future;
}

GameCubit _cubit({bool isClueless = true, WordService? wordService}) =>
    GameCubit(
      isClueless: isClueless,
      wordService: wordService ?? MockWordService(),
      roundFeedbackService: _FakeRoundFeedbackService(),
    );

void main() {
  group('removePlayer', () {
    blocTest<GameCubit, GameState>(
      'removes player by index during addingPlayers phase',
      build: _cubit,
      seed: () => const GameState(
        players: [Player(name: 'Alice'), Player(name: 'Bob')],
      ),
      act: (cubit) => cubit.removePlayer(0),
      expect: () => [
        isA<GameState>().having(
          (s) => s.players.map((p) => p.name).toList(),
          'players',
          ['Bob'],
        ),
      ],
    );
  });

  group('startGame', () {
    blocTest<GameCubit, GameState>(
      'emits loading then dealingWords with word pair assigned',
      build: _cubit,
      seed: () => const GameState(
        players: [
          Player(name: 'Alice'),
          Player(name: 'Bob'),
          Player(name: 'Carol'),
        ],
      ),
      act: (cubit) => cubit.startGame(),
      expect: () => [
        isA<GameState>().having((s) => s.phase, 'phase', GamePhase.loading),
        isA<GameState>().having((s) => s.phase, 'phase', GamePhase.dealingWords),
      ],
    );

    blocTest<GameCubit, GameState>(
      'assigns exactly one impostor',
      build: _cubit,
      seed: () => const GameState(
        players: [
          Player(name: 'Alice'),
          Player(name: 'Bob'),
          Player(name: 'Carol'),
        ],
      ),
      act: (cubit) => cubit.startGame(),
      verify: (cubit) {
        final impostors = cubit.state.players.where((p) => p.isImpostor).length;
        expect(impostors, 1);
      },
    );

    blocTest<GameCubit, GameState>(
      'stores wordPair on state after starting',
      build: _cubit,
      seed: () => const GameState(
        players: [
          Player(name: 'Alice'),
          Player(name: 'Bob'),
          Player(name: 'Carol'),
        ],
      ),
      act: (cubit) => cubit.startGame(),
      verify: (cubit) {
        expect(cubit.state.wordPair, isNotNull);
        expect(cubit.state.wordPair!.civilianWord, 'Apple');
        expect(cubit.state.wordPair!.impostorWord, 'Banana');
      },
    );

    test('does not enter dealingWords if round abandoned during loading',
        () async {
      final wordService = _ControlledWordService();
      final cubit = _cubit(wordService: wordService);
      cubit
        ..addPlayer('Alice')
        ..addPlayer('Bob')
        ..addPlayer('Carol');

      final started = cubit.startGame();
      cubit.abandonRound();
      wordService.completer
          .complete(const WordPair(civilianWord: 'a', impostorWord: 'b'));
      await started;

      expect(cubit.state.phase, GamePhase.addingPlayers);
      await cubit.close();
    });
  });

  group('confirmElimination', () {
    blocTest<GameCubit, GameState>(
      'round ends when impostor is eliminated',
      build: _cubit,
      seed: () => const GameState(
        players: [
          Player(name: 'Alice', isImpostor: true, hasSeenWord: true),
          Player(name: 'Bob', hasSeenWord: true),
          Player(name: 'Carol', hasSeenWord: true),
        ],
        phase: GamePhase.voting,
      ),
      act: (cubit) => cubit.confirmElimination(0),
      expect: () => [
        isA<GameState>()
            .having((s) => s.phase, 'phase', GamePhase.roundOver)
            .having((s) => s.dialogRequest, 'dialog',
                isA<RoundResultDialogRequest>()),
      ],
    );

    blocTest<GameCubit, GameState>(
      'impostor wins when only 2 active players remain',
      build: _cubit,
      seed: () => const GameState(
        players: [
          Player(name: 'Alice', isImpostor: true, hasSeenWord: true),
          Player(name: 'Bob', hasSeenWord: true),
          Player(name: 'Carol', hasSeenWord: true),
        ],
        phase: GamePhase.voting,
      ),
      act: (cubit) => cubit.confirmElimination(1), // non-impostor, leaving 2
      expect: () => [
        isA<GameState>()
            .having((s) => s.phase, 'phase', GamePhase.roundOver)
            .having((s) => s.players.firstWhere((p) => p.isImpostor).points,
                'impostor points', 1),
      ],
    );
  });

  group('dismissRoundResult', () {
    blocTest<GameCubit, GameState>(
      'emits QualityCheckDialogRequest after round result dismissed',
      build: _cubit,
      seed: () => GameState(
        players: const [Player(name: 'Alice')],
        phase: GamePhase.roundOver,
        dialogRequest: RoundResultDialogRequest(message: 'test', players: []),
      ),
      act: (cubit) => cubit.dismissRoundResult(),
      expect: () => [
        isA<GameState>().having(
            (s) => s.dialogRequest, 'dialog', isA<QualityCheckDialogRequest>()),
      ],
    );
  });

  group('submitQualityCheck', () {
    blocTest<GameCubit, GameState>(
      'resets to addingPlayers after quality check, keeping names and points',
      build: _cubit,
      seed: () => const GameState(
        players: [
          Player(name: 'Alice', word: 'Apple', isImpostor: true, points: 2),
          Player(name: 'Bob', word: 'Banana'),
          Player(name: 'Carol', word: 'Banana'),
        ],
        phase: GamePhase.roundOver,
      ),
      act: (cubit) => cubit.submitQualityCheck(isGood: true),
      expect: () => [
        isA<GameState>()
            .having((s) => s.phase, 'phase', GamePhase.addingPlayers)
            .having((s) => s.players.every((p) => p.word == ''),
                'words cleared', true)
            .having((s) => s.players.first.points, 'points kept', 2),
      ],
    );
  });

  group('Insidious mode', () {
    blocTest<GameCubit, GameState>(
      'impostor gets InsidiousImpostorRevealDialogRequest in insidious mode',
      build: () => _cubit(isClueless: false),
      seed: () => const GameState(
        players: [
          Player(name: 'Alice', word: 'Apple', isImpostor: true),
          Player(name: 'Bob', word: 'Banana'),
        ],
        phase: GamePhase.dealingWords,
      ),
      act: (cubit) => cubit.showWord(0),
      expect: () => [
        isA<GameState>().having((s) => s.dialogRequest, 'dialog',
            isA<InsidiousImpostorRevealDialogRequest>()),
      ],
    );

    blocTest<GameCubit, GameState>(
      'non-impostor gets normal ShowWordDialogRequest in insidious mode',
      build: () => _cubit(isClueless: false),
      seed: () => const GameState(
        players: [
          Player(name: 'Alice', word: 'Apple', isImpostor: true),
          Player(name: 'Bob', word: 'Banana'),
        ],
        phase: GamePhase.dealingWords,
      ),
      act: (cubit) => cubit.showWord(1),
      expect: () => [
        isA<GameState>().having(
            (s) => s.dialogRequest, 'dialog', isA<ShowWordDialogRequest>()),
      ],
    );
  });
}
