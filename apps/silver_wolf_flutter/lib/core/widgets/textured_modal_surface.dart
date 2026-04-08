import 'package:flutter/material.dart';
import 'package:silver_wolf_flutter/core/services/asset_catalog.dart';
import 'package:silver_wolf_flutter/core/theme/app_colors.dart';

class TexturedModalSurface extends StatelessWidget {
  const TexturedModalSurface({
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 30,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 36,
              spreadRadius: 4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: Image.asset(AssetCatalog.boardMap, fit: BoxFit.cover),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        Colors.white.withValues(alpha: 0.92),
                        AppColors.parchment.withValues(alpha: 0.95),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.brass.withValues(alpha: 0.72),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              Padding(padding: padding, child: child),
            ],
          ),
        ),
      ),
    );
  }
}
