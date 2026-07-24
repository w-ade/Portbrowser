# Portview backlog

The path from working prototype to a renamed, distributable macOS developer utility.

## Now

## PB-007 · Rename and reposition the product
- **Status:** open
- **Size:** M
- **Tags:** brand, product
- **Why:** the current name and presentation are temporary, and app identity changes ripple through packaging and distribution.
- **Spec:** choose the final product name, one-sentence purpose, visual direction, repository name, executable name, and direct-distribution strategy.
- **Done means:** one approved name and product brief are the source of truth for every following card.

## PB-008 · Create a proper Xcode macOS app target
- **Status:** open (blocked on: PB-007)
- **Size:** L
- **Tags:** architecture, packaging
- **Why:** the current SwiftPM script hand-assembles an app bundle and is not a durable release pipeline.
- **Spec:** create a native macOS app project, move the existing Swift sources and resources into its app target, preserve the lightweight AppKit/SwiftUI architecture, and keep a one-command local run path.
- **Done means:** Xcode can build, run, archive, and export the app without manually constructing `Contents/` in Bash.

## PB-009 · Establish the final app identity
- **Status:** open (blocked on: PB-007, PB-008)
- **Size:** M
- **Tags:** brand, metadata
- **Why:** macOS distribution requires stable identity and complete bundle metadata.
- **Spec:** add the final bundle identifier, product/executable names, AppIcon asset catalog, version and build numbers, copyright, category, and About panel.
- **Done means:** Finder, Activity Monitor, About, the menu bar, and the built bundle all show the final identity consistently.

## PB-010 · Preserve user data through the rename
- **Status:** open (blocked on: PB-007, PB-009)
- **Size:** S
- **Tags:** persistence, migration
- **Why:** changing the bundle identifier can strand recent URLs and preferences under the old defaults domain.
- **Spec:** define the final defaults keys and migrate existing Portview recent URLs/settings once when the renamed app first launches.
- **Done means:** existing local state survives the rename without keeping legacy branding visible.

## PB-011 · Add browser loading and failure states
- **Status:** open
- **Size:** M
- **Tags:** browser, ux
- **Why:** a real utility must explain invalid URLs, stopped dev servers, navigation failures, and loading instead of showing an ambiguous blank page.
- **Spec:** expose loading progress, invalid-address feedback, connection failure with retry, and a quiet empty state while preserving the fixed viewport.
- **Done means:** every common URL/server outcome produces a clear state and recovery action.

## PB-012 · Finish the utility preferences
- **Status:** open
- **Size:** M
- **Tags:** settings, window
- **Why:** frequently changed preview behavior should not require code edits or permanent viewport chrome.
- **Spec:** add lightweight controls for always-on-top, status/device overlay visibility, appearance, default URL, and launch behavior. Persist settings locally.
- **Done means:** the expected daily-use options survive relaunch and never change the underlying viewport dimensions.

## Next

## PB-005 · Make device overlays configurable
- **Status:** open
- **Size:** S
- **Tags:** overlay
- **Why:** the Dynamic Island and status layer help visual comparison but should not be forced into raw viewport checks.
- **Spec:** make the exact SVG status layer, Dynamic Island, safe-area guides, and tap-target guides independently toggleable without changing layout.
- **Done means:** overlays can be enabled for design review and disabled for an unobstructed webview.

## PB-013 · Build a real Release configuration
- **Status:** open (blocked on: PB-008, PB-009)
- **Size:** M
- **Tags:** release, build
- **Why:** the current artifact is a debug-oriented, ad-hoc-signed build.
- **Spec:** create a reproducible optimized Release archive, strip debug-only behavior, preserve resources, and install the exported app into `/Applications` for local validation.
- **Done means:** the app launches and completes its core workflow outside Xcode and outside the repository.

## PB-014 · Reduce permissions and define entitlements
- **Status:** open (blocked on: PB-008)
- **Size:** M
- **Tags:** security, networking
- **Why:** the current bundle broadly allows arbitrary network loads and has no intentional release entitlement policy.
- **Spec:** document the minimum WebKit/local-network needs, narrow App Transport Security exceptions where practical, remove `get-task-allow` from release builds, and decide whether App Sandbox is compatible with direct distribution.
- **Done means:** the release entitlements and Info.plist contain only capabilities the product actually requires.

## PB-015 · Decide supported Macs and architectures
- **Status:** open
- **Size:** S
- **Tags:** compatibility, release
- **Why:** the current build is arm64-only and targets macOS 14.
- **Spec:** choose the minimum macOS version and decide between Apple-silicon-only and a universal arm64/x86_64 build based on the intended audience.
- **Done means:** deployment target and architecture policy are documented and verified by the release build.

## PB-016 · Add Developer ID signing and Hardened Runtime
- **Status:** blocked (on: Apple Developer membership and Developer ID Application certificate)
- **Size:** M
- **Tags:** signing, security
- **Why:** Gatekeeper cannot trust the current ad-hoc-signed bundle.
- **Spec:** install the signing identity, assign the development team, enable Hardened Runtime, sign nested resources correctly, and include a secure timestamp.
- **Done means:** `codesign` validates the exported app and reports a Developer ID signature with no debug entitlement.

