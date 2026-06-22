import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:veyra_mobile_app/app/di/dependency_injection.dart';
import 'package:veyra_mobile_app/main.dart';
import 'package:veyra_mobile_app/shared/infrastructure/local/token_manager.dart';

void main() {
  testWidgets('shows login screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await TokenManager.initialize();
    await initDependencies();

    await tester.pumpWidget(const VeyraEnterpriseApp());
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(find.text('Veyra Mobile App'), findsOneWidget);
    expect(find.text('Ingresar'), findsOneWidget);
  });
}
