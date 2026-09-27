import 'package:flutter_test/flutter_test.dart';
import 'package:appclickfarma/main.dart';

void main() {
  testWidgets('Testes de inicializacao do ClickFarmaApp', (WidgetTester tester) async {
    await tester.pumpWidget(const ClickFarmaApp());
    expect(find.byType(ClickFarmaApp), findsOneWidget);
  });
}
