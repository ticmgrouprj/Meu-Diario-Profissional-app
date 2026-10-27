import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/widgets/clinical_card.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/services/notification_service.dart';
import '../../data/repositories/auth_repository.dart';

class PerfilScreen extends ConsumerWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profissional = ref.watch(currentProfissionalProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Perfil Profissional'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Card Principal do Médico
            ClinicalCard(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primaryLight,
                    child: const Icon(Icons.person_rounded, size: 40, color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profissional?.nome ?? 'Dra. Helena Moraes',
                    style: AppTypography.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profissional?.especialidade ?? 'Cardiologia',
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.slateLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.slateBorder),
                    ),
                    child: Text(
                      profissional?.carimbo ?? 'CRM-RJ 123456',
                      style: AppTypography.titleSmall.copyWith(letterSpacing: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Aparência & Modo Noturno
            ClinicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.dark_mode_outlined, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text('Aparência e Modo Noturno', style: AppTypography.titleSmall),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'O tema escuro de alto contraste reduz a fadiga visual durante plantões e atendimentos noturnos.',
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.light,
                          label: Text('Claro'),
                          icon: Icon(Icons.light_mode_rounded, size: 16),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text('Noturno'),
                          icon: Icon(Icons.dark_mode_rounded, size: 16),
                        ),
                        ButtonSegment(
                          value: ThemeMode.system,
                          label: Text('Auto'),
                          icon: Icon(Icons.brightness_auto_rounded, size: 16),
                        ),
                      ],
                      selected: {themeMode},
                      onSelectionChanged: (newSelection) {
                        HapticFeedback.selectionClick();
                        ref.read(themeModeProvider.notifier).state = newSelection.first;
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Carimbo Oficial Atestado / Receituário
            ClinicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_outlined, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text('Carimbo e Assinatura Digital', style: AppTypography.titleSmall),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          profissional?.assinaturaTexto ?? 'Dra. Helena Moraes — Cardiologista CRM-RJ 123456',
                          style: AppTypography.titleSmall.copyWith(fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Emissão eletrônica com conformidade CFM / ICP-Brasil',
                          style: AppTypography.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Simulação de Alerta de Emergência
            ClinicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bolt_rounded, color: AppColors.riskCritico, size: 22),
                      const SizedBox(width: 8),
                      Text('Teste de Hardware & Alertas', style: AppTypography.titleSmall),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dispare uma simulação de crise hipertensiva com vibração háptica tátil no seu aparelho celular.',
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  CustomButton(
                    label: 'Simular Alerta de Crise (PA 186/114)',
                    variant: ButtonVariant.danger,
                    icon: Icons.notifications_active_rounded,
                    onPressed: () async {
                      await NotificationService.instance.dispararAlertaCritico(
                        titulo: 'ALERTA CRÍTICO: Maria Silva',
                        mensagem: 'Pico hipertensivo detectado: 186/114 mmHg. Requer intervenção.',
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Alerta de crise emitido com vibração háptica!')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout
            CustomButton(
              label: 'Encerrar Sessão',
              variant: ButtonVariant.secondary,
              icon: Icons.logout_rounded,
              onPressed: () async {
                await ref.read(authRepositoryProvider).logout();
                ref.read(currentProfissionalProvider.notifier).state = null;
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
