import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum RiskLevel {
  critico,
  atencao,
  estavel,
}

class RiskBadge extends StatelessWidget {
  final String? status;
  final RiskLevel? level;
  final bool compact;

  const RiskBadge({
    super.key,
    this.status,
    this.level,
    this.compact = false,
  });

  RiskLevel get resolvedLevel {
    if (level != null) return level!;
    final s = (status ?? '').toUpperCase();
    if (s.contains('CRITIC') || s.contains('ALTO') || s.contains('EMERG')) {
      return RiskLevel.critico;
    }
    if (s.contains('ATENC') || s.contains('MEDIO') || s.contains('MODERAD')) {
      return RiskLevel.atencao;
    }
    return RiskLevel.estavel;
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    Color dot;
    String label;

    switch (resolvedLevel) {
      case RiskLevel.critico:
        bg = AppColors.riskCriticoBg;
        text = AppColors.riskCriticoText;
        dot = AppColors.riskCritico;
        label = 'CRÍTICO';
        break;
      case RiskLevel.atencao:
        bg = AppColors.riskAtencaoBg;
        text = AppColors.riskAtencaoText;
        dot = AppColors.riskAtencao;
        label = 'ATENÇÃO';
        break;
      case RiskLevel.estavel:
        bg = AppColors.riskEstavelBg;
        text = AppColors.riskEstavelText;
        dot = AppColors.riskEstavel;
        label = 'ESTÁVEL';
        break;
    }

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: dot.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dot,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.badgeText.copyWith(color: text, fontSize: 10),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: dot.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dot,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.badgeText.copyWith(color: text),
          ),
        ],
      ),
    );
  }
}
