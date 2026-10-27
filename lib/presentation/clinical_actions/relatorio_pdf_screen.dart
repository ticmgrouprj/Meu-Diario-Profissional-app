import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/pdf_generator_service.dart';
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

    final prescricoes = clinicoRepo.obterPrescricoes(pacienteId);
    final prescricao = prescricoes.isNotEmpty
        ? prescricoes.first
        : Prescricao(
            id: 'rx_demo',
            pacienteId: pacienteId,
            profissionalId: prof.id,
            data: DateTime.now(),
            itens: const [
              ItemPrescricao(
                id: 'it1',
                medicamento: 'Acompanhamento Clínico Contínuo',
                concentracao: '—',
                forma: 'Diário de Saúde',
                posologia: 'Aferir PA 2x ao dia e registrar no aplicativo',
                duracao: 'continuo',
              ),
            ],
            codigoImportacao: 'CLI2026',
          );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Relatório Oficial • ${paciente?.nome.split(" ").first ?? ""}'),
      ),
      body: paciente == null
          ? const Center(child: Text('Paciente não encontrado'))
          : PdfPreview(
              build: (format) => PdfGeneratorService.instance.gerarReceitaPdf(
                profissional: prof,
                paciente: paciente,
                prescricao: prescricao,
              ),
              canChangeOrientation: false,
              canChangePageFormat: false,
              pdfFileName: 'relatorio_${paciente.nome.replaceAll(" ", "_")}.pdf',
            ),
    );
  }
}
