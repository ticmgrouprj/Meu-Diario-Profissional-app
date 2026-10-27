import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/clinical_card.dart';
import '../../core/widgets/risk_badge.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/models/paciente_model.dart';
import '../../data/repositories/pacientes_repository.dart';

class AlertasScreen extends ConsumerWidget {
  const AlertasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertas = ref.watch(alertasProvider);
    final dateFormat = DateFormat("dd/MM 'às' HH:mm");

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Central de Alertas'),
        actions: [
          if (alertas.any((a) => !a.lido))
            TextButton(
              onPressed: () => ref.read(alertasProvider.notifier).marcarTodosComoLidos(),
              child: const Text('Ler Todos'),
            ),
        ],
      ),
      body: alertas.isEmpty
          ? const EmptyState(
              icon: Icons.check_circle_outline_rounded,
              title: 'Nenhum alerta pendente',
              description: 'Todos os pacientes monitorados encontram-se dentro das metas de telemetria.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: alertas.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final alerta = alertas[index];
                final isCritico = alerta.nivel == StatusRisco.critico;

                return ClinicalCard(
                  backgroundColor: alerta.lido ? Colors.white : (isCritico ? const Color(0xFFFFF1F2) : const Color(0xFFFFFBEB)),
                  borderColor: alerta.lido ? AppColors.slateBorder : (isCritico ? AppColors.riskCritico.withValues(alpha: 0.3) : AppColors.riskAtencao.withValues(alpha: 0.3)),
                  onTap: () {
                    ref.read(alertasProvider.notifier).marcarComoLido(alerta.id);
                    context.push('/paciente/${alerta.pacienteId}');
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isCritico ? AppColors.riskCriticoBg : AppColors.riskAtencaoBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCritico ? Icons.warning_rounded : Icons.info_outline_rounded,
                          color: isCritico ? AppColors.riskCritico : AppColors.riskAtencao,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  alerta.pacienteNome,
                                  style: AppTypography.titleSmall,
                                ),
                                RiskBadge(
                                  level: isCritico ? RiskLevel.critico : RiskLevel.atencao,
                                  compact: true,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              alerta.titulo,
                              style: AppTypography.titleSmall.copyWith(fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              alerta.descricao,
                              style: AppTypography.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              dateFormat.format(alerta.em),
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
