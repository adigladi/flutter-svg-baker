// Compiles each SVG the way flutter_svg does and counts the draw commands it produces.
import 'dart:io';

import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

// Runtime mode matches SvgPicture.string/asset (optimizers off); compiled mode matches the vector_graphics asset transformer.
void main(List<String> args) {
  final engine = Platform.environment['FLUTTER_ENGINE_ARTIFACTS'];
  if (engine != null) initializeLibPathOps('$engine/libpath_ops.so');
  for (final arg in args) {
    final files = FileSystemEntity.isDirectorySync(arg)
        ? (Directory(arg)
              .listSync()
              .whereType<File>()
              .where((f) => f.path.endsWith('.svg'))
              .toList()
            ..sort((a, b) => a.path.compareTo(b.path)))
        : [File(arg)];
    for (final file in files) {
      for (final compiled in [false, true]) {
        final instructions = parse(
          file.readAsStringSync(),
          key: file.path,
          warningsAsErrors: true,
          enableClippingOptimizer: compiled,
          enableMaskingOptimizer: compiled,
          enableOverdrawOptimizer: compiled,
        );
        final counts = <DrawCommandType, int>{};
        for (final command in instructions.commands) {
          counts[command.type] = (counts[command.type] ?? 0) + 1;
        }
        String n(DrawCommandType t) => '${counts[t] ?? 0}';
        print(
          '${file.path.split('/').last} ${compiled ? 'compiled' : 'runtime '}: saveLayer=${n(DrawCommandType.saveLayer)} '
          'clip=${n(DrawCommandType.clip)} path=${n(DrawCommandType.path)} total=${instructions.commands.length}',
        );
      }
    }
  }
}
