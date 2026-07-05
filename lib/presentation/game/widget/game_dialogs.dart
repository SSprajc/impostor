import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:impostor/domain/model/player.dart';
import 'package:impostor/domain/service/word_service.dart';
import 'package:impostor/presentation/common/impostor_theme.dart';

/// Right-aligned dialog action row: quiet cancel + filled confirm, gap 24.
List<Widget> _actionRow({Widget? cancel, required Widget confirm}) => [
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (cancel != null) ...[cancel, const SizedBox(width: 24)],
          confirm,
        ],
      ),
    ];

class _CancelButton extends StatelessWidget {
  const _CancelButton({this.onCancel});

  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        onCancel?.call();
        Navigator.of(context).pop();
      },
      child: const Text('Cancel'),
    );
  }
}

/// Filled confirm — blood, with the blood glow shadow. Destructive/dramatic.
class _BloodButton extends StatelessWidget {
  const _BloodButton(
    this.text, {
    required this.onPressed,
    this.padding,
    this.fontSize,
    this.shadowBlur = 18,
    this.shadowOffsetY = 4,
  });

  final String text;
  final VoidCallback onPressed;
  final EdgeInsets? padding;
  final double? fontSize;
  final double shadowBlur;
  final double shadowOffsetY;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: ImpColors.blood.withValues(alpha: .35),
            blurRadius: shadowBlur,
            offset: Offset(0, shadowOffsetY),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ImpTheme.bloodButton(padding: padding, fontSize: fontSize),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}

class AddPlayerDialog extends StatelessWidget {
  AddPlayerDialog({super.key, required this.onAdd, required this.onCancel});

  final void Function(String playerName) onAdd;
  final VoidCallback onCancel;

  final TextEditingController _controller = TextEditingController();

  void _submit(BuildContext context) {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    onAdd(name);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Player'),
      content: SizedBox(
        width: double.maxFinite,
        child: TextField(
          controller: _controller,
          autofocus: true,
          cursorColor: ImpColors.bone,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: const InputDecoration(hintText: 'Enter name'),
          onSubmitted: (_) => _submit(context),
        ),
      ),
      actions: _actionRow(
        cancel: _CancelButton(onCancel: onCancel),
        confirm: ElevatedButton(
          onPressed: () => _submit(context),
          child: const Text('Add'),
        ),
      ),
    );
  }
}

