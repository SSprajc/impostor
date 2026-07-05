import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:impostor/domain/model/game_phase.dart';
import 'package:impostor/presentation/common/impostor_theme.dart';
import 'package:impostor/presentation/game/cubit/game_cubit.dart';
import 'package:impostor/presentation/game/widget/game_dialogs.dart';
import 'package:impostor/presentation/game/widget/game_widgets.dart';
import 'package:impostor/presentation/game/widget/loading_view.dart';

class GameView extends StatelessWidget {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameCubit>().state;
    final gameCubit = context.read<GameCubit>();

    final isActiveRound = state.phase != GamePhase.addingPlayers;

    return PopScope(
      canPop: !isActiveRound,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && isActiveRound) {
          gameCubit.requestAbandonRound();
        }
      },
      child: Scaffold(
        // Loader is a full-screen takeover — no chrome. The app bar has no
        // back button (mockups); back is the system gesture, guarded above.
        appBar: state.phase == GamePhase.loading
            ? null
            : AppBar(
                automaticallyImplyLeading: false,
                title: const Text('Impostor'),
                actions: [
                  if (state.phase == GamePhase.addingPlayers &&
                      state.players.length >= 3)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: TextButton(
                        onPressed: gameCubit.startGame,
                        child: Text(
                          'PLAY',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                letterSpacing: 3,
                                color: ImpColors.blood,
                              ),
                        ),
                      ),
                    ),
                ],
              ),
        body: BlocListener<GameCubit, GameState>(
          listenWhen: (previous, current) =>
              current.dialogRequest != null &&
              !identical(previous.dialogRequest, current.dialogRequest),
          listener: (context, state) =>
              _handleDialogRequest(context, state.dialogRequest!),
          child: switch (state) {
            GameState(phase: GamePhase.loading) => const LoadingView(),
            GameState(players: []) => const NoPlayersWidget(),
            _ => PlayerGrid(
                state: state,
                onCardClick: (index) {
                  switch (state.phase) {
                    case GamePhase.dealingWords:
                      gameCubit.showWord(index);
                    case GamePhase.voting:
                      gameCubit.requestElimination(index);
                    default:
                      break;
                  }
                },
                onCardLongPress: gameCubit.requestRemovePlayer,
              ),
          },
        ),
        floatingActionButton: state.phase == GamePhase.addingPlayers
            ? Padding(
                // Scaffold gives 16 from the edges; spec wants 24.
                padding: const EdgeInsets.only(right: 8, bottom: 8),
                child: _AddPlayerFab(onTap: gameCubit.showAddPlayerDialog),
              )
            : null,
      ),
    );
  }
}

class _AddPlayerFab extends StatelessWidget {
  const _AddPlayerFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: ImpColors.blood.withValues(alpha: .45),
            blurRadius: 26,
          ),
        ],
      ),
      child: Material(
        color: ImpColors.blood,
        shape: CircleBorder(
          side: BorderSide(color: ImpColors.bone.withValues(alpha: .18)),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Center(
            child: Transform.translate(
              // ponytail: font's ascent/descent line box isn't symmetric
              // around the glyph, so Center alone renders it low. Retune
              // if font or size changes.
              offset: Offset(0, -3),
              child: Text(
                '+',
                style: TextStyle(
                  fontFamily: ImpFonts.body,
                  fontSize: 34,
                  height: 1,
                  color: ImpColors.boneBright,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void _handleDialogRequest(BuildContext context, DialogRequest request) {
  switch (request) {
    case AddPlayerDialogRequest():
      _showAddPlayerDialog(context);
    case RemovePlayerDialogRequest():
      _showRemovePlayerDialog(context, request);
    case ShowWordDialogRequest():
      _showWordDialog(context, request);
    case InsidiousImpostorRevealDialogRequest():
      _showInsidiousImpostorRevealDialog(context, request);
    case ConfirmEliminationDialogRequest():
      _showConfirmEliminationDialog(context, request);
    case NonEndingEliminationDialogRequest():
      _showNonEndingEliminationDialog(context, request);
    case RoundResultDialogRequest():
      _showRoundResultDialog(context, request);
    case QualityCheckDialogRequest():
      _showQualityCheckDialog(context);
    case GenerationErrorDialogRequest():
      _showGenerationErrorDialog(context);
    case AbandonRoundDialogRequest():
      _showAbandonRoundDialog(context);
  }
}

void _showAddPlayerDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AddPlayerDialog(
      onAdd: (name) => context.read<GameCubit>().addPlayer(name),
      onCancel: () => context.read<GameCubit>().clearDialog(),
    ),
  );
}

void _showRemovePlayerDialog(
    BuildContext context, RemovePlayerDialogRequest request) {
  showDialog(
    context: context,
    builder: (_) => RemovePlayerDialog(
      playerName: request.playerName,
      onConfirm: () =>
          context.read<GameCubit>().removePlayer(request.playerIndex),
      onCancel: () => context.read<GameCubit>().clearDialog(),
    ),
  );
}

void _showWordDialog(BuildContext context, ShowWordDialogRequest request) async {
  final cubit = context.read<GameCubit>();
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) =>
        ShowWordDialog(text: request.word, playerName: request.playerName),
  );
  cubit.confirmWordSeen(request.playerIndex);
}

void _showInsidiousImpostorRevealDialog(
    BuildContext context, InsidiousImpostorRevealDialogRequest request) {
  final cubit = context.read<GameCubit>();
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => InsidiousImpostorRevealDialog(
      playerName: request.playerName,
      onClose: () => cubit.confirmWordSeen(request.playerIndex),
    ),
  );
}

void _showConfirmEliminationDialog(
    BuildContext context, ConfirmEliminationDialogRequest request) {
  showDialog(
    context: context,
    builder: (_) => ConfirmEliminationDialog(
      playerName: request.playerName,
      onConfirm: () =>
          context.read<GameCubit>().confirmElimination(request.playerIndex),
    ),
  );
}

void _showNonEndingEliminationDialog(
    BuildContext context, NonEndingEliminationDialogRequest request) async {
  final cubit = context.read<GameCubit>();
  await showDialog(
    context: context,
    builder: (_) => NonEndingEliminationDialog(playerName: request.playerName),
  );
  cubit.clearDialog();
}

void _showRoundResultDialog(
    BuildContext context, RoundResultDialogRequest request) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => RoundResultDialog(
      message: request.message,
      players: request.players,
      onDismiss: () => context.read<GameCubit>().dismissRoundResult(),
    ),
  );
}

void _showQualityCheckDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => QualityCheckDialog(
      onGood: () => context.read<GameCubit>().submitQualityCheck(isGood: true),
      onBad: () => context.read<GameCubit>().submitQualityCheck(isGood: false),
    ),
  );
}

void _showGenerationErrorDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => GenerationErrorDialog(
      onRetry: () => context.read<GameCubit>().startGame(),
    ),
  );
}

void _showAbandonRoundDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AbandonRoundDialog(
      onConfirm: () => context.read<GameCubit>().abandonRound(),
      onCancel: () => context.read<GameCubit>().clearDialog(),
    ),
  );
}
