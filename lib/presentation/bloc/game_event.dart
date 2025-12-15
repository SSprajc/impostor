part of 'game_bloc.dart';

@immutable
sealed class GameEvent {}

class StartGame extends GameEvent {
  final bool isClassicMode;
  StartGame(this.isClassicMode);
}