# shadow_bench

Scroll benchmark for baked SVG shadows. It compares three versions of the same 4 icons, 6 per row in a 1000-row list:

- `before`: baked by the page as it is today. Each shadow layer is a group with `opacity`, which Flutter draws with a saveLayer.
- `after`: the same shadows with the opacity moved onto each shape, so no saveLayer.
- `plain`: the source files, with no baked shadow, as a baseline.

## Run on a device

```bash
flutter pub get
flutter drive --profile --driver=test_driver/perf_driver.dart --target=integration_test/scroll_test.dart -d <device-id>
```

Results land in `build/<set>_round<n>.json` (average, 90th and 99th percentile build and raster times, and missed frames).

## Other tools

- `dart run tool/count_layers.dart assets/before` counts saveLayers, clips and paths the way flutter_svg compiles each file.
  Set `FLUTTER_ENGINE_ARTIFACTS` to the engine's `linux-x64` or `darwin-x64` artifacts folder for the compiled-mode counts.
- `RENDER_IN=assets/after RENDER_OUT=build/png flutter test test/render_test.dart` renders each SVG as flutter_svg draws it.
