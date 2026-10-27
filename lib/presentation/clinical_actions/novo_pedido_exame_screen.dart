import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/services/pdf_generator_service.dart';
import '../../core/services/share_service.dart';
import '../../data/models/documento_model.dart';
import '../../data/mock/mock_database.dart';

import '../../data/repositories/pacientes_repository.dart';
import '../../data/repositories/auth_repository.dart';

class NovoPedidoExameScreen extends ConsumerStatefulWidget {
  final String pacienteId;

  const NovoPedidoExameScreen({super.key, required this.pacienteId});

  @override
  ConsumerState<NovoPedidoExameScreen> createState() => _NovoPedidoExameScreenState();
}

class _NovoPedidoExameScreenState extends ConsumerState<NovoPedidoExameScreen> {
  final List<String> _examesComuns = [
    'Hemograma Completo com contagem de plaquetas',
    'Perfil Lipídico (Colesterol Total, HDL, LDL, Triglicerídeos)',
    'Glicemia de Jejum',
    'Hemoglobina Glicada (HbA1c)',
    'Ureia e Creatinina Sérica com TFG',
    'Eletrólitos (Sódio, Potássio)',
    'TSH Ultra-sensível',
    'Urina Tipo I (EAS) e Urocultura',
    'Eletrocardiograma de Repouso (ECG)',
  ];

  final Set<String> _selecionados = {
    'Hemograma Completo com contagem de plaquetas',
    'Perfil Lipídico (Colesterol Total, HDL, LDL, Triglicerídeos)',
  };

  final _outroExameController = TextEditingController();
  final _indicacaoController = TextEditingController(text: 'Avaliação cardiovascular e controle metabólico.');
  bool _gerandoPdf = false;

  @override
  void dispose() {
    _outroExameController.dispose();
    _indicacaoController.dispose();
    super.dispose();
  }

  void _emitirPedido() async {
    if (_selecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione ao menos um exame para a requisição')),
      );
      return;
    }

    setState(() => _gerandoPdf = true);

    final paciente = ref.read(pacientesRepositoryProvider).obterPacientePorId(widget.pacienteId);
    final prof = ref.read(currentProfissionalProvider);

    final pedido = PedidoExame(
      id: 'ex_${DateTime.now().millisecondsSinceEpoch}',
      pacienteId: widget.pacienteId,
      exames: _selecionados.toList(),
      indicacaoClinica: _indicacaoController.text.trim(),
      dataEmissao: DateTime.now(),
    );

    final pdfBytes = await PdfGeneratorService.instance.gerarPedidoExamePdf(
      profissional: prof ?? MockDatabase.instance.profissionalDemo,
      paciente: paciente!,
      pedido: pedido,
    );

    setState(() => _gerandoPdf = false);

    await ShareService.instance.compartilharArquivoPdf(
      bytes: pdfBytes,
      nomeArquivo: 'pedido_exames_${paciente.nome.replaceAll(" ", "_")}.pdf',
      mensagem: 'Requisição de exames para ${paciente.nome} emitida pelo Dr(a). ${prof?.nome ?? "Helena Moraes"}.',
    );

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final paciente = ref.watch(pacientesRepositoryProvider).obterPacientePorId(widget.pacienteId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Pedido de Exames • ${paciente?.nome.split(" ").first ?? ""}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Exames Laboratoriais Frequentes', style: AppTypography.titleSmall),
            const SizedBox(height: 10),

            ..._examesComuns.map((exame) {
              final isChecked = _selecionados.contains(exame);
              return CheckboxListTile(
                value: isChecked,
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(exame, style: AppTypography.bodyMedium.copyWith(color: AppColors.navyDark)),
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _selecionados.add(exame);
                    } else {
                      _selecionados.remove(exame);
                    }
                  });
                },
              );
            }),
            const SizedBox(height: 12),

            // Adicionar Outro Exame
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _outroExameController,
                    decoration: const InputDecoration(
                      hintText: 'Adicionar outro exame...',
                      prefixIcon: Icon(Icons.add),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (_outroExameController.text.trim().isNotEmpty) {
                      setState(() {
                        _selecionados.add(_outroExameController.text.trim());
                        _outroExameController.clear();
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text('Indicação Clínica / Justificativa', style: AppTypography.titleSmall),
            const SizedBox(height: 6),
            TextField(
              controller: _indicacaoController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Ex: Acompanhamento de hipertensão arterial e dislipidemia.',
              ),
            ),
            const SizedBox(height: 32),

            CustomButton(
              label: 'Emitir Requisição Oficial em PDF',
              icon: Icons.send_rounded,
              isLoading: _gerandoPdf,
              onPressed: _emitirPedido,
            ),
          ],
        ),
      ),
    );
  }
}
