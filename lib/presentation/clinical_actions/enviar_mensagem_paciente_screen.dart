import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/clinical_card.dart';
import '../../core/services/share_service.dart';
import '../../core/services/notification_service.dart';
import '../../data/models/mensagem_model.dart';
import '../../data/repositories/pacientes_repository.dart';
import '../../data/repositories/clinico_repository.dart';
import '../../data/repositories/auth_repository.dart';

class EnviarMensagemPacienteScreen extends ConsumerStatefulWidget {
  final String pacienteId;

  const EnviarMensagemPacienteScreen({super.key, required this.pacienteId});

  @override
  ConsumerState<EnviarMensagemPacienteScreen> createState() => _EnviarMensagemPacienteScreenState();
}

class _EnviarMensagemPacienteScreenState extends ConsumerState<EnviarMensagemPacienteScreen> {
  TipoAvisoPaciente _tipoSelecionado = TipoAvisoPaciente.alertaTelemetria;
  CanalEnvio _canalSelecionado = CanalEnvio.ambos;

  final _tituloController = TextEditingController(text: 'Alerta Clínico: Atenção à Pressão Arterial');
  final _conteudoController = TextEditingController(
    text: 'Olá! Identifiquei uma aferição de pressão alterada no seu histórico. Por favor, permaneça em repouso por 15 minutos, confirme se tomou suas medicações e realize uma nova aferição.',
  );
  bool _enviando = false;

  final Map<TipoAvisoPaciente, Map<String, String>> _templates = {
    TipoAvisoPaciente.alertaTelemetria: {
      'titulo': 'Alerta Clínico: Atenção aos Sinais Vitais',
      'conteudo': 'Olá! Identifiquei uma alteração nos seus sinais vitais no aplicativo. Por favor, repouse por 15 minutos, confirme suas medicações do dia e realize uma nova aferição.',
    },
    TipoAvisoPaciente.medicacao: {
      'titulo': 'Lembrete Médico: Ajuste de Medicação',
      'conteudo': 'Olá! Conforme alinhado em consulta, lembre-se de seguir rigorosamente os horários e dosagens das suas medicações de uso contínuo prescritas.',
    },
    TipoAvisoPaciente.retorno: {
      'titulo': 'Lembrete de Retorno Clínico',
      'conteudo': 'Olá! Seu retorno médico de acompanhamento está previsto para os próximos dias. Lembre-se de trazer os resultados dos seus últimos exames.',
    },
    TipoAvisoPaciente.exames: {
      'titulo': 'Orientação para Exames Laboratoriais',
      'conteudo': 'Olá! Para a realização dos exames laboratoriais solicitados, lembre-se de manter o jejum necessário de 8 a 12 horas e hidrate-se com água.',
    },
    TipoAvisoPaciente.personalizada: {
      'titulo': 'Mensagem da Dra. Helena Moraes',
      'conteudo': '',
    },
  };

  @override
  void dispose() {
    _tituloController.dispose();
    _conteudoController.dispose();
    super.dispose();
  }

  void _selecionarTemplate(TipoAvisoPaciente tipo) {
    setState(() {
      _tipoSelecionado = tipo;
      final t = _templates[tipo];
      if (t != null) {
        _tituloController.text = t['titulo'] ?? '';
        _conteudoController.text = t['conteudo'] ?? '';
      }
    });
  }

  void _enviar() async {
    if (_tituloController.text.trim().isEmpty || _conteudoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha o título e o conteúdo do aviso')),
      );
      return;
    }

    setState(() => _enviando = true);

    final paciente = ref.read(pacientesRepositoryProvider).obterPacientePorId(widget.pacienteId);
    final prof = ref.read(currentProfissionalProvider);
    final clinicoRepo = ref.read(clinicoRepositoryProvider);

    final novaMensagem = MensagemPaciente(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      pacienteId: widget.pacienteId,
      profissionalId: prof?.id ?? 'prof_demo',
      tipo: _tipoSelecionado,
      titulo: _tituloController.text.trim(),
      conteudo: _conteudoController.text.trim(),
      enviadoEm: DateTime.now(),
      canal: _canalSelecionado,
      entregue: true,
    );

    clinicoRepo.enviarMensagem(novaMensagem);

    // Se selecionou Notificação no App / Ambos, aciona o serviço de notificação local para simular o alerta
    if (_canalSelecionado == CanalEnvio.notificacaoApp || _canalSelecionado == CanalEnvio.ambos) {
      await NotificationService.instance.dispararAlertaCritico(
        titulo: 'Aviso Enviado: ${_tituloController.text.trim()}',
        mensagem: 'Notificação entregue com sucesso para ${paciente?.nome ?? "o paciente"}.',
      );
    }

