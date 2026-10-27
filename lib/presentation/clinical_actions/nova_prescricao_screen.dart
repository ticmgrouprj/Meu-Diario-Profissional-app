import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/clinical_card.dart';
import '../../core/services/pdf_generator_service.dart';
import '../../core/services/share_service.dart';
import '../../data/models/prescricao_model.dart';
import '../../data/mock/mock_database.dart';
import '../../data/repositories/pacientes_repository.dart';

import '../../data/repositories/clinico_repository.dart';
import '../../data/repositories/auth_repository.dart';

class NovaPrescricaoScreen extends ConsumerStatefulWidget {
  final String pacienteId;

  const NovaPrescricaoScreen({super.key, required this.pacienteId});

  @override
  ConsumerState<NovaPrescricaoScreen> createState() => _NovaPrescricaoScreenState();
}

class _NovaPrescricaoScreenState extends ConsumerState<NovaPrescricaoScreen> {
  final List<ItemPrescricao> _itens = [
    const ItemPrescricao(
      id: 'it_1',
      medicamento: 'Losartana Potássica',
      concentracao: '50mg',
      forma: 'Comprimido',
      posologia: 'Tomar 1 comprimido por via oral de 12 em 12 horas',
      quantidade: '60 comprimidos',
      duracao: 'continuo',
    ),
  ];

  final _medController = TextEditingController();
  final _concController = TextEditingController();
  final _formaController = TextEditingController(text: 'Comprimido');
  final _posologiaController = TextEditingController();
  final _qtdController = TextEditingController();
  bool _isContinuo = true;
  final _diasController = TextEditingController(text: '30');
  bool _gerandoPdf = false;

  @override
  void dispose() {
    _medController.dispose();
    _concController.dispose();
    _formaController.dispose();
    _posologiaController.dispose();
    _qtdController.dispose();
    _diasController.dispose();
    super.dispose();
  }

  void _adicionarItem() {
    if (_medController.text.trim().isEmpty || _posologiaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe ao menos o nome do medicamento e a posologia')),
      );
      return;
    }

    setState(() {
      _itens.add(ItemPrescricao(
        id: 'it_${DateTime.now().millisecondsSinceEpoch}',
        medicamento: _medController.text.trim(),
        concentracao: _concController.text.trim(),
        forma: _formaController.text.trim(),
        posologia: _posologiaController.text.trim(),
        quantidade: _qtdController.text.trim().isNotEmpty ? _qtdController.text.trim() : null,
        duracao: _isContinuo ? 'continuo' : int.tryParse(_diasController.text) ?? 30,
      ));

      _medController.clear();
      _concController.clear();
      _posologiaController.clear();
      _qtdController.clear();
    });

    Navigator.pop(context);
  }

  void _abrirModalAdicionarItem() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Adicionar Fármaco', style: AppTypography.titleMedium),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _medController,
                      decoration: const InputDecoration(labelText: 'Medicamento', hintText: 'Ex: Metformina'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _concController,
                            decoration: const InputDecoration(labelText: 'Concentração', hintText: '850mg'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _formaController,
                            decoration: const InputDecoration(labelText: 'Forma', hintText: 'Comprimido'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _posologiaController,
                      decoration: const InputDecoration(
                        labelText: 'Posologia',
                        hintText: 'Ex: 1 comprimido após almoço e jantar',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _qtdController,
                            decoration: const InputDecoration(labelText: 'Qtd Total', hintText: '30 cp'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Contínuo?', style: TextStyle(fontSize: 13)),
                            value: _isContinuo,
                            onChanged: (val) {
                              setModalState(() => _isContinuo = val);
                              setState(() => _isContinuo = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      label: 'Incluir na Receita',
                      onPressed: _adicionarItem,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _finalizarEPdf() async {
    if (_itens.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos um fármaco na prescrição')),
      );
      return;
    }

    setState(() => _gerandoPdf = true);

    final paciente = ref.read(pacientesRepositoryProvider).obterPacientePorId(widget.pacienteId);
    final prof = ref.read(currentProfissionalProvider);
    final clinicoRepo = ref.read(clinicoRepositoryProvider);

    final codigoQr = 'RX-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final prescricao = Prescricao(
      id: 'rx_${DateTime.now().millisecondsSinceEpoch}',
      pacienteId: widget.pacienteId,
      profissionalId: prof?.id ?? 'prof_demo',
      data: DateTime.now(),
      itens: _itens,
      codigoImportacao: codigoQr,
    );

    clinicoRepo.salvarPrescricao(prescricao);

    final pdfBytes = await PdfGeneratorService.instance.gerarReceitaPdf(
      profissional: prof ?? MockDatabase.instance.profissionalDemo,
      paciente: paciente!,
      prescricao: prescricao,
    );

    setState(() => _gerandoPdf = false);

    await ShareService.instance.compartilharArquivoPdf(
      bytes: pdfBytes,
      nomeArquivo: 'receita_${paciente.nome.replaceAll(" ", "_")}.pdf',
      mensagem: 'Olá ${paciente.nome}, segue sua receita médica digital emitida pela Dra. Helena Moraes.',
    );

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final paciente = ref.watch(pacientesRepositoryProvider).obterPacientePorId(widget.pacienteId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Prescrição • ${paciente?.nome.split(" ").first ?? ""}'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Medicamentos Receitados', style: AppTypography.titleSmall),
                      TextButton.icon(
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Adicionar'),
                        onPressed: _abrirModalAdicionarItem,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  ..._itens.asMap().entries.map((entry) {
                    final idx = entry.key + 1;
                    final it = entry.value;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ClinicalCard(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.primaryLight,
                              foregroundColor: AppColors.primaryDark,
                              child: Text('$idx', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${it.medicamento} ${it.concentracao}',
                                    style: AppTypography.titleSmall,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Uso: ${it.forma} • ${it.posologia}',
                                    style: AppTypography.bodySmall.copyWith(color: AppColors.navyMedium),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    it.duracaoFormatada,
                                    style: AppTypography.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.riskCritico, size: 20),
                              onPressed: () => setState(() => _itens.removeAt(entry.key)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.slateBorder)),
              ),
              child: CustomButton(
                label: 'Emitir Receita & Enviar no WhatsApp',
                icon: Icons.share_rounded,
                isLoading: _gerandoPdf,
                onPressed: _finalizarEPdf,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