class RemovePlayerDialog extends StatelessWidget {
  const RemovePlayerDialog({
    super.key,
    required this.playerName,
    required this.onConfirm,
    required this.onCancel,
  });
  final String playerName;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: SizedBox(
        width: double.maxFinite,
        child: Text('Remove $playerName?'),
      ),
      actions: _actionRow(
        cancel: _CancelButton(onCancel: onCancel),
        confirm: _BloodButton(
          'Remove',
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}

/// Shared two-state full-screen reveal takeover: player name + "tap to
/// reveal", then the secret content. Never dismissible from outside.
class _RevealTakeover extends StatefulWidget {
  const _RevealTakeover({
    required this.playerName,
    required this.vignetteOpacity,
    required this.revealedBuilder,
  });

  final String playerName;
  final double vignetteOpacity;
  final WidgetBuilder revealedBuilder;

  @override
  State<_RevealTakeover> createState() => _RevealTakeoverState();
}

class _RevealTakeoverState extends State<_RevealTakeover> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Dialog.fullscreen(
      backgroundColor: ImpColors.voidBlack,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _revealed ? null : () => setState(() => _revealed = true),
        child: Container(
          decoration: ImpTheme.vignette(
            opacity: widget.vignetteOpacity,
            center: Alignment.center,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: _revealed
                ? widget.revealedBuilder(context)
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          widget.playerName,
                          textAlign: TextAlign.center,
                          style: theme.displayMedium,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'TAP TO REVEAL',
                        style: theme.labelLarge?.copyWith(letterSpacing: 4),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class ShowWordDialog extends StatefulWidget {
  const ShowWordDialog({
    super.key,
    required this.text,
    required this.playerName,
  });
  final String text;
  final String playerName;

  @override
  State<ShowWordDialog> createState() => _ShowWordDialogState();
}

class _ShowWordDialogState extends State<ShowWordDialog> {
  String? _croatian;
  bool _showCroatian = false;
  bool _translating = false;

  /// Display-only Croatian toggle; game state keeps the English word.
  /// Fails silently — translation is a nicety, not a flow step.
  Future<void> _onWordTap() async {
    if (_croatian != null) {
      setState(() => _showCroatian = !_showCroatian);
      return;
    }
    if (_translating) return;

    setState(() => _translating = true);
    try {
      final translation = await GetIt.I<WordService>()
          .translateToCroatian(widget.text)
          .timeout(const Duration(seconds: 8));
      if (!mounted) return;
      setState(() {
        _croatian = translation;
        _showCroatian = true;
        _translating = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _translating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return _RevealTakeover(
      playerName: widget.playerName,
      vignetteOpacity: .1,
      revealedBuilder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'YOUR WORD IS',
            style: theme.labelLarge?.copyWith(fontSize: 18, letterSpacing: 4),
          ),
          const SizedBox(height: 26),
          GestureDetector(
            onTap: _onWordTap,
            child: AnimatedOpacity(
              opacity: _translating ? .35 : 1,
              duration: const Duration(milliseconds: 200),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  // Uppercased: Nosifer has Đ but no đ; caps keep every
                  // Croatian glyph in-font (the face is all-caps anyway).
                  _showCroatian ? _croatian!.toUpperCase() : widget.text,
                  textAlign: TextAlign.center,
                  style:
                      theme.displayLarge?.copyWith(shadows: ImpTheme.glow()),
                ),
              ),
            ),
          ),
          const SizedBox(height: 110),
          _BloodButton(
            "I've seen it",
            fontSize: 20,
            padding: const EdgeInsets.symmetric(horizontal: 46, vertical: 16),
            shadowBlur: 24,
            shadowOffsetY: 6,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class InsidiousImpostorRevealDialog extends StatelessWidget {
  const InsidiousImpostorRevealDialog({
    super.key,
    required this.playerName,
    required this.onClose,
  });
  final String playerName;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return _RevealTakeover(
      playerName: playerName,
      vignetteOpacity: .16,
      revealedBuilder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'You are',
            style: theme.bodyLarge?.copyWith(
              fontSize: 22,
              fontStyle: FontStyle.italic,
              color: ImpColors.ash,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'the impostor',
            textAlign: TextAlign.center,
            style: theme.displayMedium?.copyWith(
              fontSize: 46,
              color: ImpColors.blood,
              shadows: ImpTheme.glow(opacity: .5),
            ),
          ),
          const SizedBox(height: 110),
          _BloodButton(
            "I've seen it",
            fontSize: 20,
            padding: const EdgeInsets.symmetric(horizontal: 46, vertical: 16),
            shadowBlur: 24,
            shadowOffsetY: 6,
            onPressed: () {
              onClose();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class ConfirmEliminationDialog extends StatelessWidget {
  const ConfirmEliminationDialog({
    super.key,
    required this.playerName,
    required this.onConfirm,
  });

  final String playerName;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: SizedBox(
        width: double.maxFinite,
        child: Text(
          'Eliminate Player?',
          style: Theme.of(context)
              .textTheme
              .displaySmall
              ?.copyWith(fontSize: 22),
        ),
      ),
      content: Text('Are you sure you want to eliminate $playerName?'),
      actions: _actionRow(
        cancel: const _CancelButton(),
        confirm: _BloodButton(
          'Eliminate',
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}

class NonEndingEliminationDialog extends StatelessWidget {
  const NonEndingEliminationDialog({super.key, required this.playerName});

  final String playerName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return AlertDialog(
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                playerName,
                textAlign: TextAlign.center,
                style: theme.displaySmall?.copyWith(fontSize: 36),
              ),
            ),
            const SizedBox(height: 16),
            Text.rich(
              TextSpan(
                text: 'is ',
                children: [
                  TextSpan(
                    text: 'NOT',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: ImpColors.blood,
                    ),
                  ),
                  const TextSpan(text: ' the impostor'),
                ],
              ),
              style: theme.bodyLarge?.copyWith(
                fontSize: 20,
                color: ImpColors.boneDim,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

class RoundResultDialog extends StatelessWidget {
  const RoundResultDialog({
    super.key,
    required this.message,
    required this.players,
    required this.onDismiss,
  });
  final String message;
  final List<Player> players;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final scorers = players.where((p) => p.points > 0).toList()
      ..sort((a, b) => b.points.compareTo(a.points));

    return AlertDialog(
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.displaySmall?.copyWith(
                color: ImpColors.blood,
                shadows: ImpTheme.glow(),
              ),
            ),
            if (scorers.isNotEmpty) ...[
              const SizedBox(height: 24),
              ...scorers.map(
                (p) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(p.name, style: theme.bodyLarge),
                      const SizedBox(width: 8),
                      const Expanded(child: _DottedLeader()),
                      const SizedBox(width: 8),
                      Text(
                        '${p.points} pts',
                        style: theme.bodyMedium?.copyWith(fontSize: 17),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDismiss();
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dotted scoreboard leader between name and points.
class _DottedLeader extends StatelessWidget {
  const _DottedLeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: CustomPaint(
        size: const Size(double.infinity, 2),
        painter: _DottedLinePainter(),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = ImpColors.inputLine;
    for (double x = 1; x < size.width; x += 5) {
      canvas.drawCircle(Offset(x, size.height / 2), .9, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class QualityCheckDialog extends StatelessWidget {
  const QualityCheckDialog({
    super.key,
    required this.onGood,
    required this.onBad,
  });
  final VoidCallback onGood;
  final VoidCallback onBad;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return AlertDialog(
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Good round?',
              textAlign: TextAlign.center,
              style: theme.displaySmall?.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _KnifeButton(
                  asset: 'assets/art/knife-up.png',
                  label: 'GOOD',
                  onTap: () {
                    Navigator.of(context).pop();
                    onGood();
                  },
                ),
                const SizedBox(width: 36),
                _KnifeButton(
                  asset: 'assets/art/knife-down.png',
                  label: 'BAD',
                  onTap: () {
                    Navigator.of(context).pop();
                    onBad();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KnifeButton extends StatelessWidget {
  const _KnifeButton({
    required this.asset,
    required this.label,
    required this.onTap,
  });
  final String asset;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Image.asset(asset, width: 96, height: 96),
        ),
        const SizedBox(height: 10),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

class AbandonRoundDialog extends StatelessWidget {
  const AbandonRoundDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const SizedBox(
        width: double.maxFinite,
        child: Text('Abandon this round?'),
      ),
      actions: _actionRow(
        cancel: _CancelButton(onCancel: onCancel),
        confirm: _BloodButton(
          'Abandon',
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
        ),
      ),
    );
  }
}

class GenerationErrorDialog extends StatelessWidget {
  const GenerationErrorDialog({super.key, required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return AlertDialog(
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'The fates are silent…',
              textAlign: TextAlign.center,
              style: theme.displaySmall?.copyWith(fontSize: 22, height: 1.7),
            ),
            const SizedBox(height: 10),
            Text(
              'Try again.',
              style: theme.bodyLarge?.copyWith(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: ImpColors.ash,
              ),
            ),
            const SizedBox(height: 24),
            _BloodButton(
              'Retry',
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
            ),
          ],
        ),
      ),
    );
  }
}
