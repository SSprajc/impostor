import 'package:flutter/material.dart';
import 'package:impostor/presentation/common_widgets.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 26),
            Text(
              "Impostor",
              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, letterSpacing: 5, fontFamily: 'Bloodthirsty', color: Color(0xFF430000)),
            ),
            PrimaryButton(
              mainText: 'Clueless',
              subText: 'Impostor doesn\'t know he is the Impostor',
              onPressed: () {},
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              mainText: 'Insidious',
              subText: 'Knows what he\'s doing',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
