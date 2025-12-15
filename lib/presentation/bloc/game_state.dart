part of 'game_bloc.dart';

@immutable
sealed class GameState {}

final class GameInitial extends GameState {}

final class RoundFinished extends GameState {}

final class RoundRunning extends GameState {}

final class Player extends GameState {}

final class PlayerAdded extends GameState {
  final bool isClassicMode;
  PlayerAdded(this.isClassicMode);
}
