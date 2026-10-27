import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/clinical_card.dart';
import '../../core/widgets/risk_badge.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/models/paciente_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/pacientes_repository.dart';

enum OrdemTriagem {
  gravidade('🚨 Gravidade (Críticos)', Icons.warning_amber_rounded),
  recente('⏱️ Mais Recente', Icons.access_time_rounded),
  adesao('📉 Menor Adesão', Icons.trending_down_rounded),
  alfabetica('🔤 Nome (A-Z)', Icons.sort_by_alpha_rounded);

  final String label;
  final IconData icon;
  const OrdemTriagem(this.label, this.icon);
}

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _searchController = TextEditingController();
  StatusRisco? _filtroStatus;
  OrdemTriagem _ordem = OrdemTriagem.gravidade;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(pacientesResumoProvider.notifier).filtrar(value, statusFiltro: _filtroStatus);
  }

  void _selecionarFiltro(StatusRisco? status) {
    setState(() => _filtroStatus = status);
    ref.read(pacientesResumoProvider.notifier).filtrar(_searchController.text, statusFiltro: status);
  }

  @override
  Widget build(BuildContext context) {
    final profissional = ref.watch(currentProfissionalProvider);
    final pacientesResumo = ref.watch(pacientesResumoProvider);
    final repo = ref.read(pacientesRepositoryProvider);
    final todos = repo.obterResumos();

    final countCritico = todos.where((p) => p.status == StatusRisco.critico).length;
    final countAtencao = todos.where((p) => p.status == StatusRisco.atencao).length;
    final countEstavel = todos.where((p) => p.status == StatusRisco.estavel).length;

    // Aplicar ordenação de triagem clínica
    final listaOrdenada = List<PacienteResumo>.from(pacientesResumo);
    switch (_ordem) {
      case OrdemTriagem.gravidade:
        listaOrdenada.sort((a, b) {
          final pesoA = a.status == StatusRisco.critico ? 0 : (a.status == StatusRisco.atencao ? 1 : 2);
          final pesoB = b.status == StatusRisco.critico ? 0 : (b.status == StatusRisco.atencao ? 1 : 2);
          return pesoA.compareTo(pesoB);
        });
        break;
      case OrdemTriagem.recente:
        listaOrdenada.sort((a, b) {
          final dtA = a.ultimaAfericao?.em ?? DateTime(2000);
          final dtB = b.ultimaAfericao?.em ?? DateTime(2000);
          return dtB.compareTo(dtA);
        });
        break;
      case OrdemTriagem.adesao:
        listaOrdenada.sort((a, b) {
          final adA = a.adesao7d ?? 1.0;
          final adB = b.adesao7d ?? 1.0;
          return adA.compareTo(adB);
        });
        break;
      case OrdemTriagem.alfabetica:
        listaOrdenada.sort((a, b) => a.paciente.nome.compareTo(b.paciente.nome));
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              profissional?.nome ?? 'Dra. Helena Moraes',
              style: AppTypography.titleMedium,
            ),
            Text(
              profissional?.carimbo ?? 'CRM-RJ 123456',
              style: AppTypography.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Calculadoras Médicas no Bolso',
            icon: const Icon(Icons.calculate_outlined, color: AppColors.primary),
            onPressed: () => context.push('/calculadoras'),
          ),
          IconButton(
            tooltip: 'Vincular Paciente / Scanner QR',
            icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary),
            onPressed: () => context.push('/vincular-paciente'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Barra de Busca com botão de ordenação
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Buscar paciente ou CID-10...',
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.slateTextMuted),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<OrdemTriagem>(
                    initialValue: _ordem,
                    tooltip: 'Critério de Triagem',
                    onSelected: (novaOrdem) {
                      setState(() => _ordem = novaOrdem);
                    },
                    itemBuilder: (context) => OrdemTriagem.values.map((o) {
                      return PopupMenuItem(
                        value: o,
                        child: Row(
                          children: [
                            Icon(o.icon, size: 18, color: _ordem == o ? AppColors.primary : AppColors.slateTextMuted),
                            const SizedBox(width: 10),
                            Text(o.label, style: AppTypography.bodyMedium),
                          ],
                        ),
                      );
                    }).toList(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.slateBorder),
                      ),
                      child: const Icon(Icons.swap_vert_rounded, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),

            // Chips de Triagem de Risco
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _FiltroChip(
                    label: 'Todos (${todos.length})',
                    isSelected: _filtroStatus == null,
                    onTap: () => _selecionarFiltro(null),
                  ),
                  const SizedBox(width: 8),
                  _FiltroChip(
                    label: 'Crítico ($countCritico)',
                    color: AppColors.riskCritico,
                    isSelected: _filtroStatus == StatusRisco.critico,
                    onTap: () => _selecionarFiltro(StatusRisco.critico),
                  ),
                  const SizedBox(width: 8),
                  _FiltroChip(
                    label: 'Atenção ($countAtencao)',
                    color: AppColors.riskAtencao,
                    isSelected: _filtroStatus == StatusRisco.atencao,
                    onTap: () => _selecionarFiltro(StatusRisco.atencao),
                  ),
                  const SizedBox(width: 8),
                  _FiltroChip(
                    label: 'Estável ($countEstavel)',
                    color: AppColors.riskEstavel,
                    isSelected: _filtroStatus == StatusRisco.estavel,
                    onTap: () => _selecionarFiltro(StatusRisco.estavel),
                  ),
                ],
              ),
            ),

            // Lista de Pacientes
            Expanded(
              child: listaOrdenada.isEmpty
                  ? EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'Nenhum paciente encontrado',
                      description: 'Verifique os termos da busca ou limpe o filtro de risco selecionado.',
                      buttonLabel: 'Limpar Filtros',
                      onButtonPressed: () {
                        _searchController.clear();
                        _selecionarFiltro(null);
                      },
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: listaOrdenada.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = listaOrdenada[index];
                        final pac = item.paciente;

                        return ClinicalCard(
                          onTap: () => context.push('/paciente/${pac.id}'),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Topo do card com Nome e Badge de Risco
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors.primaryLight,
                                    foregroundColor: AppColors.primaryDark,
                                    radius: 20,
                                    child: Text(
                                      pac.nome.split(' ').map((n) => n[0]).take(2).join(),
                                      style: AppTypography.titleSmall,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          pac.nome,
                                          style: AppTypography.titleSmall,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${pac.idade} anos • ${pac.sexo == Sexo.f ? 'Feminino' : 'Masculino'}',
                                          style: AppTypography.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  RiskBadge(level: item.status == StatusRisco.critico
                                      ? RiskLevel.critico
                                      : item.status == StatusRisco.atencao
                                          ? RiskLevel.atencao
                                          : RiskLevel.estavel),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Motivo do Status Clínico (Se houver alerta/desvio)
                              if (item.motivoStatus != null && item.motivoStatus!.isNotEmpty) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: item.status == StatusRisco.critico
                                        ? AppColors.riskCriticoBg
                                        : (item.status == StatusRisco.atencao ? AppColors.riskAtencaoBg : AppColors.riskEstavelBg),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: item.status == StatusRisco.critico
                                          ? AppColors.riskCritico.withValues(alpha: 0.3)
                                          : (item.status == StatusRisco.atencao ? AppColors.riskAtencao.withValues(alpha: 0.3) : AppColors.riskEstavel.withValues(alpha: 0.3)),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        item.status == StatusRisco.critico
                                            ? Icons.warning_amber_rounded
                                            : Icons.info_outline_rounded,
                                        size: 15,
                                        color: item.status == StatusRisco.critico
                                            ? AppColors.riskCriticoText
                                            : (item.status == StatusRisco.atencao ? AppColors.riskAtencaoText : AppColors.riskEstavelText),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          item.motivoStatus!,
                                          style: AppTypography.bodySmall.copyWith(
                                            color: item.status == StatusRisco.critico
                                                ? AppColors.riskCriticoText
                                                : (item.status == StatusRisco.atencao ? AppColors.riskAtencaoText : AppColors.riskEstavelText),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],

                              // Diagnósticos
                              if (pac.diagnosticos.isNotEmpty) ...[
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: pac.diagnosticos.map((d) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.slateLight,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${d.codigoCid} - ${d.descricao}',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.navyMedium,
                                          fontSize: 10,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 12),
                              ],

                              const Divider(),
                              const SizedBox(height: 10),

                              // Rodapé: Última Aferição & Adesão
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if (item.ultimaAfericao != null) ...[
                                    Row(
                                      children: [
                                        Icon(
                                          item.ultimaAfericao!.tipo == 'pressao'
                                              ? Icons.favorite_rounded
                                              : Icons.water_drop_rounded,
                                          size: 16,
                                          color: item.status == StatusRisco.critico
                                              ? AppColors.riskCritico
                                              : AppColors.primary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          item.ultimaAfericao!.descricao,
                                          style: AppTypography.titleSmall.copyWith(
                                            fontSize: 13,
                                            color: item.status == StatusRisco.critico
                                                ? AppColors.riskCriticoText
                                                : AppColors.navyDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ] else
                                    Text('Sem telemetria recente', style: AppTypography.bodySmall),

                                  if (item.adesao7d != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: item.adesao7d! >= 0.8
                                            ? AppColors.riskEstavelBg
                                            : AppColors.riskAtencaoBg,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Adesão ${(item.adesao7d! * 100).toStringAsFixed(0)}%',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: item.adesao7d! >= 0.8
                                              ? AppColors.riskEstavelText
                                              : AppColors.riskAtencaoText,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FiltroChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FiltroChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primary;

    return Material(
      color: isSelected ? activeColor.withValues(alpha: 0.15) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
        side: BorderSide(
          color: isSelected ? activeColor : AppColors.slateBorder,
          width: 1.2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? activeColor : AppColors.navyDark,
            ),
          ),
        ),
      ),
    );
  }
}
