import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/services/cid10_service.dart';
import '../../data/models/paciente_model.dart';
import '../../data/models/consulta_soap_model.dart';
import '../../data/repositories/pacientes_repository.dart';
import '../../data/repositories/clinico_repository.dart';
import '../../data/repositories/auth_repository.dart';

class NovaConsultaSoapScreen extends ConsumerStatefulWidget {
  final String pacienteId;

  const NovaConsultaSoapScreen({super.key, required this.pacienteId});

  @override
  ConsumerState<NovaConsultaSoapScreen> createState() => _NovaConsultaSoapScreenState();
}

class _NovaConsultaSoapScreenState extends ConsumerState<NovaConsultaSoapScreen> {
  final _subjetivoController = TextEditingController();
  final _objetivoController = TextEditingController();
  final _pasController = TextEditingController();
  final _padController = TextEditingController();
  final _fcController = TextEditingController();
  final _avaliacaoController = TextEditingController();
  final _planoController = TextEditingController();
  final _retornoController = TextEditingController(text: '30');

  final List<Diagnostico> _diagnosticosSelecionados = [];
  final _buscaCidController = TextEditingController();
  List<Diagnostico> _sugestoesCid = [];
  bool _buscandoCid = false;
  String _tipoConsulta = 'presencial';

  @override
  void dispose() {
    _subjetivoController.dispose();
    _objetivoController.dispose();
    _pasController.dispose();
    _padController.dispose();
    _fcController.dispose();
    _avaliacaoController.dispose();
    _planoController.dispose();
    _retornoController.dispose();
    _buscaCidController.dispose();
    super.dispose();
  }

  void _buscarCid(String termo) async {
    if (termo.length < 2) {
      setState(() => _sugestoesCid = []);
      return;
    }
    setState(() => _buscandoCid = true);
    final res = await CID10Service.instance.buscar(termo);
    if (mounted) {
      setState(() {
        _sugestoesCid = res;
        _buscandoCid = false;
      });
    }
  }

  void _salvarConsulta() {
    if (_subjetivoController.text.trim().isEmpty || _avaliacaoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha ao menos o Subjetivo e a Avaliação Clínica')),
      );
      return;
    }

    final prof = ref.read(currentProfissionalProvider);
    final clinicoRepo = ref.read(clinicoRepositoryProvider);

    final nova = ConsultaSOAP(
      id: 'cs_${DateTime.now().millisecondsSinceEpoch}',
      pacienteId: widget.pacienteId,
      profissionalId: prof?.id ?? 'prof_demo',
      data: DateTime.now(),
      tipo: _tipoConsulta,
      subjetivo: _subjetivoController.text.trim(),
      objetivo: _objetivoController.text.trim(),
      vitais: VitaisConsulta(
        sistolica: int.tryParse(_pasController.text),
        diastolica: int.tryParse(_padController.text),
        fc: int.tryParse(_fcController.text),
      ),
      avaliacao: _avaliacaoController.text.trim(),
      hipoteses: _diagnosticosSelecionados,
      plano: _planoController.text.trim(),
      retornoEmDias: int.tryParse(_retornoController.text),
    );

    clinicoRepo.salvarConsultaSOAP(nova);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Consulta SOAP registrada com sucesso!')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final paciente = ref.watch(pacientesRepositoryProvider).obterPacientePorId(widget.pacienteId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Evolução SOAP • ${paciente?.nome.split(" ").first ?? ""}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Seletor Tipo de Atendimento
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'presencial', label: Text('Presencial'), icon: Icon(Icons.person)),
                ButtonSegment(value: 'teleconsulta', label: Text('Teleconsulta'), icon: Icon(Icons.videocam)),
                ButtonSegment(value: 'retorno', label: Text('Retorno'), icon: Icon(Icons.refresh)),
              ],
              selected: {_tipoConsulta},
              onSelectionChanged: (val) => setState(() => _tipoConsulta = val.first),
            ),
            const SizedBox(height: 20),

            // ── S: SUBJETIVO ──
            _SecaoHeader(letra: 'S', titulo: 'Subjetivo (Anamnese)', cor: const Color(0xFF0284C7)),
            const SizedBox(height: 6),
            TextField(
              controller: _subjetivoController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Queixa principal, evolução dos sintomas, adesão relatada pelo paciente...',
              ),
            ),
            const SizedBox(height: 20),

            // ── O: OBJETIVO ──
            _SecaoHeader(letra: 'O', titulo: 'Objetivo (Exame Físico & Vitais)', cor: const Color(0xFF10B981)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pasController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'PA Sist (mmHg)', hintText: '120'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _padController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'PA Diast (mmHg)', hintText: '80'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _fcController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'FC (bpm)', hintText: '72'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _objetivoController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Achados do exame físico (Ausculta cardíaca, pulmonar, abdome, edemas)...',
              ),
            ),
            const SizedBox(height: 20),

            // ── A: AVALIAÇÃO & CID-10 ──
            _SecaoHeader(letra: 'A', titulo: 'Avaliação & Diagnóstico (CID-10)', cor: const Color(0xFFF59E0B)),
            const SizedBox(height: 6),
            TextField(
              controller: _avaliacaoController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Raciocínio clínico, controle da patologia de base...',
              ),
            ),
            const SizedBox(height: 10),

            // Busca de CID-10
            TextField(
              controller: _buscaCidController,
              onChanged: _buscarCid,
              decoration: InputDecoration(
                hintText: 'Buscar código ou nome no catálogo CID-10...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _buscandoCid ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : null,
              ),
            ),
            if (_sugestoesCid.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.slateBorder),
                ),
                child: Column(
                  children: _sugestoesCid.map((cid) {
                    return ListTile(
                      dense: true,
                      title: Text('${cid.codigoCid} - ${cid.descricao}', style: AppTypography.bodySmall.copyWith(color: AppColors.navyDark)),
                      trailing: const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 18),
                      onTap: () {
                        setState(() {
                          if (!_diagnosticosSelecionados.any((d) => d.codigoCid == cid.codigoCid)) {
                            _diagnosticosSelecionados.add(cid);
                          }
                          _sugestoesCid = [];
                          _buscaCidController.clear();
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
            if (_diagnosticosSelecionados.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _diagnosticosSelecionados.map((d) {
                  return Chip(
                    backgroundColor: AppColors.primaryLight,
                    label: Text('${d.codigoCid} - ${d.descricao}', style: AppTypography.bodySmall.copyWith(color: AppColors.primaryDark)),
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () => setState(() => _diagnosticosSelecionados.remove(d)),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 20),

            // ── P: PLANO TERAPÊUTICO ──
            _SecaoHeader(letra: 'P', titulo: 'Plano Terapêutico & Conduta', cor: const Color(0xFF8B5CF6)),
            const SizedBox(height: 6),
            TextField(
              controller: _planoController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Ajustes de dosagens, metas de PA/glicemia, recomendações de estilo de vida...',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _retornoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Retorno recomendado em quantos dias?',
                hintText: '30',
                prefixIcon: Icon(Icons.calendar_month_outlined),
              ),
            ),
            const SizedBox(height: 28),

            CustomButton(
              label: 'Registrar Evolução SOAP',
              onPressed: _salvarConsulta,
            ),
          ],
        ),
      ),
    );
  }
}

class _SecaoHeader extends StatelessWidget {
  final String letra;
  final String titulo;
  final Color cor;

  const _SecaoHeader({required this.letra, required this.titulo, required this.cor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: cor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              letra,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(titulo, style: AppTypography.titleSmall),
      ],
    );
  }
}
