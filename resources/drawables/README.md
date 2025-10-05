# Launcher Icon

A launcher icon PNG file is required for the app to build successfully.

## Required File
- `launcher_icon.png`

## Specifications
- Size: 80x80 pixels (recommended)
- Format: PNG
- Background: Should work on both light and dark themes

## Quick Solution
To create a simple placeholder icon, you can:

1. Use ImageMagick:
```bash
convert -size 80x80 xc:blue -fill white -pointsize 40 -gravity center -annotate +0+0 'HW' launcher_icon.png
```

2. Or download a simple icon and rename it to `launcher_icon.png`

3. Or use any image editor to create an 80x80 PNG file

Place the file in this directory: `resources/drawables/launcher_icon.png`
