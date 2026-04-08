import 'package:flutter/material.dart';
import 'package:silver_wolf_engine/silver_wolf_engine.dart';
import 'package:silver_wolf_flutter/core/extensions/hex_color.dart';
import 'package:silver_wolf_flutter/core/services/asset_catalog.dart';
import 'package:silver_wolf_flutter/core/widgets/app_panel.dart';
import 'package:silver_wolf_flutter/core/widgets/resource_pips.dart';
import 'package:silver_wolf_flutter/core/widgets/sigil_medallion.dart';
import 'package:silver_wolf_flutter/features/game_session/application/game_session_view_state.dart';

class FighterProfilePanel extends StatelessWidget {
  const FighterProfilePanel({required this.viewState, super.key});

  final GameSessionViewState viewState;

  @override
  Widget build(BuildContext context) {
    final Player player = viewState.selectedProfilePlayer;
    final FighterStyleCopy? style = fighterStyleCopy[player.name];
    final TownDescriptionCopy? description =
        townDescriptions['#${player.name}'];
    final String? sigilAsset = AssetCatalog.sigilForTownName(player.name);

    return AppPanel(
      title: 'Fighter Profile',
      subtitle: description?.school ?? 'Wandering challenger',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SigilMedallion(
                assetPath: sigilAsset,
                accent: player.color.toColor(),
                size: 78,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      player.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description?.description ?? player.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${style?.style ?? 'Valley Style'} • Keyword: ${style?.keyword ?? 'Keyword'}',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: <Widget>[
              ResourcePips(
                label: 'Reputation',
                filled: player.reputation,
                total: 5,
                activeColor: const Color(0xFFD6A04B),
              ),
              ResourcePips(
                label: 'Hit Points',
                filled: player.hitPoints,
                total: 3,
                activeColor: const Color(0xFFB5523F),
              ),
              ResourcePips(
                label: 'Form Points',
                filled: player.formPoints,
                total: 2,
                activeColor: const Color(0xFF466A58),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Power ${player.power}\nStamina ${player.stamina}\nAgility ${player.agility}\nChi ${player.chi}\nWit ${player.wit}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
