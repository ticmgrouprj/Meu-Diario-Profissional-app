import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_diario_profissional_mobile/main.dart';
import 'package:meu_diario_profissional_mobile/core/theme/theme_provider.dart';
import 'package:meu_diario_profissional_mobile/presentation/paciente/ajustar_metas_screen.dart';
import 'package:meu_diario_profissional_mobile/data/repositories/pacientes_repository.dart';

void main() {
  testWidgets('Smoke test de inicialização do Meu Diário Profissional', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MeuDiarioProfissionalApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pacientes'), findsOneWidget);
    expect(find.byIcon(Icons.swap_vert_rounded), findsOneWidget);
  });

  testWidgets('Validação do provider de Modo Noturno', (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.system);

    container.read(themeModeProvider.notifier).state = ThemeMode.dark;
    expect(container.read(themeModeProvider), ThemeMode.dark);

    container.read(themeModeProvider.notifier).state = ThemeMode.light;
    expect(container.read(themeModeProvider), ThemeMode.light);
  });

  testWidgets('Tela de Metas Clínicas carrega e exibe presets', (WidgetTester tester) async {
    final repo = PacientesRepository();
    final paciente = repo.obterResumos().first.paciente;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: AjustarMetasScreen(pacienteId: paciente.id),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Alvos Terapêuticos Individuais'), findsOneWidget);
    expect(find.text('Padrão SBC/ADA'), findsOneWidget);
    expect(find.text('Idoso Frágil / Quedas'), findsOneWidget);
    expect(find.text('Alto Risco / DRC'), findsOneWidget);
    expect(find.text('Salvar Metas Clínicas'), findsOneWidget);
  });
}
