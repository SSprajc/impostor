import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:impostor/presentation/common/impostor_theme.dart';
import 'package:impostor/presentation/common/primary_button.dart';
import 'package:impostor/presentation/game/cubit/game_cubit.dart';
import 'package:impostor/presentation/game/game_view.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  void _startGame(BuildContext context, {required bool isClueless}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => GameCubit(isClueless: isClueless),
          child: const GameView(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: ImpTheme.vignette(),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Impostor',
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge
                            ?.copyWith(shadows: ImpTheme.glow()),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 56),
                child: Column(
                  children: [
                    PrimaryButton(
                      mainText: 'Clueless',
                      subText: "Impostor doesn't know he is the Impostor",
                      onPressed: () => _startGame(context, isClueless: true),
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      mainText: 'Insidious',
                      subText: "Knows what he's doing",
                      onPressed: () => _startGame(context, isClueless: false),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
