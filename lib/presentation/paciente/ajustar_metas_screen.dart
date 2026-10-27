import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/clinical_card.dart';
import '../../core/widgets/custom_button.dart';
import '../../data/models/paciente_model.dart';
import '../../data/repositories/pacientes_repository.dart';

class AjustarMetasScreen extends ConsumerStatefulWidget {
  final String pacienteId;

  const AjustarMetasScreen({super.key, required this.pacienteId});

  @override
  ConsumerState<AjustarMetasScreen> createState() => _AjustarMetasScreenState();
}

class _AjustarMetasScreenState extends ConsumerState<AjustarMetasScreen> {
  late double _paSistolica;
  late double _paDiastolica;
  late double _glicemiaJejumMin;
  late double _glicemiaJejumMax;
  late double _glicemiaPosPrandial;
  final _pesoController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _pesoController.dispose();
    super.dispose();
  }

  void _initValores(Paciente paciente) {
    if (_initialized) return;
    _paSistolica = paciente.metas.paSistolicaMax;
    _paDiastolica = paciente.metas.paDiastolicaMax;
    _glicemiaJejumMin = paciente.metas.glicemiaJejumMin;
    _glicemiaJejumMax = paciente.metas.glicemiaJejumMax;
    _glicemiaPosPrandial = paciente.metas.glicemiaPosPrandialMax;
    if (paciente.metas.pesoMeta != null) {
      _pesoController.text = paciente.metas.pesoMeta!.toStringAsFixed(1);
    }
    _initialized = true;
  }

  void _aplicarPreset({
    required double sis,
    required double dia,
    required double glicMin,
    required double glicMax,
    required double glicPos,
  }) {
    HapticFeedback.selectionClick();
    setState(() {
      _paSistolica = sis;
      _paDiastolica = dia;
      _glicemiaJejumMin = glicMin;
      _glicemiaJejumMax = glicMax;
      _glicemiaPosPrandial = glicPos;
    });
  }

  void _salvarMetas() {
    HapticFeedback.mediumImpact();
    final repo = ref.read(pacientesRepositoryProvider);
    final pesoVal = double.tryParse(_pesoController.text.replaceAll(',', '.'));

    final novasMetas = MetasClinicas(
      paSistolicaMax: _paSistolica,
      paDiastolicaMax: _paDiastolica,
      glicemiaJejumMin: _glicemiaJejumMin,
      glicemiaJejumMax: _glicemiaJejumMax,
      glicemiaPosPrandialMax: _glicemiaPosPrandial,
      pesoMeta: pesoVal,
    );

    repo.atualizarMetas(widget.pacienteId, novasMetas);
    ref.read(pacientesResumoProvider.notifier).recarregar();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Metas clínicas personalizadas atualizadas com sucesso!'),
        backgroundColor: AppColors.riskEstavelText,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final paciente = ref.watch(pacientesRepositoryProvider).obterPacientePorId(widget.pacienteId);

    if (paciente == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Metas Clínicas')),
        body: const Center(child: Text('Paciente não encontrado')),
      );
    }

    _initValores(paciente);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Metas Clínicas • ${paciente.nome.split(" ").first}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Informativo
            ClinicalCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.track_changes_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Alvos Terapêuticos Individuais', style: AppTypography.titleSmall),
                        const SizedBox(height: 2),
                        Text(
                          'O cálculo de Time in Range (TIR %) e os alertas de pico serão recalculados para este paciente.',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Presets Baseados em Evidências
            Text('PRESETS RÁPIDOS POR PROTOCOLO', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _PresetChip(
                    title: 'Padrão SBC/ADA',
                    subtitle: '≤ 130/80 • 70-100 mg/dL',
                    onTap: () => _aplicarPreset(sis: 130, dia: 80, glicMin: 70, glicMax: 100, glicPos: 140),
                  ),
                  const SizedBox(width: 8),
                  _PresetChip(
                    title: 'Idoso Frágil / Quedas',
                    subtitle: '≤ 140/90 • 80-130 mg/dL',
                    onTap: () => _aplicarPreset(sis: 140, dia: 90, glicMin: 80, glicMax: 130, glicPos: 160),
                  ),
                  const SizedBox(width: 8),
                  _PresetChip(
                    title: 'Alto Risco / DRC',
                    subtitle: '≤ 120/80 • 70-100 mg/dL',
                    onTap: () => _aplicarPreset(sis: 120, dia: 80, glicMin: 70, glicMax: 100, glicPos: 140),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bloco de Pressão Arterial
            ClinicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.favorite_rounded, color: AppColors.riskCritico, size: 20),
                      const SizedBox(width: 8),
                      Text('Pressão Arterial Alvo (Máxima)', style: AppTypography.titleSmall),
                      const Spacer(),
                      Text(
                        '${_paSistolica.toInt()}/${_paDiastolica.toInt()} mmHg',
                        style: AppTypography.titleMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Sistólica
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Sistólica Máxima:', style: AppTypography.bodyMedium),
                      Text('${_paSistolica.toInt()} mmHg', style: AppTypography.titleSmall),
                    ],
                  ),
                  Slider(
                    value: _paSistolica,
                    min: 110,
                    max: 160,
                    divisions: 10,
                    label: '${_paSistolica.toInt()} mmHg',
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _paSistolica = v),
                  ),

                  // Diastólica
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Diastólica Máxima:', style: AppTypography.bodyMedium),
                      Text('${_paDiastolica.toInt()} mmHg', style: AppTypography.titleSmall),
                    ],
                  ),
                  Slider(
                    value: _paDiastolica,
                    min: 65,
                    max: 100,
                    divisions: 7,
                    label: '${_paDiastolica.toInt()} mmHg',
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _paDiastolica = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Bloco de Glicemia
            ClinicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.water_drop_rounded, color: AppColors.purpleConsult, size: 20),
                      const SizedBox(width: 8),
                      Text('Glicemia Alvo', style: AppTypography.titleSmall),
                      const Spacer(),
                      Text(
                        '${_glicemiaJejumMin.toInt()}-${_glicemiaJejumMax.toInt()} mg/dL',
                        style: AppTypography.titleMedium.copyWith(color: AppColors.purpleConsult, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Glicemia Jejum Máxima
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Jejum Limite Máximo:', style: AppTypography.bodyMedium),
                      Text('${_glicemiaJejumMax.toInt()} mg/dL', style: AppTypography.titleSmall),
                    ],
                  ),
                  Slider(
                    value: _glicemiaJejumMax,
                    min: 90,
                    max: 160,
                    divisions: 14,
                    label: '${_glicemiaJejumMax.toInt()} mg/dL',
                    activeColor: AppColors.purpleConsult,
                    onChanged: (v) => setState(() => _glicemiaJejumMax = v),
                  ),

                  // Glicemia Pós-Prandial
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Pós-Prandial Limite:', style: AppTypography.bodyMedium),
                      Text('${_glicemiaPosPrandial.toInt()} mg/dL', style: AppTypography.titleSmall),
                    ],
                  ),
                  Slider(
                    value: _glicemiaPosPrandial,
                    min: 120,
                    max: 200,
                    divisions: 16,
                    label: '${_glicemiaPosPrandial.toInt()} mg/dL',
                    activeColor: AppColors.purpleConsult,
                    onChanged: (v) => setState(() => _glicemiaPosPrandial = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Bloco de Peso Meta
            ClinicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.monitor_weight_outlined, color: AppColors.slateTextMuted, size: 20),
                      const SizedBox(width: 8),
                      Text('Peso Meta (Opcional)', style: AppTypography.titleSmall),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _pesoController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Peso Meta (kg)',
                      hintText: 'Ex: 72.5',
                      suffixText: 'kg',
                      prefixIcon: Icon(Icons.scale_rounded),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botão Salvar
            CustomButton(
              label: 'Salvar Metas Clínicas',
              icon: Icons.check_circle_rounded,
              onPressed: _salvarMetas,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PresetChip({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.slateBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.titleSmall.copyWith(fontSize: 12)),
            const SizedBox(height: 2),
            Text(subtitle, style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}
