import 'package:flutter/material.dart';
import 'package:impostor/presentation/common/impostor_theme.dart';

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
    final theme = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: ImpColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: ImpColors.border, width: 1),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mainText,
                  style: theme.displaySmall?.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 6),
                Text(
                  subText,
                  style: theme.bodyMedium?.copyWith(color: ImpColors.ash),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
