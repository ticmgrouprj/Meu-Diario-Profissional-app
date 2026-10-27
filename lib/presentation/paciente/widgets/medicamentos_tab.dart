import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/clinical_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/vitals_model.dart';

class MedicamentosTab extends StatelessWidget {
  final List<MedicamentoPaciente> medicamentos;
  final List<RegistroTomada> tomadas;

  const MedicamentosTab({
    super.key,
    required this.medicamentos,
    required this.tomadas,
  });

  @override
  Widget build(BuildContext context) {
    if (medicamentos.isEmpty) {
      return const EmptyState(
        icon: Icons.medication_outlined,
        title: 'Nenhum medicamento ativo',
        description: 'Prescreva ou importe medicações para acompanhar a adesão deste paciente.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: medicamentos.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final med = medicamentos[index];
        final adesao = med.adesaoPercentual ?? 0.85;

        return ClinicalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.medication_rounded, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                med.nome,
                                style: AppTypography.titleSmall,
                              ),
                              if (med.dosagem != null)
                                Text(
                                  med.dosagem!,
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.navyMedium),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: adesao >= 0.8 ? AppColors.riskEstavelBg : AppColors.riskAtencaoBg,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '${(adesao * 100).toInt()}% adesão',
                      style: AppTypography.badgeText.copyWith(
                        color: adesao >= 0.8 ? AppColors.riskEstavelText : AppColors.riskAtencaoText,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (med.instrucoes != null) ...[
                Text(
                  'Posologia: ${med.instrucoes}',
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 10),
              ],

              // Horários de tomada
              if (med.horarios.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: med.horarios.map((h) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.slateLight,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.slateBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.alarm_rounded, size: 12, color: AppColors.slateTextMuted),
                          const SizedBox(width: 4),
                          Text(
                            '${h.hora} (${h.periodo ?? ""})',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.navyDark, fontSize: 11),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
