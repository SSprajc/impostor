

import 'package:flutter/material.dart';
import 'package:impostor/presentation/screen/menu_screen.dart';

class AppRouter {
  static const String menu = '/';
  static const String game = '/game';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case menu:
        return MaterialPageRoute(
          builder: (_) => const MenuScreen(),
        );

      // case game:
      //   final args = settings.arguments as Map<String, dynamic>?;
      //   final isClassicMode = args?['isClassicMode'] as bool? ?? true;
      //
      //   return MaterialPageRoute(
      //     builder: (_) => GameScreen(
      //       isClassicMode: isClassicMode,
      //     ),
      //   );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
