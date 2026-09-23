# Portbrowser

A focused macOS window for previewing local websites at iPhone viewport sizes.

The current build opens the preview as a flush, full-size iPhone canvas without extra app chrome. The toolbar is being redesigned separately. The app uses SwiftUI and the system `WKWebView`; it does not bundle Chromium.

## Features

- Localhost, LAN, and HTTPS URL support
- Portrait iPhone 16, 17, and 18 series viewport presets
- Opens at iPhone 18 Pro (`402 x 874`) with its measured Dynamic Island and a live clock
- URL entry directly beneath the viewport
- Window sizes to the device at 100% and scales down only when the display is too small
- Blank canvas on launch

## Requirements

- macOS 14 or newer
- Xcode Command Line Tools with Swift 6

## Run

```bash
./script/build_and_run.sh
```

To launch with a specific URL:

```bash
PORTBROWSER_URL=http://localhost:3000 ./script/build_and_run.sh
```

The app bundle is generated at `dist/Portbrowser.app`.
