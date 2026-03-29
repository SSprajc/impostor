import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:impostor/domain/model/game_phase.dart';
import 'package:impostor/presentation/common/impostor_theme.dart';
import 'package:impostor/presentation/game/cubit/game_cubit.dart';
import 'package:impostor/presentation/game/widget/game_dialogs.dart';
import 'package:impostor/presentation/game/widget/game_widgets.dart';

class GameView extends StatelessWidget {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameCubit>().state;
    final gameCubit = context.read<GameCubit>();

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (state is GameInProgress &&
              state.phase == GamePhase.addingPlayers &&
              state.players.length >= 3)
            IconButton(
              icon: const Icon(Icons.play_circle_fill),
              onPressed: () {
                gameCubit.startGame();
              },
            ),
        ],
      ),
      body: BlocConsumer<GameCubit, GameState>(
        listenWhen: (previous, current) =>
            current is GameInProgress && current.dialogRequest != null,
        listener: (context, state) {
          if (state is GameInProgress && state.dialogRequest != null) {
            _handleDialogRequest(context, state.dialogRequest!);
          } else if (state is GameInProgress ) {

          }
        },
        builder: (context, state) {
          return switch (state) {
            GameInitial() => const NoPlayersWidget(),
            GameInProgress() => PlayerGrid(
              gameInProgressState: state,
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
            ),
          };
        },
      ),
      floatingActionButton:
          state is GameInitial ||
              state is GameInProgress &&
                  (state).phase == GamePhase.addingPlayers
          ? FloatingActionButton(
              onPressed: () {
                gameCubit.showAddPlayerDialog();
              },
              backgroundColor: ImpColors.tertiaryColor,
              foregroundColor: ImpColors.onTertiaryColor,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

void _handleDialogRequest(BuildContext context, DialogRequest request) {
  switch (request) {
    case AddPlayerDialogRequest():
      _showAddPlayerDialog(context);
    case ShowWordDialogRequest():
      _showWordDialog(context, request);
    case ConfirmEliminationDialogRequest():
      _showConfirmEliminationDialog(context, request);
    case NonEndingEliminationDialogRequest():
      _showNonEndingEliminationDialog(context, request);
    case RemovePlayerDialogRequest():
      break; // wired in Task 6
    case InsidiousImpostorRevealDialogRequest():
      break; // wired in Task 8
    case RoundResultDialogRequest():
      break; // wired in Task 8
    case QualityCheckDialogRequest():
      break; // wired in Task 8
    case GenerationErrorDialogRequest():
      break; // wired in Task 8
    case AbandonRoundDialogRequest():
      break; // wired in Task 9
  }
}

void _showAddPlayerDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AddPlayerDialog(
      onAdd: (name) {
        context.read<GameCubit>().addPlayer(name);
      },
      onCancel: () {
        context.read<GameCubit>().clearDialog();
      },
    ),
  );
}

void _showWordDialog(
  BuildContext context,
  ShowWordDialogRequest request,
) async {
  final cubit = context.read<GameCubit>();
  await showDialog(
    context: context,
    builder: (_) => ShowWordDialog(text: request.word),
  );
  cubit.confirmWordSeen(request.index);
}

void _showConfirmEliminationDialog(
  BuildContext context,
  ConfirmEliminationDialogRequest request,
) {
  showDialog(
    context: context,
    builder: (dialogContext) => ConfirmEliminationDialog(
      playerName: request.playerName,
      onConfirm: () {
        context.read<GameCubit>().confirmElimination(request.playerIndex);
      },
    ),
  );
}

void _showNonEndingEliminationDialog(
  BuildContext context,
  NonEndingEliminationDialogRequest request,
) async {
  final cubit = context.read<GameCubit>();
  await showDialog(
    context: context,
    builder: (_) => NonEndingEliminationDialog(playerName: request.playerName),
  );
  cubit.clearDialog();
}
