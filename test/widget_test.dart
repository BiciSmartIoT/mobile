import 'package:flutter_test/flutter_test.dart';

import 'package:bikelabflutter/main.dart';

void main() {
  testWidgets('renders BiceSmartIoT login screen', (tester) async {
    await tester.pumpWidget(const BiceSmartIoTApp());
    await tester.pump();

    expect(find.text('BiceSmartIoT'), findsWidgets);
    expect(find.text('Iniciar sesion'), findsOneWidget);
  });
}
