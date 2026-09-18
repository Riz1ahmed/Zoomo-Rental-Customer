import 'package:flutter_test/flutter_test.dart';

import 'package:ebike_customer/main.dart';

void main() {
  testWidgets('shows login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CustomerApp());

    expect(find.text('Login'), findsOneWidget);
  });
}
