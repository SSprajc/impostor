import 'package:flutter/material.dart';
import 'package:impostor/domain/model/game_phase.dart';
import 'package:impostor/domain/model/player.dart';
import 'package:impostor/presentation/common/impostor_theme.dart';
import 'package:impostor/presentation/game/cubit/game_cubit.dart';

class NoPlayersWidget extends StatelessWidget {
  const NoPlayersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: 94),
        child: Text(
                  "Add players",
                  style: TextStyle(
                    fontSize: 42,
                    letterSpacing: 2,
                    fontFamily: 'Bloodthirsty',
                    color: ImpColors.secondary,
                  ),
                ),
      ),
    );
  }
}


class PlayerGrid extends StatelessWidget {
  final GameInProgress gameInProgressState;
  final void Function(int index) onCardClick;
  final void Function(int index)? onCardLongPress;

  const PlayerGrid({
    super.key,
    required this.gameInProgressState,
    required this.onCardClick,
    this.onCardLongPress,
  });

  bool _isClickable(int index) {
    final player = gameInProgressState.players[index];
    switch (gameInProgressState.phase) {
      case GamePhase.dealingWords:
        return !player.hasSeenWord;
      case GamePhase.voting:
        return !player.isEliminated;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: gameInProgressState.players.length,
      itemBuilder: (context, index) {
        final player = gameInProgressState.players[index];
        final isClickable = _isClickable(index);

        return PlayerCard(
          player: player,
          isClickable: isClickable,
          phase: gameInProgressState.phase,
          onTap: isClickable ? () => onCardClick(index) : null,
          onLongPress: gameInProgressState.phase == GamePhase.addingPlayers
              ? () => onCardLongPress?.call(index)
              : null,
        );
      },
    );
  }
}

class PlayerCard extends StatelessWidget {
  const PlayerCard({
    super.key,
    required this.player,
    required this.isClickable,
    required this.phase,
    this.onTap,
    this.onLongPress,
  });

  final Player player;
  final bool isClickable;
  final GamePhase phase;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final showSeenCheck = phase == GamePhase.dealingWords && player.hasSeenWord;

    return Card(
      color: isClickable
          ? ImpColors.onTertiaryColor
          : ImpColors.tertiaryColor,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Text(
                player.name,
                style: theme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
            if (showSeenCheck)
              Positioned(
                top: 6,
                right: 8,
                child: Icon(
                  Icons.check_circle,
                  color: ImpColors.accent,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }
}