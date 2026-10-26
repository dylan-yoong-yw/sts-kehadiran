# Widget test font

`Roboto-Regular.ttf` is an unmodified Roboto font from Google Fonts, distributed
under the Apache License 2.0. The upstream license is included in `LICENSE.txt`.

- Source revision: `38062f4b4a0be4346d07a928408da21602545e9e`
- Font: https://github.com/googlefonts/roboto-2/blob/38062f4b4a0be4346d07a928408da21602545e9e/src/hinted/Roboto-Regular.ttf
- License: https://github.com/googlefonts/roboto-2/blob/38062f4b4a0be4346d07a928408da21602545e9e/LICENSE
- SHA-256: `56a45233d29f11b4dfb86d248e921939d115778f87325e7ae8cc108383d6664d`

The dashboard tests need realistic text metrics to check that normal-sized text
fits without scrolling on the supported screen sizes. Flutter's default Ahem
test font is much wider and changes line wrapping. The tests load this fixture
as `Roboto` using a path relative to the project root, so Windows and Linux use
the same bytes without inspecting the installed Flutter SDK.

This fixture is only used by tests; it is not registered as an app asset and
does not change the app's fonts or design. Run `flutter test` from the project
root. Keep this font and its license together when updating the fixture.
