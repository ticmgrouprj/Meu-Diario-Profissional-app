import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/clinical_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/repositories/pacientes_repository.dart';

class AgendaScreen extends ConsumerWidget {
  const AgendaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agenda = ref.watch(agendaProvider);
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Agenda do Dia'),
      ),
      body: agenda.isEmpty
          ? const EmptyState(
              icon: Icons.event_available_rounded,
              title: 'Agenda livre hoje',
              description: 'Nenhum paciente agendado para o dia de hoje.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: agenda.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final ag = agenda[index];
                final isTele = ag.tipo == 'teleconsulta';

                return ClinicalCard(
                  onTap: () => context.push('/paciente/${ag.pacienteId}'),
                  child: Row(
                    children: [
                      // Horário
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isTele ? AppColors.purpleLight : AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              timeFormat.format(ag.inicio),
                              style: AppTypography.titleSmall.copyWith(
                                color: isTele ? AppColors.purpleConsult : AppColors.primaryDark,
                              ),
                            ),
                            Text(
                              '${ag.duracaoMin} min',
                              style: AppTypography.bodySmall.copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Detalhes da Consulta
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ag.pacienteNome,
                              style: AppTypography.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  isTele ? Icons.videocam_rounded : Icons.person_rounded,
                                  size: 14,
                                  color: AppColors.slateTextMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isTele ? 'Teleconsulta' : 'Consulta Presencial',
                                  style: AppTypography.bodySmall,
                                ),
                              ],
                            ),
                            if (ag.observacao != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                ag.observacao!,
                                style: AppTypography.bodySmall.copyWith(color: AppColors.navyMedium),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Botão Ação
                      IconButton(
                        icon: Icon(
                          isTele ? Icons.video_call_rounded : Icons.arrow_forward_ios_rounded,
                          color: isTele ? AppColors.purpleConsult : AppColors.primary,
                          size: isTele ? 28 : 16,
                        ),
                        onPressed: () {
                          if (isTele) {
                            context.push('/paciente/${ag.pacienteId}/teleconsulta');
                          } else {
                            context.push('/paciente/${ag.pacienteId}');
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
