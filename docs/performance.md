# Performance numbers

Measured 2026-09-23, release build (`swift build -c release`), on Wade's M-series
Mac. Single-machine sample — not a benchmark suite, no CI. Re-measure before
quoting on the site as a "vs." claim against another tool.

| Metric | Value | Method |
|---|---|---|
| App size | 1.8 MB packaged `.app` (682 KB executable) | `du -sh`, includes icon + resource bundle |
| Cold launch | ~470 ms | single sample, app quit → visible window (not a true post-reboot cold start) |
| Warm launch | ~335–345 ms | 4 consecutive runs, quit → visible window, stable |
| Idle memory (total) | ~61 MB | main process (36 MB) + its own WebKit GPU (17 MB) + Networking (8 MB) helpers — blank page, no site loaded |
| Loaded memory (total) | ~100 MB | same, with a real localhost Next.js site open — adds a WebContent helper (43 MB) |
| Rendering engine | WebKit / WKWebView | Apple's system framework, not bundled |
| Chromium footprint | 0 MB | confirmed via `otool -L` (no Chromium/CEF/Electron linked) and Package.swift (no such dependency) |
| Device presets | 11 | iPhone 16, 16 Plus, 16 Pro, 16 Pro Max, 16e, 17 & 17 Pro, 17 Pro Max, 17e, Air, 18 Pro, 18 Pro Max |
| macOS requirement | 14.0+ | `Package.swift` platforms, `Info.plist` `LSMinimumSystemVersion` |
| Architecture | arm64 (Apple Silicon native) | confirmed via `lipo -info`, no Intel slice |

## Caveats before publishing

- **Idle/loaded memory always includes WebKit's helper processes** (GPU,
  Networking, and WebContent once a page loads) — the main app process alone
  reads much lower (~35 MB) but that's not the real footprint; don't quote
  that number in isolation.
- **Cold launch** has one sample. Get 3–5 true cold-start samples (reboot or
  `purge` between runs) before treating it as solid.
- Numbers will shift once PB-013 (proper Release configuration, code
  signing) ships — re-measure then.
