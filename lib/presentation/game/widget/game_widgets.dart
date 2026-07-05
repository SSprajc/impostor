import 'package:flutter/material.dart';
import 'package:impostor/domain/model/game_phase.dart';
import 'package:impostor/domain/model/player.dart';
import 'package:impostor/presentation/common/impostor_theme.dart';
import 'package:impostor/presentation/game/cubit/game_cubit.dart';

class NoPlayersWidget extends StatelessWidget {
  const NoPlayersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          'Add players',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .displaySmall
              ?.copyWith(fontSize: 30, color: ImpColors.ash),
        ),
      ),
    );
  }
}

class PlayerGrid extends StatelessWidget {
  final GameState state;
  final void Function(int index) onCardClick;
  final void Function(int index)? onCardLongPress;

  const PlayerGrid({
    super.key,
    required this.state,
    required this.onCardClick,
    this.onCardLongPress,
  });

  bool _isClickable(int index) {
    final player = state.players[index];
    switch (state.phase) {
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
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 104,
      ),
      itemCount: state.players.length,
      itemBuilder: (context, index) {
        final player = state.players[index];
        final isClickable = _isClickable(index);

        return PlayerCard(
          player: player,
          isClickable: isClickable,
          phase: state.phase,
          onTap: isClickable ? () => onCardClick(index) : null,
          onLongPress: state.phase == GamePhase.addingPlayers
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
    final isSeen = phase == GamePhase.dealingWords && player.hasSeenWord;
    final isDead = player.isEliminated;

    return Material(
      color: isDead ? ImpColors.deadSurface : ImpColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(
          color: isDead
              ? ImpColors.deadBorder
              : isSeen
                  ? ImpColors.borderSeen
                  : ImpColors.border,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isDead)
              Text(
                '✕',
                style: TextStyle(
                  fontFamily: ImpFonts.body,
                  fontSize: 64,
                  height: 1,
                  color: ImpColors.blood.withValues(alpha: .16),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                player.name,
                textAlign: TextAlign.center,
                style: theme.bodyLarge?.copyWith(
                  fontSize: 21,
                  color: isDead ? ImpColors.deadText : ImpColors.bone,
                  decoration: isDead ? TextDecoration.lineThrough : null,
                  decorationColor: ImpColors.deadText,
                ),
              ),
            ),
            if (isSeen)
              const Positioned(
                top: 6,
                right: 12,
                child: Text(
                  '†',
                  style: TextStyle(
                    fontFamily: ImpFonts.body,
                    fontSize: 24,
                    height: 1,
                    color: ImpColors.blood,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
