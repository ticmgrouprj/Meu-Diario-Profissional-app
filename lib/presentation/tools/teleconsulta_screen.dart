import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/repositories/pacientes_repository.dart';

class TeleconsultaScreen extends ConsumerStatefulWidget {
  final String pacienteId;

  const TeleconsultaScreen({super.key, required this.pacienteId});

  @override
  ConsumerState<TeleconsultaScreen> createState() => _TeleconsultaScreenState();
}

class _TeleconsultaScreenState extends ConsumerState<TeleconsultaScreen> {
  int _segundos = 0;
  Timer? _timer;
  bool _audioMuted = false;
  bool _videoMuted = false;
  final _notasController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _segundos++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _notasController.dispose();
    super.dispose();
  }

  String _formatarTempo(int segs) {
    final m = (segs ~/ 60).toString().padLeft(2, '0');
    final s = (segs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final paciente = ref.watch(pacientesRepositoryProvider).obterPacientePorId(widget.pacienteId);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Feed de Vídeo do Paciente (Simulado em alta definição)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xFF1E293B),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 54,
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        paciente?.nome.split(' ').map((n) => n[0]).take(2).join() ?? 'P',
                        style: AppTypography.displayLarge.copyWith(color: AppColors.primaryDark),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      paciente?.nome ?? 'Paciente Conectado',
                      style: AppTypography.titleMedium.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Conexão Criptografada P2P • Áudio & Vídeo HD',
                      style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),

            // Feed Miniatura do Médico (PIP no canto superior direito)
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                width: 100,
                height: 140,
                decoration: BoxDecoration(
                  color: _videoMuted ? Colors.black : const Color(0xFF334155),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white30, width: 2),
                ),
                child: Center(
                  child: _videoMuted
                      ? const Icon(Icons.videocam_off, color: Colors.white54)
                      : const Icon(Icons.person, color: Colors.white70, size: 36),
                ),
              ),
            ),

            // Cronômetro de Atendimento no Topo
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatarTempo(_segundos),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            // Barra de Controles Inferior
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Mute Microfone
                    IconButton(
                      icon: Icon(_audioMuted ? Icons.mic_off : Icons.mic),
                      color: _audioMuted ? Colors.redAccent : Colors.white,
                      onPressed: () => setState(() => _audioMuted = !_audioMuted),
                    ),
                    // Mute Câmera
                    IconButton(
                      icon: Icon(_videoMuted ? Icons.videocam_off : Icons.videocam),
                      color: _videoMuted ? Colors.redAccent : Colors.white,
                      onPressed: () => setState(() => _videoMuted = !_videoMuted),
                    ),
                    // Anotações SOAP
                    IconButton(
                      icon: const Icon(Icons.edit_note, color: Colors.white),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                                left: 20,
                                right: 20,
                                top: 20,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text('Notas Clínicas da Teleconsulta', style: AppTypography.titleMedium),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _notasController,
                                    maxLines: 4,
                                    decoration: const InputDecoration(
                                      hintText: 'Anotações rápidas durante a chamada com o paciente...',
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Salvar nas Notas'),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    // Desconectar / Encerrar
                    IconButton.filled(
                      style: IconButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                      icon: const Icon(Icons.call_end),
                      onPressed: () {

                        context.pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Teleconsulta encerrada. Duração: ${_formatarTempo(_segundos)}')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
