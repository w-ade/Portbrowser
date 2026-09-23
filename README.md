# Portbrowser

A focused macOS window for previewing local websites at iPhone viewport sizes.

The current build opens the preview as a flush, full-size iPhone canvas without extra app chrome. The toolbar is being redesigned separately. The app uses SwiftUI and the system `WKWebView`; it does not bundle Chromium.

## Features

- Localhost, LAN, and HTTPS URL support
- Portrait iPhone 16, 17, and 18 series viewport presets
- Opens at iPhone 18 Pro (`402 x 874`) with its measured Dynamic Island and a live clock
- Safari-style Liquid Glass toolbar floating over the page: back, address, reload, device menu, new window
- Window sizes to the device at 100% and scales down only when the display is too small
- Blank canvas on launch

## Requirements

- macOS 14 or newer
- Xcode Command Line Tools with Swift 6

## Run

```bash
cd app
./script/build_and_run.sh
```

To launch with a specific URL:

```bash
PORTBROWSER_URL=http://localhost:3000 ./script/build_and_run.sh
```
(run from `app/`)

The app bundle is generated at `dist/Portbrowser.app`.

## App icon

`app/Icon/AppIcon.icns` is rendered from the "Soft depth" design by `app/script/render_icon.swift`. To change it, edit that script and run (from `app/`):

```bash
swift script/render_icon.swift . && iconutil -c icns Icon/AppIcon.iconset -o Icon/AppIcon.icns
```