    // Se selecionou WhatsApp / Ambos, aciona o compartilhamento nativo para envio com 1 toque
    if (_canalSelecionado == CanalEnvio.whatsApp || _canalSelecionado == CanalEnvio.ambos) {
      final textoZap = '*[Meu Diário de Saúde - Dra. Helena Moraes]*\n\n'
          '*${_tituloController.text.trim()}*\n\n'
          '${_conteudoController.text.trim()}\n\n'
          'Atenciosamente,\n${prof?.nome ?? "Dra. Helena Moraes"} (${prof?.carimbo ?? "CRM-RJ 123456"})';

      await ShareService.instance.compartilharTexto(textoZap, assunto: _tituloController.text.trim());
    }

    setState(() => _enviando = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Aviso clínico enviado com sucesso para ${paciente?.nome ?? "o paciente"}!'),
          backgroundColor: AppColors.riskEstavelText,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final paciente = ref.watch(pacientesRepositoryProvider).obterPacientePorId(widget.pacienteId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Enviar Mensagem • ${paciente?.nome.split(" ").first ?? ""}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Destinatário
            ClinicalCard(
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: const Icon(Icons.person, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(paciente?.nome ?? 'Paciente', style: AppTypography.titleSmall),
                        Text(
                          'Telefone: ${paciente?.telefone ?? "Não informado"}',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.mark_chat_read_rounded, color: AppColors.primary, size: 22),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Modelos Rápidos de Avisos
            Text('Modelos Rápidos de Comunicação', style: AppTypography.titleSmall),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _ChipModelo(
                    label: '🚨 Alerta de Pressão/Glicemia',
                    isSelected: _tipoSelecionado == TipoAvisoPaciente.alertaTelemetria,
                    onTap: () => _selecionarTemplate(TipoAvisoPaciente.alertaTelemetria),
                  ),
                  const SizedBox(width: 8),
                  _ChipModelo(
                    label: '💊 Ajuste de Remédio',
                    isSelected: _tipoSelecionado == TipoAvisoPaciente.medicacao,
                    onTap: () => _selecionarTemplate(TipoAvisoPaciente.medicacao),
                  ),
                  const SizedBox(width: 8),
                  _ChipModelo(
                    label: '📅 Lembrete de Consulta',
                    isSelected: _tipoSelecionado == TipoAvisoPaciente.retorno,
                    onTap: () => _selecionarTemplate(TipoAvisoPaciente.retorno),
                  ),
                  const SizedBox(width: 8),
                  _ChipModelo(
                    label: '🧪 Preparo de Exames',
                    isSelected: _tipoSelecionado == TipoAvisoPaciente.exames,
                    onTap: () => _selecionarTemplate(TipoAvisoPaciente.exames),
                  ),
                  const SizedBox(width: 8),
                  _ChipModelo(
                    label: '✍️ Personalizada',
                    isSelected: _tipoSelecionado == TipoAvisoPaciente.personalizada,
                    onTap: () => _selecionarTemplate(TipoAvisoPaciente.personalizada),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Canal de Disparo
            Text('Canal de Envio do Aviso', style: AppTypography.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<CanalEnvio>(
              segments: const [
                ButtonSegment(
                  value: CanalEnvio.ambos,
                  label: Text('App + WhatsApp'),
                  icon: Icon(Icons.all_inclusive_rounded),
                ),
                ButtonSegment(
                  value: CanalEnvio.notificacaoApp,
                  label: Text('App Notif'),
                  icon: Icon(Icons.notifications_active_rounded),
                ),
                ButtonSegment(
                  value: CanalEnvio.whatsApp,
                  label: Text('WhatsApp'),
                  icon: Icon(Icons.chat_rounded),
                ),
              ],
              selected: {_canalSelecionado},
              onSelectionChanged: (val) => setState(() => _canalSelecionado = val.first),
            ),
            const SizedBox(height: 20),

            // Título do Aviso
            Text('Título do Aviso', style: AppTypography.titleSmall),
            const SizedBox(height: 6),
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(
                hintText: 'Ex: Alerta de Pressão Arterial',
                prefixIcon: Icon(Icons.title_rounded),
              ),
            ),
            const SizedBox(height: 16),

            // Conteúdo
            Text('Mensagem / Orientação Médica', style: AppTypography.titleSmall),
            const SizedBox(height: 6),
            TextField(
              controller: _conteudoController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Digite aqui a orientação para o paciente...',
              ),
            ),
            const SizedBox(height: 28),

            // Botão Enviar
            CustomButton(
              label: 'Enviar Aviso ao Paciente',
              icon: Icons.send_rounded,
              isLoading: _enviando,
              onPressed: _enviar,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipModelo extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChipModelo({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.slateBorder,
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
              color: isSelected ? AppColors.primaryDark : AppColors.navyDark,
            ),
          ),
        ),
      ),
    );
  }
}
