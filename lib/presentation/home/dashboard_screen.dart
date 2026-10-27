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

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _searchController = TextEditingController();
  StatusRisco? _filtroStatus;

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
            // Barra de Busca
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
              child: pacientesResumo.isEmpty
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
                      itemCount: pacientesResumo.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = pacientesResumo[index];
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
