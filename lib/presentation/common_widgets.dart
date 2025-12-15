import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String mainText;
  final String subText;
  final VoidCallback onPressed;

  const PrimaryButton({
    super.key,
    required this.mainText,
    required this.subText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2a2a2a),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              mainText,
              style: const TextStyle(fontSize: 64, letterSpacing: 5),
            ),
            Text(
              subText,
              style: const TextStyle(fontSize: 20, color: Color(0xFF9e9e9e)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
