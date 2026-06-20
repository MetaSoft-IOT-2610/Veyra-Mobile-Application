import 'package:flutter_test/flutter_test.dart';

import 'package:veyra_mobile_app/app/di/dependency_injection.dart';
import 'package:veyra_mobile_app/main.dart';

void main() {
  testWidgets('shows login screen', (WidgetTester tester) async {
    await initDependencies();

    await tester.pumpWidget(const VeyraEnterpriseApp());

    expect(find.text('Veyra Mobile App'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
