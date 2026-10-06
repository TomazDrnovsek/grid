// Carousels (G-016): the "Add as" dialog and the carousel preview, mounted at
// a phone's width. Photos are paths with no file, so images show their
// error state; layout and behaviour are what is checked.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grid/ui/grid_home.dart';

Future<void> _pumpAtPhoneSize(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(360, 740);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
  await tester.pump();
}

List<String> _paths(int count) => [for (var i = 0; i < count; i++) '/missing/pick_$i.jpg'];

void main() {
  testWidgets('Add as: two choices for 6 photos, each calls its callback', (tester) async {
    var separate = 0, carousel = 0, cancel = 0;
    await _pumpAtPhoneSize(
      tester,
      AddAsModal(
        pickedPaths: _paths(6),
        onCancel: () => cancel++,
        onSeparate: () => separate++,
        onCarousel: () => carousel++,
        isDark: false,
      ),
    );

    expect(find.text('Add 6 photos as'), findsOneWidget);
    expect(find.text('6 tiles'), findsOneWidget);
    expect(find.textContaining('holds up to'), findsNothing);

    await tester.tap(find.text('Separate'));
    await tester.tap(find.text('Carousel'));
    expect(separate, 1);
    expect(carousel, 1);
    expect(cancel, 0);
  });

  testWidgets('Add as: over 20 photos, Carousel is disabled and says why', (tester) async {
    var carousel = 0;
    await _pumpAtPhoneSize(
      tester,
      AddAsModal(
        pickedPaths: _paths(25),
        onCancel: () {},
        onSeparate: () {},
        onCarousel: () => carousel++,
        isDark: true,
      ),
    );

    expect(find.text('A carousel holds up to 20 photos. You picked 25.'), findsOneWidget);
    await tester.tap(find.text('Carousel'));
    expect(carousel, 0);
  });

  testWidgets('Add as: tapping outside the dialog cancels', (tester) async {
    var cancel = 0;
    await _pumpAtPhoneSize(
      tester,
      AddAsModal(
        pickedPaths: _paths(3),
        onCancel: () => cancel++,
        onSeparate: () {},
        onCarousel: () {},
        isDark: false,
      ),
    );

    await tester.tapAt(const Offset(10, 10));
    expect(cancel, 1);
  });

  testWidgets('Carousel preview: swipe moves to the next slide, tap closes', (tester) async {
    var closed = 0;
    await _pumpAtPhoneSize(
      tester,
      CarouselPreviewModal(
        slides: [for (final p in _paths(4)) File(p)],
        onClose: () => closed++,
      ),
    );

    expect(find.text('1/4'), findsOneWidget);
    await tester.drag(find.byType(PageView), const Offset(-300, 0));
    await tester.pumpAndSettle();
    expect(find.text('2/4'), findsOneWidget);
    expect(closed, 0);

    await tester.tapAt(const Offset(180, 370));
    expect(closed, 1);
  });
}
