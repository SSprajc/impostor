import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:impostor/core/routes/app_router.dart';
import 'package:impostor/presentation/bloc/game_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Add your BLoCs here
        BlocProvider(
          create: (context) => GameBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Game App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.black45),
          fontFamily: 'GloomyGrave',
          useMaterial3: true,

        ),
        initialRoute: AppRouter.menu,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}