# Fonts Directory

## Current Status

The app is currently using the default Material Design font (Roboto).

## Future Enhancement: Glacial Indifference Font

If you want to add the Glacial Indifference font in the future:

### Required Files

1. **GlacialIndifference-Regular.otf**
2. **GlacialIndifference-Bold.otf**

### Where to Download

- [Google Fonts](https://fonts.google.com/)
- [DaFont](https://www.dafont.com/)
- [Font Squirrel](https://www.fontsquirrel.com/)

### Installation Steps

1. Download the font files
2. Place them in this directory (`assets/fonts/`)
3. Update `pubspec.yaml` to include:
```yaml
fonts:
  - family: GlacialIndifference
    fonts:
      - asset: assets/fonts/GlacialIndifference-Regular.otf
      - asset: assets/fonts/GlacialIndifference-Bold.otf
        weight: 700
```
4. Add `fontFamily: 'GlacialIndifference'` to TextStyle widgets
5. Run `flutter pub get`
6. Restart the app

## Note

Font files are not included in the repository. The app works perfectly with the default font.
