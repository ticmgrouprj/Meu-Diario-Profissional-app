import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/services/biometric_service.dart';
import '../../data/repositories/auth_repository.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController(text: 'demo@meudiario.pro');
  final _senhaController = TextEditingController(text: 'demo123');
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.disposeNavigator();
    super.dispose();
  }

  void _autenticarComBiometria() async {
    final auth = BiometricService.instance;
    final autenticado = await auth.authenticate(
      reason: 'Acesse o prontuário com sua biometria',
    );

    if (autenticado && mounted) {
      ref.read(currentProfissionalProvider.notifier).state =
          ref.read(authRepositoryProvider).currentProfissional;
      context.go('/home');
    }
  }

  void _fazerLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final repo = ref.read(authRepositoryProvider);
    final sucesso = await repo.login(_emailController.text, _senhaController.text);

    if (mounted) {
      setState(() => _isLoading = false);
      if (sucesso) {
        ref.read(currentProfissionalProvider.notifier).state = repo.currentProfissional;
        context.go('/home');
      } else {
        setState(() => _errorMessage = 'E-mail ou senha inválidos');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Ícone da Aplicação
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.navyDark, AppColors.primary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x200284C7),
                            blurRadius: 16,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_hospital_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Título e Subtítulo
                  Text(
                    'Meu Diário Profissional',
                    style: AppTypography.displayLarge.copyWith(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Prontuário 360° e Telemetria Clínica Móvel',
                    style: AppTypography.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.riskCriticoBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.riskCritico.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: AppTypography.bodySmall.copyWith(color: AppColors.riskCriticoText),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Campo E-mail
                  Text('E-mail institucional', style: AppTypography.titleSmall),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'medico@consultorio.com.br',
                      prefixIcon: Icon(Icons.email_outlined, color: AppColors.slateTextMuted),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Campo Senha
                  Text('Senha de acesso', style: AppTypography.titleSmall),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _senhaController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.slateTextMuted),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.slateTextMuted,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botão Entrar
                  CustomButton(
                    label: 'Acessar Prontuário',
                    onPressed: _fazerLogin,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 14),

                  // Botão Biometria
                  CustomButton(
                    label: 'Desbloquear com Biometria',
                    variant: ButtonVariant.secondary,
                    icon: Icons.fingerprint_rounded,
                    onPressed: _autenticarComBiometria,
                  ),
                  const SizedBox(height: 24),

                  // Cadastro
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Novo médico na clínica? ', style: AppTypography.bodyMedium),
                      GestureDetector(
                        onTap: () => context.push('/cadastro'),
                        child: Text(
                          'Cadastre-se',
                          style: AppTypography.titleSmall.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension on TextEditingController {
  void disposeNavigator() {
    dispose();
  }
}
