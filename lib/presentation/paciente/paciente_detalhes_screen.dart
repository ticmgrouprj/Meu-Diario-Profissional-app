import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/risk_badge.dart';
import '../../data/models/paciente_model.dart';
import '../../data/repositories/pacientes_repository.dart';
import '../../data/repositories/clinico_repository.dart';
import 'widgets/vitals_tab.dart';
import 'widgets/medicamentos_tab.dart';
import 'widgets/documentos_tab.dart';
import 'widgets/soap_history_tab.dart';
import 'widgets/mensagens_tab.dart';

class PacienteDetalhesScreen extends ConsumerStatefulWidget {
  final String pacienteId;

  const PacienteDetalhesScreen({super.key, required this.pacienteId});

  @override
  ConsumerState<PacienteDetalhesScreen> createState() => _PacienteDetalhesScreenState();
}

class _PacienteDetalhesScreenState extends ConsumerState<PacienteDetalhesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _mostrarMenuAcoesClinicas(BuildContext context, Paciente pac) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Ações Clínicas para ${pac.nome.split(" ").first}',
                    style: AppTypography.titleMedium,
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.edit_note_rounded, color: AppColors.primary),
                  title: const Text('Evoluir Consulta SOAP'),
                  subtitle: const Text('Registro clínico em 4 passos com CID-10'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/paciente/${pac.id}/nova-consulta');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.receipt_long_rounded, color: Color(0xFF10B981)),
                  title: const Text('Nova Prescrição Digital'),
                  subtitle: const Text('Receituário com código QR e posologias'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/paciente/${pac.id}/nova-prescricao');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.verified_outlined, color: Color(0xFFF59E0B)),
                  title: const Text('Emitir Atestado Médico CFM'),
                  subtitle: const Text('Conformidade Resoluções 1.658/02 e 1.851/08'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/paciente/${pac.id}/novo-atestado');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.biotech_rounded, color: Color(0xFF0284C7)),
                  title: const Text('Pedido de Exames Laboratoriais'),
                  subtitle: const Text('Requisição oficial com justificativa'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/paciente/${pac.id}/novo-pedido-exame');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFEF4444)),
                  title: const Text('Gerar Relatório Clínico em PDF'),
                  subtitle: const Text('Laudo consolidado pronto para WhatsApp'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/paciente/${pac.id}/relatorio-pdf');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.video_camera_front_rounded, color: Color(0xFF8B5CF6)),
                  title: const Text('Iniciar Teleconsulta'),
                  subtitle: const Text('Sala de atendimento virtual e timer'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/paciente/${pac.id}/teleconsulta');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.mark_chat_read_rounded, color: Color(0xFF0284C7)),
                  title: const Text('Enviar Mensagem / Aviso Clínico'),
                  subtitle: const Text('Alerta de telemetria, retorno ou WhatsApp'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/paciente/${pac.id}/enviar-mensagem');
                  },
                ),
              ],
            ),

          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pacRepo = ref.watch(pacientesRepositoryProvider);
    final clinicoRepo = ref.watch(clinicoRepositoryProvider);

    final paciente = pacRepo.obterPacientePorId(widget.pacienteId);

    if (paciente == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Prontuário')),
        body: const Center(child: Text('Paciente não encontrado')),
      );
    }

    final statusRisco = pacRepo.obterResumos().firstWhere(
      (r) => r.paciente.id == paciente.id,
      orElse: () => PacienteResumo(paciente: paciente, status: StatusRisco.estavel),
    ).status;

    final pressoes = clinicoRepo.obterPressoes(paciente.id);
    final glicemias = clinicoRepo.obterGlicemias(paciente.id);
    final pesos = clinicoRepo.obterPesos(paciente.id);
    final medicamentos = clinicoRepo.obterMedicamentos(paciente.id);
    final tomadas = clinicoRepo.obterTomadas(paciente.id);
    final documentos = clinicoRepo.obterDocumentos(paciente.id);
    final consultas = clinicoRepo.obterConsultas(paciente.id);
    final mensagens = clinicoRepo.obterMensagens(paciente.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(paciente.nome),
        actions: [
          IconButton(
            tooltip: 'Ações Clínicas',
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 26),
            onPressed: () => _mostrarMenuAcoesClinicas(context, paciente),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header do Paciente
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          RiskBadge(
                            level: statusRisco == StatusRisco.critico
                                ? RiskLevel.critico
                                : statusRisco == StatusRisco.atencao
                                    ? RiskLevel.atencao
                                    : RiskLevel.estavel,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${paciente.idade} anos • ${paciente.sexo == Sexo.f ? "Feminino" : "Masculino"}',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                      if (paciente.telefone != null)
                        Text(paciente.telefone!, style: AppTypography.bodySmall),
                    ],
                  ),
                  if (paciente.alergias.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.riskCritico),
                        const SizedBox(width: 4),
                        Text(
                          'Alergias: ${paciente.alergias.join(", ")}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.riskCriticoText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // TabBar fixa
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.slateTextMuted,
                indicatorColor: AppColors.primary,
                labelStyle: AppTypography.titleSmall.copyWith(fontSize: 12),
                unselectedLabelStyle: AppTypography.bodySmall.copyWith(fontSize: 12),
                tabs: const [
                  Tab(text: 'Vitals'),
                  Tab(text: 'Remédios'),
                  Tab(text: 'Documentos'),
                  Tab(text: 'SOAP'),
                  Tab(text: 'Avisos'),
                ],
              ),
            ),
            const Divider(height: 1),

            // Conteúdo das Abas
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  VitalsTab(
                    paciente: paciente,
                    pressoes: pressoes,
                    glicemias: glicemias,
                    pesos: pesos,
                  ),
                  MedicamentosTab(
                    medicamentos: medicamentos,
                    tomadas: tomadas,
                  ),
                  DocumentosTab(
                    documentos: documentos,
                  ),
                  SoapHistoryTab(
                    consultas: consultas,
                  ),
                  MensagensTab(
                    paciente: paciente,
                    mensagens: mensagens,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.bolt_rounded),
        label: const Text('Ação Clínica'),
        onPressed: () => _mostrarMenuAcoesClinicas(context, paciente),
      ),
    );
  }
}
