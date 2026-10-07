import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:clinicaapp_mobile/main.dart';

void main() {
  testWidgets('ClinicaAppMobile loads successfully', (WidgetTester tester) async {
    // Set a realistic mobile device resolution
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    await tester.pumpWidget(const ClinicaAppMobile());
    await tester.pump();

    // Verify root widget exists
    expect(find.byType(ClinicaAppMobile), findsOneWidget);

    addTearDown(tester.view.resetPhysicalSize);
  });
}
