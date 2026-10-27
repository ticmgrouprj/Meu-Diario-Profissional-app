import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/clinical_card.dart';
import '../../../data/models/paciente_model.dart';
import '../../../data/models/vitals_model.dart';

class VitalsTab extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // Últimos 14 registros para o gráfico móvel caber confortavelmente
    final ultimasPressoes = pressoes.length > 14
        ? pressoes.sublist(pressoes.length - 14)
        : pressoes;

    final ultimasGlicemias = glicemias.length > 14
        ? glicemias.sublist(glicemias.length - 14)
        : glicemias;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    if (ultimasPressoes.isNotEmpty)
                      Text(
                        'Última: ${ultimasPressoes.last.sistolica}/${ultimasPressoes.last.diastolica}',
                        style: AppTypography.titleSmall.copyWith(
                          color: ultimasPressoes.last.sistolica >= 140
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
                  child: ultimasPressoes.isEmpty
                      ? const Center(child: Text('Sem registros de PA'))
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
                                spots: ultimasPressoes.asMap().entries.map((entry) {
                                  return FlSpot(entry.key.toDouble(), entry.value.sistolica.toDouble());
                                }).toList(),
                                isCurved: true,
                                color: const Color(0xFFEF4444),
                                barWidth: 3,
                                dotData: const FlDotData(show: true),
                              ),
                              // Linha Diastólica
                              LineChartBarData(
                                spots: ultimasPressoes.asMap().entries.map((entry) {
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
          if (ultimasGlicemias.isNotEmpty) ...[
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
                        '${ultimasGlicemias.last.valor} mg/dL',
                        style: AppTypography.titleSmall.copyWith(
                          color: ultimasGlicemias.last.valor < 70 || ultimasGlicemias.last.valor > 180
                              ? AppColors.riskCritico
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _Legenda(cor: const Color(0xFF0284C7), label: 'Glicemia (Meta: 70 - 140 mg/dL)'),
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
                            spots: ultimasGlicemias.asMap().entries.map((entry) {
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
          if (pesos.isNotEmpty) ...[
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
                        valor: '${pesos.last.peso.toStringAsFixed(1)} kg',
                      ),
                      if (paciente.altura != null) ...[
                        _MetricaItem(
                          label: 'Altura',
                          valor: '${paciente.altura!.toStringAsFixed(2)} m',
                        ),
                        _MetricaItem(
                          label: 'IMC Calculado',
                          valor: (pesos.last.peso / (paciente.altura! * paciente.altura!)).toStringAsFixed(1),
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
