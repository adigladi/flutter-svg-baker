import 'dart:io';

/// Bakes a soft drop shadow into SVG files, in place.
///
/// flutter_svg skips `<filter>` elements, so a design tool's drop shadow never
/// renders. This approximates one with copies of the artwork drawn behind it,
/// filled with `--color` and widened by increasingly thick, faint strokes
/// that stack into a falloff that reads like a blur.
///
/// Run it on exports without a shadow filter, before any SVG optimizer:
///
/// ```sh
/// dart cli/bake_svg_shadow.dart --color '#1f1a17' path/to/icons/*.svg
/// ```
///
/// Files that already have a baked shadow are skipped. The web page in
/// `index.html` does the same with more options, and also converts filters.
void main(List<String> arguments) {
  final colorIndex = arguments.indexOf('--color');
  if (colorIndex == -1 || colorIndex + 1 >= arguments.length) {
    stderr.writeln(
      'Usage: dart cli/bake_svg_shadow.dart --color <#hex> <file.svg>...',
    );
    exit(64);
  }

  final color = arguments[colorIndex + 1];
  final paths = [...arguments]..removeRange(colorIndex, colorIndex + 2);

  for (final path in paths) {
    final file = File(path);
    final svg = file.readAsStringSync();
    if (svg.contains(_marker)) {
      stderr.writeln('Skipped $path: it already has a baked shadow.');
      continue;
    }
    file.writeAsStringSync(_withShadow(svg, color));
    stdout.writeln('Shadowed $path');
  }
}

const _marker = '<!-- baked-shadow -->';

// Outermost first; offset and stroke width are in SVG units.
const _layers = [
  (offset: 1.6, strokeWidth: 6.0, opacity: 0.10),
  (offset: 1.3, strokeWidth: 3.6, opacity: 0.16),
  (offset: 1.0, strokeWidth: 1.8, opacity: 0.28),
  (offset: 0.4, strokeWidth: 0.9, opacity: 0.55),
];

final _shapeTag = RegExp(r'<(path|circle|rect|ellipse|polygon|polyline)\b');
final _paintAttribute = RegExp(
  r'\s(stroke|stroke-width|stroke-linejoin|opacity|fill-opacity|stroke-opacity)="[^"]*"',
);
final _fillAttribute = RegExp(r'\sfill="(?!none")[^"]*"');
final _defs = RegExp(r'<defs\b[\s\S]*?</defs>');

String _withShadow(String svg, String color) {
  final artworkStart = svg.indexOf('>', svg.indexOf('<svg')) + 1;
  final artworkEnd = svg.lastIndexOf('</svg>');
  final artwork = svg.substring(artworkStart, artworkEnd).replaceAll(_defs, '');

  final silhouette = artwork
      .replaceAll(_paintAttribute, '')
      .replaceAll(_fillAttribute, ' fill="$color"')
      .replaceAllMapped(
        _shapeTag,
        (match) =>
            '${match[0]} stroke="$color" stroke-linejoin="round" '
            'stroke-width="{width}"',
      );

  final layers = _layers.map(
    (layer) =>
        '<g opacity="${layer.opacity}" '
        'transform="translate(0 ${layer.offset})">'
        '${silhouette.replaceAll('{width}', '${layer.strokeWidth}')}</g>',
  );

  return '${svg.substring(0, artworkStart)}$_marker<g fill="$color">'
      '${layers.join()}</g>'
      '${svg.substring(artworkStart)}';
}
