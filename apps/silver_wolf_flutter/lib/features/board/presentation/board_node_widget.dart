import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:silver_wolf_engine/silver_wolf_engine.dart';
import 'package:silver_wolf_flutter/core/extensions/hex_color.dart';
import 'package:silver_wolf_flutter/core/services/asset_catalog.dart';
import 'package:silver_wolf_flutter/core/widgets/resource_pips.dart';
import 'package:silver_wolf_flutter/features/board/presentation/occupant_marker.dart';

class BoardNodeWidget extends StatelessWidget {
  const BoardNodeWidget({
    required this.location,
    required this.occupants,
    required this.school,
    required this.isCurrentLocation,
    required this.currentPlayerId,
    required this.onSelectPlayer,
    super.key,
  });

  final Location location;
  final List<Player> occupants;
  final School? school;
  final bool isCurrentLocation;
  final String currentPlayerId;
  final ValueChanged<String> onSelectPlayer;

  @override
  Widget build(BuildContext context) {
    final bool isTown = location.type == LocationType.town;
    final Color baseColor = location.hue.toColor();
    final String? sigilAsset = AssetCatalog.sigilForLocationId(location.id);
    final Color schoolColor = switch (school?.status) {
      SchoolStatus.destroyed => const Color(0xFF86312D),
      SchoolStatus.sieged => const Color(0xFFD6A04B),
      _ => baseColor,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.all(isTown ? 12 : 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(isTown ? 26 : 20),
        border: Border.all(
          color: isCurrentLocation
              ? schoolColor
              : baseColor.withValues(alpha: 0.45),
          width: isCurrentLocation ? 3 : 1.5,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: schoolColor.withValues(
              alpha: isCurrentLocation ? 0.35 : 0.14,
            ),
            blurRadius: isCurrentLocation ? 22 : 12,
            spreadRadius: isCurrentLocation ? 2 : 0,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          if (isTown && sigilAsset != null)
            Positioned(
              top: 4,
              right: 4,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.14,
                  child: SizedBox(
                    width: isTown ? 42 : 32,
                    height: isTown ? 42 : 32,
                    child: SvgPicture.asset(sigilAsset, fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                location.name,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontSize: isTown ? 14 : 12),
              ),
              const SizedBox(height: 6),
              if (school != null && school!.status != SchoolStatus.destroyed)
                ResourcePips(
                  label: school!.status == SchoolStatus.sieged
                      ? 'Rescue'
                      : 'School',
                  filled: school!.status == SchoolStatus.sieged
                      ? school!.saveProgress
                      : 3,
                  total: 3,
                  activeColor: schoolColor,
                )
              else if (school?.status == SchoolStatus.destroyed)
                Text(
                  'Destroyed',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: const Color(0xFF86312D),
                  ),
                )
              else
                Text(
                  'Road',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: baseColor),
                ),
              if (occupants.isNotEmpty) ...<Widget>[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: occupants
                      .map(
                        (Player player) => InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => onSelectPlayer(player.id),
                          child: OccupantMarker(
                            player: player,
                            isCurrentPlayer: player.id == currentPlayerId,
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
