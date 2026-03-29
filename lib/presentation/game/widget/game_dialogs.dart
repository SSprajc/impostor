import 'package:flutter/material.dart';
import 'package:impostor/domain/model/player.dart';
import 'package:impostor/presentation/common/impostor_theme.dart';

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
    final theme = Theme.of(context).textTheme;

    return AlertDialog(
      title: const Text('Add Player'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter name',
              isDense: true, // ✅ reduces height
              contentPadding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 12,
              ),
            ),
            onSubmitted: (_) => _submit(context),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () {
                  onCancel();
                  Navigator.of(context).pop();
                },
                child: Text('Cancel', style: theme.bodyMedium),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _submit(context),
                child: const Text('Add'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ShowWordDialog extends StatefulWidget {
  const ShowWordDialog({super.key, required this.text, required this.playerName});
  final String text;
  final String playerName;

  @override
  State<ShowWordDialog> createState() => _ShowWordDialogState();
}

class _ShowWordDialogState extends State<ShowWordDialog> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Dialog.fullscreen(
      child: GestureDetector(
        onTap: _revealed ? null : () => setState(() => _revealed = true),
        child: Container(
          color: ImpColors.primaryColor,
          child: Center(
            child: _revealed
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.text, style: theme.headlineLarge, textAlign: TextAlign.center),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("I've seen it"),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.playerName, style: theme.headlineMedium),
                      const SizedBox(height: 24),
                      Text('Tap to reveal', style: theme.headlineSmall),
                    ],
                  ),
          ),
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
      title: Text('Remove $playerName?'),
      actions: [
        Row(children: [
          Expanded(child: TextButton(
            onPressed: () { onCancel(); Navigator.of(context).pop(); },
            child: const Text('Cancel'),
          )),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(
            onPressed: () { onConfirm(); Navigator.of(context).pop(); },
            child: const Text('Remove'),
          )),
        ]),
      ],
    );
  }
}

class InsidiousImpostorRevealDialog extends StatefulWidget {
  const InsidiousImpostorRevealDialog({
    super.key,
    required this.playerName,
    required this.onClose,
  });
  final String playerName;
  final VoidCallback onClose;

  @override
  State<InsidiousImpostorRevealDialog> createState() => _InsidiousImpostorRevealDialogState();
}

class _InsidiousImpostorRevealDialogState extends State<InsidiousImpostorRevealDialog> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Dialog.fullscreen(
      child: GestureDetector(
        onTap: _revealed ? null : () => setState(() => _revealed = true),
        child: Container(
          color: ImpColors.primaryColor,
          child: Center(
            child: _revealed
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('You are', style: theme.headlineSmall),
                      const SizedBox(height: 8),
                      Text('the impostor', style: theme.headlineLarge, textAlign: TextAlign.center),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () { widget.onClose(); Navigator.of(context).pop(); },
                        child: const Text("I've seen it"),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.playerName, style: theme.headlineMedium),
                      const SizedBox(height: 24),
                      Text('Tap to reveal', style: theme.headlineSmall),
                    ],
                  ),
          ),
        ),
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
      title: const Text('Eliminate Player?'),
      content: Text('Are you sure you want to eliminate $playerName?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Eliminate'),
        ),
      ],
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            playerName,
            style: theme.headlineMedium?.copyWith(color: Colors.black),
          ),
          const SizedBox(height: 16),
          Text('is NOT the impostor', style: theme.bodyMedium),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Continue'),
        ),
      ],
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: theme.headlineMedium?.copyWith(color: ImpColors.secondary), textAlign: TextAlign.center),
          if (scorers.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            ...scorers.map((p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(p.name, style: theme.bodyMedium),
                  Text('${p.points} pts', style: theme.bodyMedium),
                ],
              ),
            )),
          ],
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () { Navigator.of(context).pop(); onDismiss(); },
          child: const Text('Continue'),
        ),
      ],
    );
  }
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Good round?', style: theme.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _KnifeButton(label: '🔪↑', onTap: () { Navigator.of(context).pop(); onGood(); }),
              _KnifeButton(label: '🔪↓', onTap: () { Navigator.of(context).pop(); onBad(); }),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('Good', style: theme.labelMedium),
              Text('Bad', style: theme.labelMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class _KnifeButton extends StatelessWidget {
  const _KnifeButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: ImpColors.tertiaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: Text(label, style: const TextStyle(fontSize: 32))),
      ),
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
      title: const Text('Abandon this round?'),
      actions: [
        Row(children: [
          Expanded(child: TextButton(
            onPressed: () { onCancel(); Navigator.of(context).pop(); },
            child: const Text('Cancel'),
          )),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(
            onPressed: () { Navigator.of(context).pop(); onConfirm(); },
            child: const Text('Abandon'),
          )),
        ]),
      ],
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
      content: Text('The fates are silent…\nTry again.', style: theme.bodyMedium, textAlign: TextAlign.center),
      actions: [
        ElevatedButton(
          onPressed: () { Navigator.of(context).pop(); onRetry(); },
          style: ElevatedButton.styleFrom(backgroundColor: ImpColors.accent),
          child: const Text('Retry'),
        ),
      ],
    );
  }
}
