<img src="logo.svg" alt="" width="64" height="64">

# flutter-svg-baker

Flutter SVG Shadow Baker: a single web page that makes SVG exports render in Flutter the way they look in a browser or design tool.

[`flutter_svg`](https://pub.dev/packages/flutter_svg) skips `<filter>` elements without a warning, so drop shadows, inner shadows and glows from Figma, Illustrator or Inkscape exports silently disappear. This tool rebuilds those shadows from shapes `flutter_svg` can draw, and cleans up anything else it would ignore.

Everything runs in your browser. Files never leave your machine.

## Use it

Open `index.html` in a browser, or serve the folder (for example with GitHub Pages), then drop SVG files or whole folders onto the page.

The page opens with its own logo as an example. `logo.svg` uses a `<style>` block for its colours, two inner shadows on the tile and a drop shadow under the mark, so `flutter_svg` draws nothing at all from the original.

Each file shows three previews side by side:

- **Browser**: the original, as designed.
- **Flutter today**: the original with everything `flutter_svg` ignores removed, which is roughly what your app draws now.
- **Baked**: the converted file.

Click any preview to see all three full screen. Use the arrow keys or Previous/Next to step through files, and Esc to close.

Save files one at a time, or everything as a `.zip` that keeps the folder structure.

## What it changes

| In the SVG | What happens |
| --- | --- |
| Drop shadow filter | Rebuilt as stacked, offset copies of the artwork |
| Inner shadow filter | Rebuilt as a clipped, offset cut-out of each shape |
| Layer or background blur | Removed, with a warning |
| `<style>` rules | Inlined onto the elements they style |
| `<marker>`, `<foreignObject>`, SMIL animations | Removed, with a warning |

Then [SVGO](https://github.com/svg/svgo) minifies the result with its default preset, keeping `viewBox`. It also converts `style=""` declarations to plain attributes and removes embedded raster images (PNG, JPEG and GIF), with a warning for each file that had them.

### How a blur becomes shapes

A Gaussian blur fades out gradually from an edge. The tool approximates that with eight copies of the artwork drawn behind it in the shadow colour, each with a stroke that reaches a little further out, in even steps up to three blur radii. Where they overlap, the darkness adds up. Each copy's opacity is solved so the band it adds is exactly as dark as a real Gaussian blur at that distance: half the shadow's opacity at the edge, fading smoothly to nothing.

Inner shadows use the same layers, drawn as a large rectangle with the shape cut out of it, offset, and clipped to the shape. `flutter_svg` only accepts plain shapes inside a `<clipPath>`, so each shape gets its own clip.

Filters are parsed primitive by primitive. Figma's export pattern (`feOffset`, `feGaussianBlur`, `feComposite`, `feColorMatrix`) is supported, as are `feDropShadow`, `feFlood` colours, and `feMorphology` spread.

## Settings

- **Filter shadows**: strength, softness and extra downward lift for converted filter shadows.
- **Add a shadow**: give artwork that has no filter a soft dark edge, so light or metallic shapes stand out from their background. Set its colour, blur, opacity and lift.
- **Output**: turn SVGO minifying on or off. Raster images are only removed while minifying is on.

### Per-file settings

Every file keeps its own settings. With nothing selected, changes apply to all files. Tick files, or type a pattern such as `negative_*` or `icons/` and choose **Select matches**, to change only those files. Each control changes only its own setting, so raising Strength on a selection leaves those files' shadow colour alone. Files with their own settings show an **Own settings** chip, and controls show "mixed" when the files they affect disagree.

## Command line

`cli/bake_svg_shadow.dart` adds the same soft shadow from a script, for files without a filter:

```sh
dart cli/bake_svg_shadow.dart --color '#1f1a17' path/to/icons/*.svg
```

It edits the files in place and skips files it has already shadowed. Run it before any SVG optimizer, since optimizers remove the comment it uses to recognize those files.

## Limitations

- Layer blur and background blur can't be drawn with shapes, so they are removed.
- `<image>` and `<use>` elements are left out of baked shadows, because their colours can't be changed.
- Inner shadows are applied per shape, so overlapping shapes inside one filtered group each get their own inner edge.
- A filter shadow is cut out under its shape; a baked one sits behind it. Semi-transparent shapes therefore show their baked drop shadow through them. Use solid colours for shapes that cast a shadow.
- Baked shadows add path data, so files usually grow even after minifying.

## License

MIT, see [LICENSE](LICENSE).
