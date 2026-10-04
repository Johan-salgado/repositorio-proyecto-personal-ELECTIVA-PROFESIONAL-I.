import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('El menú principal muestra las pantallas del Taller 3',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Menú principal'), findsOneWidget);
    expect(find.text('1. Future / async / await'), findsOneWidget);
    expect(find.text('2. Cronómetro (Timer)'), findsOneWidget);
    expect(find.text('3. Tarea pesada (Isolate)'), findsOneWidget);
  });
}
