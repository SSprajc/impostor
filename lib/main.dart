import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:impostor/domain/service/mock_word_service.dart';
import 'package:impostor/domain/service/word_service.dart';
import 'package:impostor/presentation/common/impostor_theme.dart';
import 'package:impostor/presentation/menu/menu_view.dart';

void main() {
  GetIt.I.registerSingleton<WordService>(MockWordService());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Impostor',
        theme: ImpTheme.themeData,
        home: MenuView(),
      );
  }
}