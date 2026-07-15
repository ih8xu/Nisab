import 'package:flutter_test/flutter_test.dart';
import 'package:nisab/main.dart';

void main() {
  testWidgets('يعرض التطبيق شاشة المقدمة', (tester) async {
    await tester.pumpWidget(const Nisab());
    await tester.pump();

    expect(find.text('نِصاب'), findsOneWidget);
    expect(find.text('ابدأ احتساب الزكاة'), findsOneWidget);
  });
}
