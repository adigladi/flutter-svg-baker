// Renders every SVG in RENDER_IN to a PNG in RENDER_OUT, the way flutter_svg draws it on a white background.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

const size = 384.0;

void main() {
  final inDir = Platform.environment['RENDER_IN']!;
  final outDir = Platform.environment['RENDER_OUT']!;
  Directory(outDir).createSync(recursive: true);
  final files = Directory(inDir).listSync().whereType<File>().where((f) => f.path.endsWith('.svg'));
  for (final file in files) {
    final name = file.uri.pathSegments.last.replaceAll('.svg', '');
    testWidgets(name, (tester) async {
      final key = GlobalKey();
      await tester.pumpWidget(Center(
        child: RepaintBoundary(
          key: key,
          child: Container(
            color: Colors.white,
            width: size,
            height: size,
            child: SvgPicture.string(file.readAsStringSync(), width: size, height: size),
          ),
        ),
      ));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        File('$outDir/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
      });
    });
  }
}
