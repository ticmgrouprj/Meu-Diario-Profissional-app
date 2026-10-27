import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/paciente_model.dart';

import '../../data/repositories/pacientes_repository.dart';
import '../../data/repositories/auth_repository.dart';

class VincularPacienteScreen extends ConsumerStatefulWidget {
  const VincularPacienteScreen({super.key});

  @override
  ConsumerState<VincularPacienteScreen> createState() => _VincularPacienteScreenState();
}

class _VincularPacienteScreenState extends ConsumerState<VincularPacienteScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MobileScannerController _scannerController = MobileScannerController();
  bool _scanned = false;
  String? _codigoLido;

  // Código aleatório de 6 dígitos
  final String _codigoVinculo = '742918';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          _scanned = true;
          _codigoLido = barcode.rawValue;
        });

        // Simula vínculo do paciente com base no QR lido
        _confirmarVinculoPaciente(_codigoLido!);
        break;
      }
    }
  }

  void _confirmarVinculoPaciente(String codigo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Paciente Identificado'),
          content: Text('Vínculo com código "$codigo" validado com sucesso. Deseja adicionar o paciente ao seu prontuário?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _scanned = false);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final novo = Paciente(
                  id: 'pac_novo_${DateTime.now().millisecondsSinceEpoch}',
                  nome: 'Juliana Paes Correia',
                  sexo: Sexo.f,
                  dataNascimento: '1995-07-12',
                  telefone: '(21) 98111-9999',
                  alergias: const [],
                  diagnosticos: const [
                    Diagnostico(codigoCid: 'I10', descricao: 'Hipertensão Arterial Sistêmica'),
                  ],
                  vinculadoEm: DateTime.now(),
                );
                ref.read(pacientesRepositoryProvider).adicionarPaciente(novo);
                ref.read(pacientesResumoProvider.notifier).carregar();

                Navigator.pop(context);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Juliana Paes vinculada com sucesso!')),
                );
              },
              child: const Text('Confirmar Vínculo'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final prof = ref.watch(currentProfissionalProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Vincular Novo Paciente'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.slateTextMuted,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(icon: Icon(Icons.qr_code_2_rounded), text: 'Meu QR Code'),
            Tab(icon: Icon(Icons.camera_alt_rounded), text: 'Escanear Paciente'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ─── ABA 1: MOSTRAR QR CODE DO MÉDICO ───
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Apresente este código ao paciente',
                    style: AppTypography.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'O paciente deve abrir o "Meu Diário de Saúde" e ler este QR Code com a câmera do celular.',
                    style: AppTypography.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Container com QR Code Nativo
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.slateBorder),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x100F172A),
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: 'meudiariosaude://vincular?medico=${prof?.registro ?? "123456"}&uf=${prof?.uf ?? "RJ"}&codigo=$_codigoVinculo',
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text('Ou informe o código PIN numérico:', style: AppTypography.bodySmall),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _codigoVinculo,
                      style: AppTypography.displayLarge.copyWith(
                        fontSize: 28,
                        letterSpacing: 4,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── ABA 2: ESCANEAR COM A CÂMERA DO APARELHO ───
          Stack(
            children: [
              MobileScanner(
                controller: _scannerController,
                onDetect: _onDetect,
              ),

              // Mira de enquadramento
              Center(
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary, width: 3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              Positioned(
                top: 20,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Aponte a câmera para o QR Code exibido na tela do smartphone do paciente',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              Positioned(
                bottom: 30,
                left: 40,
                right: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton.filled(
                      icon: const Icon(Icons.flash_on_rounded),
                      onPressed: () => _scannerController.toggleTorch(),
                    ),
                    IconButton.filled(
                      icon: const Icon(Icons.cameraswitch_rounded),
                      onPressed: () => _scannerController.switchCamera(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
