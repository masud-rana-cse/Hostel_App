import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:hostel_app/main.dart';
import 'package:hostel_app/providers/app_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: const MyApp(),
      ),
    );
    expect(find.text('Hostel Management'), findsOneWidget);
  });
}
