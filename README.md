# Portbrowser

A native macOS app for previewing websites at true iPhone dimensions.

**v0.1.0** · [portbrowser.com](https://www.portbrowser.com)

Open a localhost, LAN, or HTTPS URL and see it in an accurate iPhone frame: the right logical viewport, the Dynamic Island, a live status bar, and Safari's floating toolbar. Portbrowser is built with SwiftUI and the system `WKWebView`. It is 1.8 MB and does not bundle Chromium.

## What's in v0.1.0

- **11 iPhone presets** across the 16, 17, and 18 series (plus Air and the "e" models), switchable from the toolbar's device menu
- Opens at **iPhone 18 Pro** (`402 × 874`) with its measured Dynamic Island
- **Live status bar**: the real clock in place of a baked-in 9:41
- **Safari-style Liquid Glass toolbar** floating over the page: back, address, reload, device menu, new window
- Windows open at **100% device size** and scale down only when the display is too small
- **Per-window sessions**, recent URLs, and a remembered window position
- Standard macOS menus and shortcuts
- Localhost, LAN, and HTTPS URLs

| Shortcut | Action |
|---|---|
| ⌘N | New window |
| ⌘K | Open location (focus the address field) |
| ⌘R | Reload |
| ⌘W | Close window |

## Numbers

Measured on 2026-09-23 from a release build on an Apple-silicon Mac. See [`docs/performance.md`](docs/performance.md) for the methods and caveats.

| | |
|---|---|
| App size | 1.8 MB |
| Warm launch | ~340 ms |
| Memory at idle | ~61 MB (including WebKit's helper processes) |
| Chromium | 0 MB |
| Runs on | macOS 14+, Apple silicon (arm64) |

## Install

There is no signed download yet. Builds are ad-hoc signed, and Developer ID signing and notarization are on the [backlog](BACKLOG.md). For now, build from source.

**Requirements:** macOS 14 or newer, and the Xcode Command Line Tools with Swift 6.

```bash
git clone https://github.com/w-ade/Portbrowser.git
cd Portbrowser/app
./script/build_and_run.sh
```

The app bundle is written to `app/dist/Portbrowser.app`. To launch straight into a URL:

```bash
PORTBROWSER_URL=http://localhost:3000 ./script/build_and_run.sh
```

## Repository

| Path | What it is |
|---|---|
| `app/` | The macOS app (SwiftPM, SwiftUI + WebKit) |
| `site/` | [portbrowser.com](https://www.portbrowser.com): Next.js 16 + Tailwind 4 |
| `docs/` | Measured performance numbers |
| `BACKLOG.md` | Roadmap from v0.1.0 to a signed, notarized download |

### Website

```bash
cd site
npm install
npx next dev -p 3000
```

The version shown on the landing page is hard-coded in `site/app/page.tsx`. Its stats come from `docs/performance.md`, so update both when either changes.

### App icon

`app/Icon/AppIcon.icns` is rendered from the "Soft depth" design by `app/script/render_icon.swift`. To change it, edit that script and run this from `app/`:

```bash
swift script/render_icon.swift . && iconutil -c icns Icon/AppIcon.iconset -o Icon/AppIcon.icns
```

## Known limitations

- Portrait only
- Apple silicon only; there is no Intel build
- Ad-hoc signed, so Gatekeeper will warn about a build copied to another Mac
- No loading or error states yet: a stopped dev server shows a blank page
