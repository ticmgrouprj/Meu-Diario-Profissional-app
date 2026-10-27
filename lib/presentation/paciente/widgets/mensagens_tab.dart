import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/clinical_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/services/share_service.dart';
import '../../../data/models/mensagem_model.dart';
import '../../../data/models/paciente_model.dart';

class MensagensTab extends StatelessWidget {
  final Paciente paciente;
  final List<MensagemPaciente> mensagens;

  const MensagensTab({
    super.key,
    required this.paciente,
    required this.mensagens,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("dd/MM/yyyy 'às' HH:mm");

    if (mensagens.isEmpty) {
      return EmptyState(
        icon: Icons.chat_bubble_outline_rounded,
        title: 'Nenhum aviso enviado',
        description: 'Envie orientações médicas, alertas de telemetria ou lembretes de retorno para ${paciente.nome}.',
        buttonLabel: 'Enviar Primeiro Aviso',
        onButtonPressed: () => context.push('/paciente/${paciente.id}/enviar-mensagem'),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: mensagens.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final msg = mensagens[index];

          Color badgeColor;
          IconData icon;
          switch (msg.tipo) {
            case TipoAvisoPaciente.alertaTelemetria:
              badgeColor = AppColors.riskCritico;
              icon = Icons.warning_rounded;
              break;
            case TipoAvisoPaciente.medicacao:
              badgeColor = const Color(0xFF0284C7);
              icon = Icons.medication_rounded;
              break;
            case TipoAvisoPaciente.retorno:
              badgeColor = const Color(0xFF8B5CF6);
              icon = Icons.calendar_month_rounded;
              break;
            case TipoAvisoPaciente.exames:
              badgeColor = const Color(0xFFF59E0B);
              icon = Icons.biotech_rounded;
              break;
            default:
              badgeColor = AppColors.primary;
              icon = Icons.chat_rounded;
          }

          return ClinicalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon, color: badgeColor, size: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          msg.tipoFormatado,
                          style: AppTypography.titleSmall.copyWith(color: badgeColor, fontSize: 13),
                        ),
                      ],
                    ),
                    Text(
                      dateFormat.format(msg.enviadoEm),
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  msg.titulo,
                  style: AppTypography.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  msg.conteudo,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.navyDark),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF10B981)),
                        const SizedBox(width: 4),
                        Text(
                          msg.canal == CanalEnvio.ambos
                              ? 'Entregue no App & WhatsApp'
                              : (msg.canal == CanalEnvio.whatsApp ? 'Enviado via WhatsApp' : 'Notificação no App'),
                          style: AppTypography.bodySmall.copyWith(
                            color: const Color(0xFF065F46),
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_outlined, size: 18, color: AppColors.primary),
                      tooltip: 'Reenviar no WhatsApp',
                      onPressed: () {
                        ShareService.instance.compartilharTexto(
                          '*${msg.titulo}*\n\n${msg.conteudo}',
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.send_rounded),
        label: const Text('Novo Aviso'),
        onPressed: () => context.push('/paciente/${paciente.id}/enviar-mensagem'),
      ),
    );
  }
}
