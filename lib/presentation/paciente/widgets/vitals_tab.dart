import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/clinical_card.dart';
import '../../../data/models/paciente_model.dart';
import '../../../data/models/vitals_model.dart';

class VitalsTab extends StatefulWidget {
  final Paciente paciente;
  final List<RegistroPressao> pressoes;
  final List<RegistroGlicemia> glicemias;
  final List<RegistroPeso> pesos;

  const VitalsTab({
    super.key,
    required this.paciente,
    required this.pressoes,
    required this.glicemias,
    required this.pesos,
  });

  @override
  State<VitalsTab> createState() => _VitalsTabState();
}

class _VitalsTabState extends State<VitalsTab> {
  String _filtroPeriodo = '14D'; // '7D' | '14D' | '30D' | 'Tudo'

  List<T> _filtrarPorPeriodo<T>(List<T> lista, int diasMax) {
    if (diasMax == 0 || lista.length <= diasMax) {
      return lista;
    }
    return lista.sublist(lista.length - diasMax);
  }

  int get _limiteDias {
    switch (_filtroPeriodo) {
      case '7D':
        return 7;
      case '14D':
        return 14;
      case '30D':
        return 30;
      default:
        return 0; // Tudo
    }
  }

  @override
  Widget build(BuildContext context) {
    final limite = _limiteDias;
    final pressoesFiltradas = _filtrarPorPeriodo(widget.pressoes, limite > 0 ? limite * 2 : 0);
    final glicemiasFiltradas = _filtrarPorPeriodo(widget.glicemias, limite > 0 ? limite * 2 : 0);
    final pesosFiltrados = _filtrarPorPeriodo(widget.pesos, limite > 0 ? (limite / 3).ceil() : 0);

    // ─── CÁLCULOS CLÍNICOS AVANÇADOS ───
    // 1. Médias de Pressão Arterial
    double mediaSis = 0;
    double mediaDia = 0;
    int paNoAlvo = 0;
    int picosPa = 0;

    if (pressoesFiltradas.isNotEmpty) {
      final somaPas = pressoesFiltradas.fold<int>(0, (acc, p) => acc + p.sistolica);
      final somaPad = pressoesFiltradas.fold<int>(0, (acc, p) => acc + p.diastolica);
      mediaSis = somaPas / pressoesFiltradas.length;
      mediaDia = somaPad / pressoesFiltradas.length;

      paNoAlvo = pressoesFiltradas.where((p) =>
          p.sistolica <= widget.paciente.metas.paSistolicaMax &&
          p.diastolica <= widget.paciente.metas.paDiastolicaMax).length;

      picosPa = pressoesFiltradas.where((p) => p.sistolica >= 140 || p.diastolica >= 90).length;
    }
    final timeInRangePa = pressoesFiltradas.isNotEmpty
        ? (paNoAlvo / pressoesFiltradas.length) * 100
        : 100.0;

    // 2. Médias de Glicemia
    double mediaGlic = 0;
    int glicNoAlvo = 0;
    if (glicemiasFiltradas.isNotEmpty) {
      final somaGlic = glicemiasFiltradas.fold<int>(0, (acc, g) => acc + g.valor);
      mediaGlic = somaGlic / glicemiasFiltradas.length;

      glicNoAlvo = glicemiasFiltradas.where((g) =>
          g.valor >= widget.paciente.metas.glicemiaJejumMin &&
          g.valor <= widget.paciente.metas.glicemiaPosPrandialMax).length;
    }
    final timeInRangeGlic = glicemiasFiltradas.isNotEmpty
        ? (glicNoAlvo / glicemiasFiltradas.length) * 100
        : 100.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── SELETOR DE PERÍODO TEMPORAL ───
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Janela de Telemetria', style: AppTypography.titleSmall),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.slateBorder),
                ),
                child: Row(
                  children: [
                    _BotaoPeriodo(
                      label: '7D',
                      isSelected: _filtroPeriodo == '7D',
                      onTap: () => setState(() => _filtroPeriodo = '7D'),
                    ),
                    _BotaoPeriodo(
                      label: '14D',
                      isSelected: _filtroPeriodo == '14D',
                      onTap: () => setState(() => _filtroPeriodo = '14D'),
                    ),
                    _BotaoPeriodo(
                      label: '30D',
                      isSelected: _filtroPeriodo == '30D',
                      onTap: () => setState(() => _filtroPeriodo = '30D'),
                    ),
                    _BotaoPeriodo(
                      label: 'Tudo',
                      isSelected: _filtroPeriodo == 'Tudo',
                      onTap: () => setState(() => _filtroPeriodo = 'Tudo'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ─── CARD DE MÉTRICAS CLÍNICAS (TIME IN RANGE & MÉDIAS) ───
          ClinicalCard(
            backgroundColor: const Color(0xFFF0FDF4),
            borderColor: const Color(0xFFBBF7D0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.analytics_outlined, color: Color(0xFF16A34A), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Controle no Período ($_filtroPeriodo)',
                          style: AppTypography.titleSmall.copyWith(color: const Color(0xFF166534)),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: timeInRangePa >= 70 ? AppColors.riskEstavelBg : AppColors.riskAtencaoBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${timeInRangePa.toInt()}% no Alvo',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: timeInRangePa >= 70 ? AppColors.riskEstavelText : AppColors.riskAtencaoText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _MetricaDestaque(
                      label: 'PA Média',
                      valor: pressoesFiltradas.isNotEmpty ? '${mediaSis.round()}/${mediaDia.round()}' : '—',
                      unidade: 'mmHg',
                    ),
                    _MetricaDestaque(
                      label: 'Tempo no Alvo',
                      valor: '${timeInRangePa.round()}%',
                      unidade: 'meta ≤ 130/80',
                    ),
                    _MetricaDestaque(
                      label: 'Picos de PA',
                      valor: '$picosPa',
                      unidade: '≥ 140/90',
                      destaqueAlerta: picosPa > 0,
                    ),
                    if (glicemiasFiltradas.isNotEmpty)
                      _MetricaDestaque(
                        label: 'Glicemia Média',
                        valor: '${mediaGlic.round()}',
                        unidade: 'mg/dL',
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ─── 1. GRÁFICO DE PRESSÃO ARTERIAL ───
          ClinicalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.favorite_rounded, color: AppColors.riskCritico, size: 20),
                        const SizedBox(width: 8),
                        Text('Pressão Arterial (mmHg)', style: AppTypography.titleSmall),
                      ],
                    ),
                    if (pressoesFiltradas.isNotEmpty)
                      Text(
                        'Última: ${pressoesFiltradas.last.sistolica}/${pressoesFiltradas.last.diastolica}',
                        style: AppTypography.titleSmall.copyWith(
                          color: pressoesFiltradas.last.sistolica >= 140
                              ? AppColors.riskCritico
                              : AppColors.primary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _Legenda(cor: const Color(0xFFEF4444), label: 'Sistólica'),
                    const SizedBox(width: 12),
                    _Legenda(cor: const Color(0xFF3B82F6), label: 'Diastólica'),
                    const SizedBox(width: 12),
                    _Legenda(cor: const Color(0xFF10B981), label: 'Alvo (≤130/80)', isLine: true),
                  ],
                ),
                const SizedBox(height: 20),

                // Gráfico fl_chart
                SizedBox(
                  height: 180,
                  child: pressoesFiltradas.isEmpty
                      ? const Center(child: Text('Sem registros de PA no período selecionado'))
                      : LineChart(
                          LineChartData(
                            gridData: const FlGridData(
                              show: true,
                              drawVerticalLine: false,
                            ),
                            titlesData: const FlTitlesData(
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 32,
                                  interval: 40,
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            minY: 50,
                            maxY: 200,
                            lineTouchData: LineTouchData(
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipItems: (touchedSpots) {
                                  return touchedSpots.map((spot) {
                                    final isSis = spot.barIndex == 0;
                                    return LineTooltipItem(
                                      '${isSis ? "Sis" : "Dia"}: ${spot.y.toInt()} mmHg',
                                      TextStyle(
                                        color: isSis ? const Color(0xFFEF4444) : const Color(0xFF3B82F6),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                            lineBarsData: [
                              // Linha Sistólica
                              LineChartBarData(
                                spots: pressoesFiltradas.asMap().entries.map((entry) {
                                  return FlSpot(entry.key.toDouble(), entry.value.sistolica.toDouble());
                                }).toList(),
                                isCurved: true,
                                color: const Color(0xFFEF4444),
                                barWidth: 3,
                                dotData: const FlDotData(show: true),
                              ),
                              // Linha Diastólica
                              LineChartBarData(
                                spots: pressoesFiltradas.asMap().entries.map((entry) {
                                  return FlSpot(entry.key.toDouble(), entry.value.diastolica.toDouble());
                                }).toList(),
                                isCurved: true,
                                color: const Color(0xFF3B82F6),
                                barWidth: 3,
                                dotData: const FlDotData(show: true),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ─── 2. GRÁFICO DE GLICEMIA CAPILAR ───
          if (glicemiasFiltradas.isNotEmpty) ...[
            ClinicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.water_drop_rounded, color: Color(0xFF0284C7), size: 20),
                          const SizedBox(width: 8),
                          Text('Glicemia Capilar (mg/dL)', style: AppTypography.titleSmall),
                        ],
                      ),
                      Text(
                        '${glicemiasFiltradas.last.valor} mg/dL',
                        style: AppTypography.titleSmall.copyWith(
                          color: glicemiasFiltradas.last.valor < 70 || glicemiasFiltradas.last.valor > 180
                              ? AppColors.riskCritico
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _Legenda(cor: const Color(0xFF0284C7), label: 'Glicemia'),
                      const SizedBox(width: 12),
                      _Legenda(cor: const Color(0xFF10B981), label: 'TIR: ${timeInRangeGlic.round()}% no alvo', isLine: true),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 160,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: true, drawVerticalLine: false),
                        titlesData: const FlTitlesData(
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true, reservedSize: 32, interval: 60),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minY: 40,
                        maxY: 260,
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                return LineTooltipItem(
                                  '${spot.y.toInt()} mg/dL',
                                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                );
                              }).toList();
                            },
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: glicemiasFiltradas.asMap().entries.map((entry) {
                              return FlSpot(entry.key.toDouble(), entry.value.valor.toDouble());
                            }).toList(),
                            isCurved: true,
                            color: const Color(0xFF0284C7),
                            barWidth: 3,
                            belowBarData: BarAreaData(
                              show: true,
                              color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ─── 3. RESUMO PONDERAL / IMC ───
          if (pesosFiltrados.isNotEmpty) ...[
            ClinicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.monitor_weight_rounded, color: Color(0xFF8B5CF6), size: 20),
                      const SizedBox(width: 8),
                      Text('Evolução do Peso & IMC', style: AppTypography.titleSmall),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MetricaItem(
                        label: 'Peso Atual',
                        valor: '${pesosFiltrados.last.peso.toStringAsFixed(1)} kg',
                      ),
                      if (widget.paciente.altura != null) ...[
                        _MetricaItem(
                          label: 'Altura',
                          valor: '${widget.paciente.altura!.toStringAsFixed(2)} m',
                        ),
                        _MetricaItem(
                          label: 'IMC Calculado',
                          valor: (pesosFiltrados.last.peso / (widget.paciente.altura! * widget.paciente.altura!)).toStringAsFixed(1),
                          destaque: true,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BotaoPeriodo extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BotaoPeriodo({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.slateTextMuted,
          ),
        ),
      ),
    );
  }
}

class _MetricaDestaque extends StatelessWidget {
  final String label;
  final String valor;
  final String unidade;
  final bool destaqueAlerta;

  const _MetricaDestaque({
    required this.label,
    required this.valor,
    required this.unidade,
    this.destaqueAlerta = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF166534))),
        const SizedBox(height: 2),
        Text(
          valor,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: destaqueAlerta ? AppColors.riskCritico : const Color(0xFF14532D),
          ),
        ),
        Text(unidade, style: const TextStyle(fontSize: 9, color: Color(0xFF15803D))),
      ],
    );
  }
}

class _Legenda extends StatelessWidget {
  final Color cor;
  final String label;
  final bool isLine;

  const _Legenda({required this.cor, required this.label, this.isLine = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isLine ? 14 : 8,
          height: isLine ? 2 : 8,
          decoration: BoxDecoration(
            color: cor,
            shape: isLine ? BoxShape.rectangle : BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 10)),
      ],
    );
  }
}

class _MetricaItem extends StatelessWidget {
  final String label;
  final String valor;
  final bool destaque;

  const _MetricaItem({required this.label, required this.valor, this.destaque = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTypography.bodySmall),
        const SizedBox(height: 4),
        Text(
          valor,
          style: AppTypography.metricSmall.copyWith(
            color: destaque ? AppColors.primary : AppColors.navyDark,
          ),
        ),
      ],
    );
  }
}
