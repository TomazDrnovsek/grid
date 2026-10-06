// Smoke test: the app's first screen builds without throwing.
//
// It pumps GridApp inside a ProviderScope, as main() does. It skips main()'s
// service-locator setup, which nothing on the splash screen uses, and it
// stops before the splash hands over to GridHomePage (about 2.3 s), whose
// database and plugins are not available in a widget test.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:grid/main.dart';
import 'package:grid/ui/splash_screen.dart';

void main() {
  testWidgets('first screen builds without throwing', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: GridApp()));
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.takeException(), isNull);
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);
  });
}
