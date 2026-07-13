# mobilepreview

A focused macOS window for previewing local websites at mobile viewport sizes.

Paste a localhost or LAN URL, choose an iPhone preset, and keep the preview visible without opening Chrome DevTools. The app uses SwiftUI and the system `WKWebView`; it does not bundle Chromium.

## Features

- Localhost, LAN, and HTTPS URL support
- iPhone and Pixel viewport presets
- Portrait and landscape rotation
- Reload and hard reload
- Fit-to-window scaling
- Recent URL history
- Always-on-top mode
- Default preview: `192.168.1.100:3000/rework`

## Requirements

- macOS 14 or newer
- Xcode Command Line Tools with Swift 6

## Run

```bash
./script/build_and_run.sh
```

To launch with a specific URL:

```bash
MOBILE_PREVIEW_URL=http://localhost:3000 ./script/build_and_run.sh
```

The app bundle is generated at `dist/MobilePreviewer.app`.
