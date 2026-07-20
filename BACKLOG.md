# Visto backlog

## Now

## VISTO-001 · Match the iOS Simulator viewport
- **Status:** open
- **Size:** M
- **Tags:** viewport
- **Why:** Visto only works if its preview matches the simulator closely enough to trust during layout work.
- **Spec:** render the iPhone 17 logical viewport at the same visible scale/shape as Simulator with device bezels off, without the extra URL bar, titlebar height, or fake phone shell.
- **Done means:** Visto and the Simulator show the same page at the same usable viewport size on the main display.

## VISTO-002 · Keep the window intentionally fixed
- **Status:** open
- **Size:** S
- **Tags:** window
- **Why:** resizing keeps creating ambiguous preview states.
- **Spec:** make the Visto window non-resizable once the correct target size is established.
- **Done means:** the window opens on the main display, fits the screen, and cannot be resized by accident.

## VISTO-003 · Preserve browser-like basics
- **Status:** open
- **Size:** S
- **Tags:** app
- **Why:** even a minimal viewport app still needs normal Mac behavior.
- **Spec:** support File > New Window, Command-W close, Command-C/V in editable fields, and a reload path that does not require visible chrome in the viewport.
- **Done means:** Visto behaves like a small focused browser without adding UI around the preview.

## Next

## VISTO-004 · Decide the URL input model
- **Status:** open
- **Size:** M
- **Tags:** ux
- **Why:** the URL bar breaks the viewport, but the app still needs a clean way to switch dev-server URLs.
- **Spec:** choose between a menu command, command palette, transient overlay, or launch/recent URL model.
- **Done means:** URLs can be changed without permanently consuming viewport space.

## VISTO-005 · Add lightweight device overlays
- **Status:** open
- **Size:** S
- **Tags:** overlay
- **Why:** Dynamic Island and safe-area hints help compare against iPhone layouts without running the full simulator.
- **Spec:** add optional status/Dynamic Island overlay that can be toggled without changing the underlying viewport size.
- **Done means:** overlay can be enabled for layout reference and disabled for raw viewport checks.

## Later

## VISTO-006 · Add preset switching after the default is correct
- **Status:** open
- **Size:** M
- **Tags:** presets
- **Why:** multiple devices are useful, but only after the main iPhone 17 target is reliable.
- **Spec:** support iPhone 17, 17 Pro Max, and a custom size without reopening the sizing argument every time.
- **Done means:** presets change window/content size predictably and remain non-resizable.
