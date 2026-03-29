import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:impostor/presentation/common/impostor_theme.dart';
import 'package:impostor/presentation/common_widgets.dart';
import 'package:impostor/presentation/game/cubit/game_cubit.dart';
import 'package:impostor/presentation/game/cubit/game_view.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeData = ImpTheme.themeData;
    
    return Scaffold(
      backgroundColor: Colors.black12,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Spacer(flex: 1),
              Text(
                "Impostor",
                style: themeData.textTheme.headlineLarge,
              ),
              Spacer(flex: 3),
              PrimaryButton(
                mainText: 'Clueless',
                subText: 'Impostor doesn\'t know he is the Impostor',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => GameCubit(isClueless: true),
                        child: GameView(),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                mainText: 'Insidious',
                subText: 'Knows what he\'s doing',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => GameCubit(isClueless: false),
                        child: const GameView(),
                      ),
                    ),
                  );
                },
              ),
              Spacer(flex: 6),
            ],
          ),
        ),
      ),
    );
  }
}
