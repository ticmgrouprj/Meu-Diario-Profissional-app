import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/auth/login_screen.dart';
import '../../presentation/auth/cadastro_screen.dart';
import '../../presentation/home/home_nav_screen.dart';
import '../../presentation/paciente/paciente_detalhes_screen.dart';
import '../../presentation/clinical_actions/nova_consulta_soap_screen.dart';
import '../../presentation/clinical_actions/nova_prescricao_screen.dart';
import '../../presentation/clinical_actions/novo_atestado_screen.dart';
import '../../presentation/clinical_actions/novo_pedido_exame_screen.dart';
import '../../presentation/clinical_actions/relatorio_pdf_screen.dart';
import '../../presentation/tools/vincular_paciente_screen.dart';
import '../../presentation/tools/teleconsulta_screen.dart';
import '../../presentation/tools/calculadoras_screen.dart';
import '../../presentation/clinical_actions/enviar_mensagem_paciente_screen.dart';



final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',

    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/cadastro',
        builder: (context, state) => const CadastroScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeNavScreen(),
      ),
      GoRoute(
        path: '/vincular-paciente',
        builder: (context, state) => const VincularPacienteScreen(),
      ),
      GoRoute(
        path: '/paciente/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PacienteDetalhesScreen(pacienteId: id);
        },
        routes: [
          GoRoute(
            path: 'nova-consulta',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return NovaConsultaSoapScreen(pacienteId: id);
            },
          ),
          GoRoute(
            path: 'nova-prescricao',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return NovaPrescricaoScreen(pacienteId: id);
            },
          ),
          GoRoute(
            path: 'novo-atestado',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return NovoAtestadoScreen(pacienteId: id);
            },
          ),
          GoRoute(
            path: 'novo-pedido-exame',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return NovoPedidoExameScreen(pacienteId: id);
            },
          ),
          GoRoute(
            path: 'relatorio-pdf',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return RelatorioPdfScreen(pacienteId: id);
            },
          ),
          GoRoute(
            path: 'teleconsulta',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return TeleconsultaScreen(pacienteId: id);
            },
          ),
          GoRoute(
            path: 'enviar-mensagem',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return EnviarMensagemPacienteScreen(pacienteId: id);
            },
          ),
          GoRoute(
            path: 'calculadoras',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return CalculadorasScreen(pacienteId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/calculadoras',
        builder: (context, state) => const CalculadorasScreen(),
      ),
    ],
  );
});

