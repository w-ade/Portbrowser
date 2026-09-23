import { Inter } from "next/font/google";

const inter = Inter({ subsets: ["latin"] });

// Numbers from docs/performance.md (release build, measured 2026-09-23).
// Only the ones that doc clears for quoting: memory is the total with
// WebKit's helpers, launch is the stable warm figure, and the single-sample
// cold launch stays out until it is re-measured.
const STATS = [
  { value: "1.8 MB", label: "App size", icon: "app-size" },
  { value: "~340 ms", label: "to launch", icon: "launch" },
  { value: "~61 MB", label: "Memory at idle", icon: "memory" },
  { value: "0 MB", label: "of Chromium", icon: "chromium" },
  { value: "11", label: "iPhone presets", icon: "presets" },
  { value: "arm64", label: "Native, macOS 14+", icon: "native" },
];

export default function Home() {
  return (
    <main className="flex flex-1 flex-col items-center px-6 pt-[18vh] pb-24">
      <div className={`w-full max-w-md ${inter.className}`}>
        <p className="text-left text-[14px] leading-snug">
          <strong className="font-semibold">Portbrowser</strong> is a native
          macOS app for previewing websites at true iPhone dimensions. Open
          localhost, LAN, or HTTPS URLs in accurate iPhone frames, powered by
          SwiftUI and WebKit.{" "}
          <a
            href="https://github.com/w-ade/Portbrowser"
            target="_blank"
            rel="noopener"
            aria-label="Portbrowser on GitHub"
            className="inline-block align-[-0.15em] text-[#007AFF] opacity-90 transition-opacity hover:opacity-100"
          >
            {/* GitHub's mark (octicon mark-github), sized to the text */}
            <svg viewBox="0 0 16 16" width="1em" height="1em" fill="currentColor" aria-hidden="true">
              <path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z" />
            </svg>
          </a>
        </p>
        <ul className="mt-6 grid grid-cols-2 gap-2">
          {STATS.map((s) => (
            // the designed 375x230 card, scaled to its column: same shape
            // and corner, with the text and icon kept at readable sizes
            <li
              key={s.label}
              className="relative aspect-[375/230] rounded-[12px] bg-[#F6F6F5] p-3 sm:p-3.5"
            >
              <p className="text-[15px] font-medium leading-tight text-[#323232]">{s.value}</p>
              <p className="mt-0.5 text-[11px] leading-tight text-[#666666]">{s.label}</p>
              {/* eslint-disable-next-line @next/next/no-img-element -- tiny static svg */}
              <img
                src={`/stat-icons/${s.icon}.svg`}
                alt=""
                width={22}
                height={22}
                className="absolute right-3 bottom-3 sm:right-3.5 sm:bottom-3.5"
              />
            </li>
          ))}
        </ul>
      </div>
      {/* TODO: swap font-family to "Gen Interface JP Display" once the font file is available in this project */}
      <p
        className="fixed inset-x-0 bottom-5 px-4 text-center text-[9px] font-normal text-[#E8E8E8]"
        style={{ fontFamily: "var(--font-geist-sans), sans-serif" }}
      >
        Made on macOS, for checking the thing before you check the thing on
        your phone.
      </p>
    </main>
  );
}
