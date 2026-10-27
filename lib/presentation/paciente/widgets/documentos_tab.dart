import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/clinical_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/services/share_service.dart';
import '../../../data/models/documento_model.dart';

class DocumentosTab extends StatelessWidget {
  final List<DocumentoClinico> documentos;

  const DocumentosTab({super.key, required this.documentos});

  @override
  Widget build(BuildContext context) {
    if (documentos.isEmpty) {

      return const EmptyState(
        icon: Icons.folder_open_rounded,
        title: 'Nenhum documento anexado',
        description: 'Exames laboratoriais, ecocardiogramas e receitas anteriores aparecerão aqui.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: documentos.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final doc = documentos[index];

        IconData icon;
        Color iconColor;
        switch (doc.tipo) {
          case TipoDocumentoClinico.exame:
            icon = Icons.biotech_rounded;
            iconColor = const Color(0xFF0284C7);
            break;
          case TipoDocumentoClinico.laudo:
            icon = Icons.description_rounded;
            iconColor = const Color(0xFF8B5CF6);
            break;
          case TipoDocumentoClinico.imagem:
            icon = Icons.image_rounded;
            iconColor = const Color(0xFFF59E0B);
            break;
          case TipoDocumentoClinico.receita:
            icon = Icons.receipt_long_rounded;
            iconColor = const Color(0xFF10B981);
            break;
          default:
            icon = Icons.article_rounded;
            iconColor = AppColors.navyMedium;
        }

        return ClinicalCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.titulo,
                      style: AppTypography.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${doc.categoria ?? "Geral"} • ${doc.data}',
                      style: AppTypography.bodySmall,
                    ),
                    if (doc.observacao != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        doc.observacao!,
                        style: AppTypography.bodyMedium,
                      ),
                    ],
                    if (doc.tamanhoFormatado != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${doc.arquivoNome ?? "arquivo.pdf"} (${doc.tamanhoFormatado})',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.slateTextMuted),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined, color: AppColors.primary, size: 20),
                tooltip: 'Compartilhar Documento',
                onPressed: () {
                  ShareService.instance.compartilharTexto(
                    'Documento: ${doc.titulo}\nData: ${doc.data}\nLaudo: ${doc.observacao ?? ""}',
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
