import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/services/cid10_service.dart';
import 'core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fixar orientação preferencial para smartphones
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Inicializar dados de localização pt_BR
  await initializeDateFormatting('pt_BR', null);

  // Inicializar serviços de notificação e CID-10
  try {
    await NotificationService.instance.inicializar();
  } catch (_) {}

  try {
    CID10Service.instance.carregarCatalogo();
  } catch (_) {}

  runApp(
    const ProviderScope(
      child: MeuDiarioProfissionalApp(),
    ),
  );
}

class MeuDiarioProfissionalApp extends ConsumerWidget {
  const MeuDiarioProfissionalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Meu Diário Profissional',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
