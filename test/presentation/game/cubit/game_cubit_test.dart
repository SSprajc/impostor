import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impostor/domain/model/game_phase.dart';
import 'package:impostor/domain/model/player.dart';
import 'package:impostor/domain/service/mock_word_service.dart';
import 'package:impostor/presentation/game/cubit/game_cubit.dart';

GameCubit _cubit({bool isClueless = true}) =>
    GameCubit(isClueless: isClueless, wordService: MockWordService());

void main() {
  group('removePlayer', () {
    blocTest<GameCubit, GameState>(
      'removes player by index during addingPlayers phase',
      build: _cubit,
      seed: () => GameInProgress(
        players: [
          Player.firstCreate(name: 'Alice'),
          Player.firstCreate(name: 'Bob'),
        ],
        phase: GamePhase.addingPlayers,
      ),
      act: (cubit) => cubit.removePlayer(0),
      expect: () => [
        isA<GameInProgress>().having(
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
      seed: () => GameInProgress(
        players: [
          Player.firstCreate(name: 'Alice'),
          Player.firstCreate(name: 'Bob'),
          Player.firstCreate(name: 'Carol'),
        ],
        phase: GamePhase.addingPlayers,
      ),
      act: (cubit) => cubit.startGame(),
      expect: () => [
        isA<GameInProgress>().having((s) => s.phase, 'phase', GamePhase.loading),
        isA<GameInProgress>().having((s) => s.phase, 'phase', GamePhase.dealingWords),
      ],
    );

    blocTest<GameCubit, GameState>(
      'assigns exactly one impostor',
      build: _cubit,
      seed: () => GameInProgress(
        players: [
          Player.firstCreate(name: 'Alice'),
          Player.firstCreate(name: 'Bob'),
          Player.firstCreate(name: 'Carol'),
        ],
        phase: GamePhase.addingPlayers,
      ),
      act: (cubit) => cubit.startGame(),
      verify: (cubit) {
        final state = cubit.state as GameInProgress;
        final impostors = state.players.where((p) => p.isImpostor).length;
        expect(impostors, 1);
      },
    );

    blocTest<GameCubit, GameState>(
      'stores wordPair on state after starting',
      build: _cubit,
      seed: () => GameInProgress(
        players: [
          Player.firstCreate(name: 'Alice'),
          Player.firstCreate(name: 'Bob'),
          Player.firstCreate(name: 'Carol'),
        ],
        phase: GamePhase.addingPlayers,
      ),
      act: (cubit) => cubit.startGame(),
      verify: (cubit) {
        final state = cubit.state as GameInProgress;
        expect(state.wordPair, isNotNull);
        expect(state.wordPair!.civilianWord, 'Apple');
        expect(state.wordPair!.impostorWord, 'Banana');
      },
    );
  });

  group('confirmElimination', () {
    blocTest<GameCubit, GameState>(
      'round ends when impostor is eliminated',
      build: _cubit,
      seed: () => GameInProgress(
        players: [
          Player.firstCreate(name: 'Alice').copyWith(isImpostor: true, hasSeenWord: true),
          Player.firstCreate(name: 'Bob').copyWith(hasSeenWord: true),
          Player.firstCreate(name: 'Carol').copyWith(hasSeenWord: true),
        ],
        phase: GamePhase.voting,
      ),
      act: (cubit) => cubit.confirmElimination(0),
      expect: () => [
        isA<GameInProgress>()
            .having((s) => s.phase, 'phase', GamePhase.roundOver)
            .having((s) => s.dialogRequest, 'dialog', isA<RoundResultDialogRequest>()),
      ],
    );

    blocTest<GameCubit, GameState>(
      'impostor wins when only 2 active players remain',
      build: _cubit,
      seed: () => GameInProgress(
        players: [
          Player.firstCreate(name: 'Alice').copyWith(isImpostor: true, hasSeenWord: true),
          Player.firstCreate(name: 'Bob').copyWith(hasSeenWord: true),
          Player.firstCreate(name: 'Carol').copyWith(hasSeenWord: true),
        ],
        phase: GamePhase.voting,
      ),
      act: (cubit) => cubit.confirmElimination(1), // eliminate non-impostor, leaving 2
      expect: () => [
        isA<GameInProgress>()
            .having((s) => s.phase, 'phase', GamePhase.roundOver)
            .having((s) => s.players.firstWhere((p) => p.isImpostor).points, 'impostor points', 1),
      ],
    );
  });

  group('dismissRoundResult', () {
    blocTest<GameCubit, GameState>(
      'emits QualityCheckDialogRequest after round result dismissed',
      build: _cubit,
      seed: () => GameInProgress(
        players: [Player.firstCreate(name: 'Alice')],
        phase: GamePhase.roundOver,
        dialogRequest: RoundResultDialogRequest(message: 'test', players: []),
      ),
      act: (cubit) => cubit.dismissRoundResult(),
      expect: () => [
        isA<GameInProgress>()
            .having((s) => s.dialogRequest, 'dialog', isA<QualityCheckDialogRequest>()),
      ],
    );
  });

  group('submitQualityCheck', () {
    blocTest<GameCubit, GameState>(
      'resets to addingPlayers after quality check',
      build: _cubit,
      seed: () => GameInProgress(
        players: [
          Player.firstCreate(name: 'Alice').copyWith(word: 'Apple', isImpostor: true),
          Player.firstCreate(name: 'Bob').copyWith(word: 'Banana'),
          Player.firstCreate(name: 'Carol').copyWith(word: 'Banana'),
        ],
        phase: GamePhase.roundOver,
      ),
      act: (cubit) => cubit.submitQualityCheck(isGood: true),
      expect: () => [
        isA<GameInProgress>()
            .having((s) => s.phase, 'phase', GamePhase.addingPlayers)
            .having((s) => s.players.every((p) => p.word == ''), 'words cleared', true),
      ],
    );
  });

  group('Insidious mode', () {
    blocTest<GameCubit, GameState>(
      'impostor gets InsidiousImpostorRevealDialogRequest in insidious mode',
      build: () => GameCubit(isClueless: false, wordService: MockWordService()),
      seed: () => GameInProgress(
        players: [
          Player.firstCreate(name: 'Alice').copyWith(word: 'Apple', isImpostor: true),
          Player.firstCreate(name: 'Bob').copyWith(word: 'Banana'),
        ],
        phase: GamePhase.dealingWords,
      ),
      act: (cubit) => cubit.showWord(0),
      expect: () => [
        isA<GameInProgress>()
            .having((s) => s.dialogRequest, 'dialog', isA<InsidiousImpostorRevealDialogRequest>()),
      ],
    );

    blocTest<GameCubit, GameState>(
      'non-impostor gets normal ShowWordDialogRequest in insidious mode',
      build: () => GameCubit(isClueless: false, wordService: MockWordService()),
      seed: () => GameInProgress(
        players: [
          Player.firstCreate(name: 'Alice').copyWith(word: 'Apple', isImpostor: true),
          Player.firstCreate(name: 'Bob').copyWith(word: 'Banana'),
        ],
        phase: GamePhase.dealingWords,
      ),
      act: (cubit) => cubit.showWord(1),
      expect: () => [
        isA<GameInProgress>()
            .having((s) => s.dialogRequest, 'dialog', isA<ShowWordDialogRequest>()),
      ],
    );
  });
}
