import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/clinical_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/consulta_soap_model.dart';

class SoapHistoryTab extends StatelessWidget {
  final List<ConsultaSOAP> consultas;

  const SoapHistoryTab({super.key, required this.consultas});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    if (consultas.isEmpty) {
      return const EmptyState(
        icon: Icons.history_edu_rounded,
        title: 'Nenhuma consulta registrada',
        description: 'Clique no botão de Nova Consulta SOAP abaixo para registrar o primeiro atendimento clínico.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: consultas.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final cs = consultas[index];

        return ClinicalCard(
          padding: EdgeInsets.zero,
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: index == 0,
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.medical_services_rounded, color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Consulta ${cs.tipo.toUpperCase()}',
                          style: AppTypography.titleSmall,
                        ),
                        Text(
                          dateFormat.format(cs.data),
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              children: [
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SoapBloco(titulo: 'S — SUBJETIVO', conteudo: cs.subjetivo),
                      const SizedBox(height: 12),
                      _SoapBloco(
                        titulo: 'O — OBJETIVO',
                        conteudo: cs.objetivo,
                        complemento: cs.vitais != null
                            ? 'Vitais: PA ${cs.vitais!.sistolica ?? "—"}/${cs.vitais!.diastolica ?? "—"} mmHg • FC ${cs.vitais!.fc ?? "—"} bpm'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _SoapBloco(
                        titulo: 'A — AVALIAÇÃO',
                        conteudo: cs.avaliacao,
                        diagnosticos: cs.hipoteses,
                      ),
                      const SizedBox(height: 12),
                      _SoapBloco(
                        titulo: 'P — PLANO TERAPÊUTICO',
                        conteudo: cs.plano,
                        retorno: cs.retornoEmDias,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SoapBloco extends StatelessWidget {
  final String titulo;
  final String conteudo;
  final String? complemento;
  final List<dynamic>? diagnosticos;
  final int? retorno;

  const _SoapBloco({
    required this.titulo,
    required this.conteudo,
    this.complemento,
    this.diagnosticos,
    this.retorno,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: AppTypography.badgeText.copyWith(color: AppColors.primary, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          conteudo,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.navyDark),
        ),
        if (complemento != null) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.slateLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              complemento!,
              style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
        if (diagnosticos != null && diagnosticos!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: diagnosticos!.map((d) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${d.codigoCid} - ${d.descricao}',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.primaryDark, fontSize: 10),
                ),
              );
            }).toList(),
          ),
        ],
        if (retorno != null) ...[
          const SizedBox(height: 6),
          Text(
            'Retorno previsto em: $retorno dias',
            style: AppTypography.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ],
      ],
    );
  }
}
