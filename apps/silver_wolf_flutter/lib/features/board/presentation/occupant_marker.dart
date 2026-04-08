import 'package:flutter/material.dart';
import 'package:silver_wolf_engine/silver_wolf_engine.dart';
import 'package:silver_wolf_flutter/core/extensions/hex_color.dart';

class OccupantMarker extends StatelessWidget {
  const OccupantMarker({
    required this.player,
    required this.isCurrentPlayer,
    super.key,
  });

  final Player player;
  final bool isCurrentPlayer;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: player.color.toColor(),
        border: Border.all(
          color: isCurrentPlayer
              ? Colors.white
              : Colors.black.withValues(alpha: 0.15),
          width: isCurrentPlayer ? 2.4 : 1.2,
        ),
        boxShadow: <BoxShadow>[
          if (isCurrentPlayer)
            BoxShadow(
              color: player.color.toColor().withValues(alpha: 0.45),
              blurRadius: 16,
              spreadRadius: 2,
            ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        player.id.substring(1),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
