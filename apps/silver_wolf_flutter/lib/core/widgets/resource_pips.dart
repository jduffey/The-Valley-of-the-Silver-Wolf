import 'package:flutter/material.dart';

class ResourcePips extends StatelessWidget {
  const ResourcePips({
    required this.label,
    required this.filled,
    required this.total,
    required this.activeColor,
    this.inactiveColor,
    super.key,
  });

  final String label;
  final int filled;
  final int total;
  final Color activeColor;
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    final Color mutedColor =
        inactiveColor ?? activeColor.withValues(alpha: 0.18);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.generate(total, (int index) {
            final bool isFilled = index < filled;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFilled ? activeColor : mutedColor,
              ),
            );
          }),
        ),
      ],
    );
  }
}
