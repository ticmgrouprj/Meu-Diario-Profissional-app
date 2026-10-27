import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meu_diario_profissional_mobile/main.dart';

void main() {
  testWidgets('Smoke test de inicialização do Meu Diário Profissional', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MeuDiarioProfissionalApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pacientes'), findsOneWidget);
  });
}
