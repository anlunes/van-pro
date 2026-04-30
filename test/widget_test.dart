import 'package:flutter_test/flutter_test.dart';
import 'package:van_pro/app.dart';

void main() {
  testWidgets('VanPro app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VanProApp());
    expect(find.text('VanPro'), findsAny);
  });
}
