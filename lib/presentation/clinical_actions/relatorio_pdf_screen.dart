import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/pdf_generator_service.dart';
import '../../core/services/share_service.dart';
import '../../data/models/prescricao_model.dart';
import '../../data/mock/mock_database.dart';
import '../../data/repositories/pacientes_repository.dart';
import '../../data/repositories/clinico_repository.dart';
import '../../data/repositories/auth_repository.dart';

class RelatorioPdfScreen extends ConsumerWidget {
  final String pacienteId;

  const RelatorioPdfScreen({super.key, required this.pacienteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paciente = ref.watch(pacientesRepositoryProvider).obterPacientePorId(pacienteId);
    final prof = ref.watch(currentProfissionalProvider) ?? MockDatabase.instance.profissionalDemo;
    final clinicoRepo = ref.watch(clinicoRepositoryProvider);

    final pressoes = clinicoRepo.obterPressoes(pacienteId);
    final glicemias = clinicoRepo.obterGlicemias(pacienteId);
    final prescricoes = clinicoRepo.obterPrescricoes(pacienteId);
    final medicamentos = prescricoes.expand((p) => p.itens).toList();
    final consultas = clinicoRepo.obterConsultas(pacienteId);
    final ultimaConsulta = consultas.isNotEmpty ? consultas.first : null;

    final fallbackItens = medicamentos.isNotEmpty
        ? medicamentos
        : const [
            ItemPrescricao(
              id: 'it1',
              medicamento: 'Acompanhamento de Telemetria Domiciliar',
              concentracao: '—',
              forma: 'Diário de Saúde',
              posologia: 'Aferir PA 2x ao dia e glicemia conforme prescrição',
              duracao: 'continuo',
            ),
          ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Dossiê 360° • ${paciente?.nome.split(" ").first ?? ""}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AppColors.primary),
            tooltip: 'Compartilhar Resumo Clínico',
            onPressed: () async {
              final texto = '''*[Meu Diário de Saúde — Dossiê Clínico 360°]*
Paciente: ${paciente?.nome.toUpperCase()}
Médico: ${prof.nome} (${prof.carimbo})
Emissão: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}

O Dossiê Clínico 360° consolidado está emitido no prontuário digital com histórico de telemetria, metas de controle, medicamentos de uso contínuo e evolução SOAP.''';
              await ShareService.instance.compartilharTexto(
                texto,
                assunto: 'Dossiê Clínico — ${paciente?.nome}',
              );
            },
          ),
        ],
      ),
      body: paciente == null
          ? const Center(child: Text('Paciente não encontrado'))
          : PdfPreview(
              build: (format) => PdfGeneratorService.instance.gerarDossieClinicoPdf(
                profissional: prof,
                paciente: paciente,
                pressoes: pressoes,
                glicemias: glicemias,
                medicamentos: fallbackItens,
                ultimaConsulta: ultimaConsulta,
              ),
              canChangeOrientation: false,
              canChangePageFormat: false,
              pdfFileName: 'dossie_${paciente.nome.replaceAll(" ", "_")}.pdf',
            ),
    );
  }
}
