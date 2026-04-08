import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:silver_wolf_flutter/core/theme/app_colors.dart';

class SigilMedallion extends StatelessWidget {
  const SigilMedallion({
    required this.assetPath,
    required this.accent,
    this.size = 56,
    super.key,
  });

  final String? assetPath;
  final Color accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.18),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: <Color>[
            Colors.white.withValues(alpha: 0.96),
            accent.withValues(alpha: 0.18),
          ],
        ),
        border: Border.all(color: AppColors.brass.withValues(alpha: 0.72)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: accent.withValues(alpha: 0.18),
            blurRadius: size * 0.3,
            spreadRadius: 1,
          ),
        ],
      ),
      child: assetPath == null
          ? Icon(
              Icons.shield_outlined,
              size: size * 0.42,
              color: AppColors.storm,
            )
          : SvgPicture.asset(assetPath!, fit: BoxFit.contain),
    );
  }
}
