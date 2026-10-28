import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

void main() {
  const cases = {
    'fill on leaf': '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 10"><rect width="5" height="5" fill="#000" opacity=".2"/></svg>',
    'fill on group': '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 10"><g fill="#000"><rect width="5" height="5" opacity=".2"/></g></svg>',
    'fill+stroke on group': '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 10"><g fill="#000" stroke="#000"><rect width="5" height="5" opacity=".2"/></g></svg>',
    'stroke-width on mid group': '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 10"><g fill="#000" stroke="#000"><g stroke-width="2"><rect width="5" height="5" opacity=".2"/></g></g></svg>',
    'stroke-opacity on leaf': '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 10"><g fill="#000" stroke="#000"><rect width="5" height="5" opacity=".2" stroke-opacity="1"/></g></svg>',
    'stroke on leaf': '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 10"><g fill="#000"><rect width="5" height="5" opacity=".2" stroke="#000"/></g></svg>',
  };
  cases.forEach((name, svg) {
    final i = parse(svg, enableClippingOptimizer: false, enableMaskingOptimizer: false, enableOverdrawOptimizer: false);
    print('$name: ${i.paints.map((p) => '${p.fill?.color}/${p.stroke?.color}').join(', ')}');
  });
}