## PB-017 · Notarize and staple the release
- **Status:** open (blocked on: PB-016)
- **Size:** M
- **Tags:** notarization, release
- **Why:** a directly downloaded Mac app should pass Gatekeeper without frightening installation workarounds.
- **Spec:** submit the signed artifact with `notarytool`, retain the notarization log, staple the ticket, and validate with `spctl`.
- **Done means:** Gatekeeper accepts the app from a quarantined download on a separate user account or Mac.

## PB-018 · Create the distributable DMG
- **Status:** open (blocked on: PB-017)
- **Size:** M
- **Tags:** packaging, distribution
- **Why:** users need a familiar, low-friction installation artifact.
- **Spec:** create a clean DMG containing the app and an Applications shortcut, then sign/notarize the final deliverable as required.
- **Done means:** the DMG supports drag-to-install and preserves the validated app signature and notarization ticket.

## PB-019 · Run release and resource QA
- **Status:** open (blocked on: PB-013, PB-017)
- **Size:** L
- **Tags:** qa, performance
- **Why:** the product promise depends on being much lighter than Simulator while still behaving predictably.
- **Spec:** verify New Window, URL loading, reload, Command-K/C/V/R/W, saved state, main-display placement, always-on-top, error states, CPU, memory, cold launch, and WebKit cleanup across repeated windows.
- **Done means:** a release checklist passes on a clean install with no crashes, runaway web processes, clipped UI, or missing resources.

## PB-020 · Publish the first GitHub release
- **Status:** open (blocked on: PB-018, PB-019)
- **Size:** S
- **Tags:** release, docs
- **Why:** the downloadable artifact needs a trustworthy home and clear expectations.
- **Spec:** write a concise README, installation instructions, limitations, privacy statement, release notes, screenshots, and checksums; attach the notarized DMG to a tagged release.
- **Done means:** a new user can understand, download, verify, install, and launch the app without repository knowledge.

## Later

## PB-006 · Add device preset switching
- **Status:** open
- **Size:** M
- **Tags:** presets
- **Why:** one trusted default matters most, but additional common devices make the utility broadly useful.
- **Spec:** support selected iPhone presets and custom logical dimensions while preserving deterministic, non-resizable window sizing.
- **Done means:** presets update the viewport and outer window predictably without distorting content.

## PB-021 · Add automatic updates
- **Status:** open (blocked on: stable signed releases)
- **Size:** L
- **Tags:** updates, distribution
- **Why:** manually reinstalling every release will become friction once other people use the app.
- **Spec:** evaluate Sparkle, establish signed update feeds, define update channels, and preserve notarization and code-signing integrity.
- **Done means:** the app can discover, verify, install, and relaunch into a newer signed version.

## PB-022 · Add lightweight diagnostics
- **Status:** open
- **Size:** M
- **Tags:** reliability, privacy
- **Why:** release failures need enough evidence to diagnose without turning a tiny utility into an analytics product.
- **Spec:** add local diagnostic export for app version, macOS version, loaded URL host, WebKit errors, memory footprint, and recent failures. Keep telemetry opt-in or local-only.
- **Done means:** a user can produce a useful support bundle without exposing page content or secrets.

## PB-023 · Evaluate Mac App Store distribution
- **Status:** open (blocked on: successful direct-distribution release)
- **Size:** M
- **Tags:** app-store, strategy
- **Why:** the App Store may improve discovery but introduces sandbox and review constraints for a localhost browser utility.
- **Spec:** test the required sandbox model, local-network behavior, WebKit permissions, review guidelines, and maintenance cost against the direct-download version.
- **Done means:** there is an evidence-based decision to pursue or reject an App Store edition.

## PB-001 · Match the iOS Simulator viewport
- **Status:** done 2026-07-20
- **Size:** M
- **Tags:** viewport
- **Why:** the preview must match the trusted iPhone 17 viewport closely enough for daily layout work.
- **Spec:** render the iPhone 17 logical viewport at the Simulator's visible scale without a fake device shell.
- **Done means:** Portview uses a fixed 366 x 795 visible viewport backed by a 402 x 874 logical mobile webview.

## PB-002 · Keep the window intentionally fixed
- **Status:** done 2026-07-20
- **Size:** S
- **Tags:** window
- **Why:** resizing creates ambiguous preview states.
- **Spec:** keep the viewport non-resizable, square-cornered, and centered on the main display.
- **Done means:** every new window opens at the trusted dimensions and cannot be resized accidentally.

## PB-003 · Preserve browser-like basics
- **Status:** done 2026-07-20
- **Size:** M
- **Tags:** browser, shortcuts
- **Why:** a focused preview still needs normal Mac/browser behavior.
- **Spec:** provide native traffic lights, New Window, Close, reload, editable URL input, recent URL persistence, Command-C/V/R/W, and per-window sessions.
- **Done means:** each window behaves like a lightweight independent browser without consuming viewport space.

## PB-004 · Establish the URL input model
- **Status:** done 2026-07-20
- **Size:** M
- **Tags:** ux, browser
- **Why:** URLs must be editable without changing the phone viewport dimensions.
- **Spec:** place URL input and reload in a fixed 32-point utility strip outside the 366 x 795 viewport; use Command-K to focus and select it.
- **Done means:** URLs can be changed quickly while the preview geometry remains untouched.
