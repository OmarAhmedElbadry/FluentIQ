import 'package:flutter_test/flutter_test.dart';
import 'package:fluentiq/app.dart';
import 'package:fluentiq/core/di/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('renders the LinguaIQ welcome experience', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await configureDependencies();
    await tester.pumpWidget(const LinguaIQApp(onboardingComplete: true));
    await tester.pumpAndSettle();

    expect(find.text('Hello,'), findsOneWidget);
  });
}
