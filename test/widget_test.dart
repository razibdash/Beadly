import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:beadly/app.dart';
import 'package:beadly/state/app_state.dart';

void main() {
  testWidgets('Onboarding screen shows tradition choices', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState()..load(),
        child: const BeadlyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Choose your tradition'), findsOneWidget);
    expect(find.text('Sanatan / Hindu'), findsOneWidget);
  });
}
