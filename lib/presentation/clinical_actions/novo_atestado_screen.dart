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

class NovoAtestadoScreen extends ConsumerStatefulWidget {
  final String pacienteId;

  const NovoAtestadoScreen({super.key, required this.pacienteId});

  @override
  ConsumerState<NovoAtestadoScreen> createState() => _NovoAtestadoScreenState();
}

class _NovoAtestadoScreenState extends ConsumerState<NovoAtestadoScreen> {
  String _tipoAtestado = 'afastamento';
  final _diasController = TextEditingController(text: '3');
  final _cidController = TextEditingController(text: 'I10');
  bool _autorizaCid = false;
  bool _gerandoPdf = false;

  @override
  void dispose() {
    _diasController.dispose();
    _cidController.dispose();
    super.dispose();
  }

  void _emitirAtestado() async {
    setState(() => _gerandoPdf = true);

    final paciente = ref.read(pacientesRepositoryProvider).obterPacientePorId(widget.pacienteId);
    final prof = ref.read(currentProfissionalProvider);

    final atestado = AtestadoMedico(
      id: 'at_${DateTime.now().millisecondsSinceEpoch}',
      pacienteId: widget.pacienteId,
      tipo: _tipoAtestado,
      diasAfastamento: int.tryParse(_diasController.text) ?? 1,
      cid10: _cidController.text.trim().isNotEmpty ? _cidController.text.trim() : null,
      autorizaCid: _autorizaCid,
      dataEmissao: DateTime.now(),
    );

    final pdfBytes = await PdfGeneratorService.instance.gerarAtestadoPdf(
      profissional: prof ?? MockDatabase.instance.profissionalDemo,
      paciente: paciente!,
      atestado: atestado,
    );

    setState(() => _gerandoPdf = false);

    await ShareService.instance.compartilharArquivoPdf(
      bytes: pdfBytes,
      nomeArquivo: 'atestado_${paciente.nome.replaceAll(" ", "_")}.pdf',
      mensagem: 'Atestado médico de ${paciente.nome} emitido pelo Dr(a). ${prof?.nome ?? "Helena Moraes"}.',
    );

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final paciente = ref.watch(pacientesRepositoryProvider).obterPacientePorId(widget.pacienteId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Atestado CFM • ${paciente?.nome.split(" ").first ?? ""}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Modalidade do Documento', style: AppTypography.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'afastamento', label: Text('Afastamento')),
                ButtonSegment(value: 'comparecimento', label: Text('Comparec.')),
                ButtonSegment(value: 'aptidao', label: Text('Aptidão')),
              ],
              selected: {_tipoAtestado},
              onSelectionChanged: (val) => setState(() => _tipoAtestado = val.first),
            ),
            const SizedBox(height: 20),

            if (_tipoAtestado == 'afastamento') ...[
              Text('Dias de Afastamento Solicitados', style: AppTypography.titleSmall),
              const SizedBox(height: 6),
              TextField(
                controller: _diasController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Ex: 3',
                  prefixIcon: Icon(Icons.bed_rounded),
                ),
              ),
              const SizedBox(height: 16),
            ],

            Text('Código CID-10 (Opcional)', style: AppTypography.titleSmall),
            const SizedBox(height: 6),
            TextField(
              controller: _cidController,
              decoration: const InputDecoration(
                hintText: 'Ex: I10, J00, M54.5',
                prefixIcon: Icon(Icons.medical_information_outlined),
              ),
            ),
            const SizedBox(height: 10),

            // Regra CFM 1.658/02 e 1.851/08
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _autorizaCid,
              onChanged: (val) => setState(() => _autorizaCid = val ?? false),
              title: const Text(
                'Paciente autorizou expressamente a inclusão do diagnóstico CID no documento (CFM 1.658/02)',
                style: TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 32),

            CustomButton(
              label: 'Emitir Atestado & Compartilhar A4',
              icon: Icons.picture_as_pdf_rounded,
              isLoading: _gerandoPdf,
              onPressed: _emitirAtestado,
            ),
          ],
        ),
      ),
    );
  }
}
