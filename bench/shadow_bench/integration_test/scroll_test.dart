// Scrolls a long list of baked icons for each set and records frame timings.
// Run in profile mode on a device: see README.md.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shadow_bench/main.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> scroll(WidgetTester tester, int flings) async {
    final list = find.byKey(const ValueKey('list'));
    for (var i = 0; i < flings; i++) {
      await tester.fling(list, Offset(0, i.isEven ? -3000 : -2000), 5000);
      await tester.pumpAndSettle();
    }
  }

  // Two rounds, alternating the order, so warm-up and thermal drift don't favour one set.
  for (final round in [1, 2]) {
    for (final set in round == 1 ? sets : sets.reversed) {
      testWidgets('$set round $round', (tester) async {
        await tester.pumpWidget(BenchApp(set: set));
        await tester.pumpAndSettle();
        await scroll(tester, 2); // warm up: parse every icon once
        await binding.watchPerformance(() => scroll(tester, 12), reportKey: '${set}_round$round');
      });
    }
  }
}
