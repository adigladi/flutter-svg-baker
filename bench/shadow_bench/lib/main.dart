import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// before: shadows as baked today (each layer is a group with opacity, so Flutter uses a saveLayer per layer).
/// after: the same shadows with the opacity on each shape (no saveLayer).
/// plain: the source files with no shadow, as a baseline.
const sets = ['before', 'after', 'plain'];
const icons = ['figma_group', 'figma_single', 'icon_multi', 'logo'];

void main() => runApp(const BenchApp());

class BenchApp extends StatelessWidget {
  const BenchApp({super.key, this.set = 'before'});

  final String set;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: IconList(key: ValueKey(set), set: set),
    );
  }
}

class IconList extends StatelessWidget {
  const IconList({super.key, required this.set});

  final String set;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Shadow bench: $set')),
      body: ListView.builder(
        key: const ValueKey('list'),
        itemCount: 1000,
        itemExtent: 64,
        itemBuilder: (context, row) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (var column = 0; column < 6; column++)
              SvgPicture.asset(
                'assets/$set/${icons[(row + column) % icons.length]}.svg',
                width: 48,
                height: 48,
              ),
          ],
        ),
      ),
    );
  }
}
