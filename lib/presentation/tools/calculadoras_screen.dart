import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/clinical_card.dart';
import '../../core/services/medical_calculators_service.dart';

import '../../data/models/paciente_model.dart';
import '../../data/repositories/pacientes_repository.dart';
import '../../data/repositories/clinico_repository.dart';

class CalculadorasScreen extends ConsumerStatefulWidget {
  final String? pacienteId;

  const CalculadorasScreen({super.key, this.pacienteId});

  @override
  ConsumerState<CalculadorasScreen> createState() => _CalculadorasScreenState();
}

class _CalculadorasScreenState extends ConsumerState<CalculadorasScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ── Framingham State ──
  int _frIdade = 55;
  bool _frIsFeminino = true;
  int _frColesterol = 210;
  int _frHdl = 48;
  int _frPas = 145;
  bool _frTratado = true;
  bool _frTabagista = false;
  bool _frDiabetico = true;

  // ── CHA2DS2-VASc State ──
  int _chIdade = 68;
  bool _chIsFeminino = true;
  bool _chIc = false;
  bool _chHa = true;
  bool _chDm = true;
  bool _chAvc = false;
  bool _chVas = true;

  // ── CKD-EPI State ──
  final _ckCreatininaController = TextEditingController(text: '1.2');
  int _ckIdade = 62;
  bool _ckIsFeminino = true;

  // ── IMC State ──
  final _imcPesoController = TextEditingController(text: '78.4');
  final _imcAlturaController = TextEditingController(text: '1.62');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Auto-preenchimento com os dados clínicos do paciente se informado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.pacienteId != null) {
        final pac = ref.read(pacientesRepositoryProvider).obterPacientePorId(widget.pacienteId!);
        if (pac != null) {
          final pressoes = ref.read(clinicoRepositoryProvider).obterPressoes(pac.id);
          final pesos = ref.read(clinicoRepositoryProvider).obterPesos(pac.id);

          setState(() {
            final isFem = pac.sexo == Sexo.f;
            final idade = pac.idade > 0 ? pac.idade : 55;

            // Framingham
            _frIdade = idade;
            _frIsFeminino = isFem;
            _frDiabetico = pac.diagnosticos.any((d) => d.codigoCid.startsWith('E10') || d.codigoCid.startsWith('E11'));
            if (pressoes.isNotEmpty) {
              _frPas = pressoes.last.sistolica;
            }

            // CHA2DS2-VASc
            _chIdade = idade;
            _chIsFeminino = isFem;
            _chHa = pac.diagnosticos.any((d) => d.codigoCid.startsWith('I10'));
            _chDm = _frDiabetico;
            _chIc = pac.diagnosticos.any((d) => d.codigoCid.startsWith('I50'));

            // CKD-EPI
            _ckIdade = idade;
            _ckIsFeminino = isFem;

            // IMC
            if (pesos.isNotEmpty) {
              _imcPesoController.text = pesos.last.peso.toStringAsFixed(1);
            }
            if (pac.altura != null) {
              _imcAlturaController.text = pac.altura!.toStringAsFixed(2);
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ckCreatininaController.dispose();
    _imcPesoController.dispose();
    _imcAlturaController.dispose();
    super.dispose();
  }

  void _copiarTexto(String texto) {
    Clipboard.setData(ClipboardData(text: texto));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Escore clínico copiado para a área de transferência!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pac = widget.pacienteId != null
        ? ref.watch(pacientesRepositoryProvider).obterPacientePorId(widget.pacienteId!)
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(pac != null ? 'Calculadoras • ${pac.nome.split(" ").first}' : 'Calculadoras Clínicas'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.slateTextMuted,
          indicatorColor: AppColors.primary,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Framingham (CV)'),
            Tab(text: 'CHA₂DS₂-VASc (AVC)'),
            Tab(text: 'CKD-EPI (Renal)'),
            Tab(text: 'IMC & Área Corpórea'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFraminghamTab(),
          _buildCha2ds2VascTab(),
          _buildCkdEpiTab(),
          _buildImcTab(),
        ],
      ),
    );
  }

  // ─── ABA 1: FRAMINGHAM ───
  Widget _buildFraminghamTab() {
    final result = MedicalCalculatorsService.calcularFramingham(
      idade: _frIdade,
      isFeminino: _frIsFeminino,
      colesterolTotal: _frColesterol,
      hdl: _frHdl,
      paSistolica: _frPas,
      tratadoHipertensao: _frTratado,
      tabagista: _frTabagista,
      diabetico: _frDiabetico,
    );

    final isAlto = result.percentual >= 20.0;
    final isMedio = result.percentual >= 10.0 && !isAlto;

    final badgeColor = isAlto ? AppColors.riskCritico : (isMedio ? AppColors.riskAtencao : AppColors.riskEstavel);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card de Resultado
          ClinicalCard(
            backgroundColor: badgeColor.withValues(alpha: 0.08),
            borderColor: badgeColor.withValues(alpha: 0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Risco Cardiovascular em 10 Anos', style: AppTypography.titleSmall),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 20, color: AppColors.primary),
                      tooltip: 'Copiar laudo',
                      onPressed: () => _copiarTexto(
                        'Escore de Framingham: ${result.percentual.toStringAsFixed(1)}% (${result.categoria}). Conduta: ${result.recomendacao}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${result.percentual.toStringAsFixed(1)}%',
                      style: AppTypography.displayLarge.copyWith(color: badgeColor, fontSize: 36),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      result.categoria,
                      style: AppTypography.titleSmall.copyWith(color: badgeColor),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  result.recomendacao,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.navyDark),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Variáveis
          Text('Variáveis do Paciente', style: AppTypography.titleSmall),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _NumberInput(
                  label: 'Idade (anos)',
                  valor: _frIdade,
                  onChanged: (v) => setState(() => _frIdade = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sexo Biológico', style: AppTypography.bodySmall),
                    const SizedBox(height: 4),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: true, label: Text('F')),
                        ButtonSegment(value: false, label: Text('M')),
                      ],
                      selected: {_frIsFeminino},
                      onSelectionChanged: (val) => setState(() => _frIsFeminino = val.first),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _NumberInput(
                  label: 'Colesterol Total (mg/dL)',
                  valor: _frColesterol,
                  onChanged: (v) => setState(() => _frColesterol = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NumberInput(
                  label: 'HDL-Colesterol (mg/dL)',
                  valor: _frHdl,
                  onChanged: (v) => setState(() => _frHdl = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _NumberInput(
            label: 'PA Sistólica Atual (mmHg)',
            valor: _frPas,
            onChanged: (v) => setState(() => _frPas = v),
          ),
          const SizedBox(height: 12),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Em tratamento anti-hipertensivo'),
            value: _frTratado,
            onChanged: (v) => setState(() => _frTratado = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Tabagista atual'),
            value: _frTabagista,
            onChanged: (v) => setState(() => _frTabagista = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Diagnóstico de Diabetes Mellitus'),
            value: _frDiabetico,
            onChanged: (v) => setState(() => _frDiabetico = v),
          ),
        ],
      ),
    );
  }

  // ─── ABA 2: CHA2DS2-VASc ───
  Widget _buildCha2ds2VascTab() {
    final result = MedicalCalculatorsService.calcularCha2ds2Vasc(
      idade: _chIdade,
      isFeminino: _chIsFeminino,
      insuficienciaCardiaca: _chIc,
      hipertensao: _chHa,
      diabetes: _chDm,
      avcOuAitPrevio: _chAvc,
      doencaVascular: _chVas,
    );

    final isAlto = result.pontuacao >= 2;
    final badgeColor = isAlto ? AppColors.riskCritico : (result.pontuacao == 1 ? AppColors.riskAtencao : AppColors.riskEstavel);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClinicalCard(
            backgroundColor: badgeColor.withValues(alpha: 0.08),
            borderColor: badgeColor.withValues(alpha: 0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Escore CHA₂DS₂-VASc', style: AppTypography.titleSmall),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 20, color: AppColors.primary),
                      tooltip: 'Copiar escore',
                      onPressed: () => _copiarTexto(
                        'Escore CHA2DS2-VASc: ${result.pontuacao} ponto(s) (Risco AVC: ${result.riscoAvcAno}% ao ano). ${result.recomendacao}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${result.pontuacao} pts',
                      style: AppTypography.displayLarge.copyWith(color: badgeColor, fontSize: 36),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Risco AVC: ${result.riscoAvcAno}%/ano',
                      style: AppTypography.titleSmall.copyWith(color: badgeColor),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  result.recomendacao,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.navyDark),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text('Fatores de Risco Clínico', style: AppTypography.titleSmall),
          const SizedBox(height: 8),

          _NumberInput(
            label: 'Idade do Paciente',
            valor: _chIdade,
            onChanged: (v) => setState(() => _chIdade = v),
          ),
          const SizedBox(height: 8),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('C — Insuficiência Cardíaca Congestiva (+1)'),
            value: _chIc,
            onChanged: (v) => setState(() => _chIc = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('H — Hipertensão Arterial Sistêmica (+1)'),
            value: _chHa,
            onChanged: (v) => setState(() => _chHa = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('D — Diabetes Mellitus (+1)'),
            value: _chDm,
            onChanged: (v) => setState(() => _chDm = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('S₂ — AVC / AIT / Tromboembolismo prévio (+2)'),
            value: _chAvc,
            onChanged: (v) => setState(() => _chAvc = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('V — Doença Vascular (IAM, DAOP, placa aórtica) (+1)'),
            value: _chVas,
            onChanged: (v) => setState(() => _chVas = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Sc — Sexo Feminino (+1)'),
            value: _chIsFeminino,
            onChanged: (v) => setState(() => _chIsFeminino = v),
          ),
        ],
      ),
    );
  }

  // ─── ABA 3: CKD-EPI ───
  Widget _buildCkdEpiTab() {
    final creatinina = double.tryParse(_ckCreatininaController.text) ?? 1.0;
    final result = MedicalCalculatorsService.calcularCkdEpi(
      creatinina: creatinina,
      idade: _ckIdade,
      isFeminino: _ckIsFeminino,
    );

    final isGrave = result.tfg < 30.0;
    final isAlerta = result.tfg < 60.0 && !isGrave;
    final badgeColor = isGrave ? AppColors.riskCritico : (isAlerta ? AppColors.riskAtencao : AppColors.riskEstavel);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClinicalCard(
            backgroundColor: badgeColor.withValues(alpha: 0.08),
            borderColor: badgeColor.withValues(alpha: 0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Taxa de Filtração Glomerular (CKD-EPI)', style: AppTypography.titleSmall),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 20, color: AppColors.primary),
                      tooltip: 'Copiar TFG',
                      onPressed: () => _copiarTexto(
                        'TFG (CKD-EPI): ${result.tfg} mL/min/1.73m² (${result.estagio} - ${result.descricao}). Conduta: ${result.conduta}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${result.tfg}',
                      style: AppTypography.displayLarge.copyWith(color: badgeColor, fontSize: 36),
                    ),
                    const SizedBox(width: 8),
                    Text('mL/min/1.73m²', style: AppTypography.bodySmall),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(6)),
                      child: Text(result.estagio, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(result.descricao, style: AppTypography.titleSmall.copyWith(fontSize: 13)),
                const SizedBox(height: 8),
                Text(result.conduta, style: AppTypography.bodyMedium.copyWith(color: AppColors.navyDark)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text('Dados Laboratoriais', style: AppTypography.titleSmall),
          const SizedBox(height: 12),

          TextField(
            controller: _ckCreatininaController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (v) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Creatinina Sérica (mg/dL)',
              hintText: 'Ex: 1.1',
              prefixIcon: Icon(Icons.biotech_rounded),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _NumberInput(
                  label: 'Idade',
                  valor: _ckIdade,
                  onChanged: (v) => setState(() => _ckIdade = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sexo', style: AppTypography.bodySmall),
                    const SizedBox(height: 4),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: true, label: Text('Feminino')),
                        ButtonSegment(value: false, label: Text('Masculino')),
                      ],
                      selected: {_ckIsFeminino},
                      onSelectionChanged: (val) => setState(() => _ckIsFeminino = val.first),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── ABA 4: IMC & SUPERFÍCIE CORPÓREA ───
  Widget _buildImcTab() {
    final peso = double.tryParse(_imcPesoController.text) ?? 70.0;
    final altura = double.tryParse(_imcAlturaController.text) ?? 1.70;
    final result = MedicalCalculatorsService.calcularImc(pesoKg: peso, alturaMetros: altura);

    final isAlterado = result.imc >= 30.0 || result.imc < 18.5;
    final badgeColor = isAlterado ? AppColors.riskCritico : (result.imc >= 25.0 ? AppColors.riskAtencao : AppColors.riskEstavel);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClinicalCard(
            backgroundColor: badgeColor.withValues(alpha: 0.08),
            borderColor: badgeColor.withValues(alpha: 0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Composição Antropométrica', style: AppTypography.titleSmall),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 20, color: AppColors.primary),
                      tooltip: 'Copiar IMC',
                      onPressed: () => _copiarTexto(
                        'IMC: ${result.imc} kg/m² (${result.classificacao}). Peso Ideal: ${result.pesoIdealMin}-${result.pesoIdealMax} kg. Superfície Corpórea: ${result.superficieCorporea} m².',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${result.imc}',
                      style: AppTypography.displayLarge.copyWith(color: badgeColor, fontSize: 36),
                    ),
                    const SizedBox(width: 8),
                    Text('kg/m²', style: AppTypography.bodySmall),
                    const SizedBox(width: 12),
                    Text(
                      result.classificacao,
                      style: AppTypography.titleSmall.copyWith(color: badgeColor),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Faixa de Peso Ideal (OMS)', style: AppTypography.bodySmall),
                        Text(
                          '${result.pesoIdealMin} kg a ${result.pesoIdealMax} kg',
                          style: AppTypography.titleSmall.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Superfície Corpórea (Mosteller)', style: AppTypography.bodySmall),
                        Text(
                          '${result.superficieCorporea} m²',
                          style: AppTypography.titleSmall.copyWith(fontSize: 13, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text('Parâmetros Antropométricos', style: AppTypography.titleSmall),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _imcPesoController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Peso Atual (kg)',
                    hintText: 'Ex: 75.5',
                    prefixIcon: Icon(Icons.monitor_weight_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _imcAlturaController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Altura (m)',
                    hintText: 'Ex: 1.72',
                    prefixIcon: Icon(Icons.height_rounded),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NumberInput extends StatelessWidget {
  final String label;
  final int valor;
  final ValueChanged<int> onChanged;

  const _NumberInput({
    required this.label,
    required this.valor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySmall),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.slateBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 18),
                onPressed: () => onChanged(valor - 1),
              ),
              Text(
                '$valor',
                style: AppTypography.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 18),
                onPressed: () => onChanged(valor + 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
