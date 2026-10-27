import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/custom_button.dart';
import '../../data/models/paciente_model.dart';
import '../../data/repositories/auth_repository.dart';

class CadastroScreen extends ConsumerStatefulWidget {
  const CadastroScreen({super.key});

  @override
  ConsumerState<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends ConsumerState<CadastroScreen> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _crmController = TextEditingController();
  final _especialidadeController = TextEditingController();
  String _ufSelecionada = 'RJ';
  String _conselhoSelecionado = 'CRM';
  bool _isLoading = false;

  final List<String> _ufs = [
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS', 'MG',
    'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'
  ];

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _crmController.dispose();
    _especialidadeController.dispose();
    super.dispose();
  }

  void _cadastrar() async {
    if (_nomeController.text.trim().isEmpty || _crmController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha nome e número de registro')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final novoProfissional = Profissional(
      id: 'prof_${DateTime.now().millisecondsSinceEpoch}',
      nome: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      conselho: _conselhoSelecionado,
      registro: _crmController.text.trim(),
      uf: _ufSelecionada,
      especialidade: _especialidadeController.text.trim().isEmpty
          ? 'Clínica Médica'
          : _especialidadeController.text.trim(),
      assinaturaTexto: '${_nomeController.text.trim()} — $_conselhoSelecionado-$_ufSelecionada ${_crmController.text.trim()}',
    );

    ref.read(authRepositoryProvider).atualizarPerfil(novoProfissional);
    ref.read(currentProfissionalProvider.notifier).state = novoProfissional;

    if (mounted) {
      setState(() => _isLoading = false);
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Cadastro de Profissional'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Credenciamento Clínico',
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  'Informe seus dados do conselho para emissão de receitas e laudos com validade jurídica.',
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 24),

                // Nome Completo
                Text('Nome com Titulação', style: AppTypography.titleSmall),
                const SizedBox(height: 6),
                TextField(
                  controller: _nomeController,
                  decoration: const InputDecoration(hintText: 'Ex: Dr. Roberto Alencar'),
                ),
                const SizedBox(height: 16),

                // E-mail
                Text('E-mail institucional', style: AppTypography.titleSmall),
                const SizedBox(height: 6),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(hintText: 'roberto@clinica.com.br'),
                ),
                const SizedBox(height: 16),

                // Conselho e UF
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Conselho', style: AppTypography.titleSmall),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _conselhoSelecionado,
                            items: const [
                              DropdownMenuItem(value: 'CRM', child: Text('CRM (Medicina)')),
                              DropdownMenuItem(value: 'COREN', child: Text('COREN (Enfermagem)')),
                              DropdownMenuItem(value: 'CRN', child: Text('CRN (Nutrição)')),
                              DropdownMenuItem(value: 'CREFITO', child: Text('CREFITO (Fisioterapia)')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _conselhoSelecionado = val);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('UF', style: AppTypography.titleSmall),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _ufSelecionada,
                            items: _ufs.map((uf) => DropdownMenuItem(value: uf, child: Text(uf))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _ufSelecionada = val);
                            },
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Registro
                Text('Número do Registro Profissional', style: AppTypography.titleSmall),
                const SizedBox(height: 6),
                TextField(
                  controller: _crmController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: '123456'),
                ),
                const SizedBox(height: 16),

                // Especialidade
                Text('Especialidade Médica', style: AppTypography.titleSmall),
                const SizedBox(height: 6),
                TextField(
                  controller: _especialidadeController,
                  decoration: const InputDecoration(hintText: 'Ex: Cardiologia, Endocrinologia'),
                ),
                const SizedBox(height: 32),

                CustomButton(
                  label: 'Concluir Credenciamento',
                  onPressed: _cadastrar,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
