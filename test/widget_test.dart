import 'package:flutter_test/flutter_test.dart';

import 'package:catatan_harian/main.dart';

void main() {
  testWidgets('menampilkan splash screen aplikasi', (WidgetTester tester) async {
    await tester.pumpWidget(
      const CatatanHarianApp(initialDarkMode: false),
    );

    expect(find.text('Catatan Harian'), findsOneWidget);
    expect(
      find.text('Simpan ide dan kegiatanmu setiap hari'),
      findsOneWidget,
    );
  });
}
