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
          SwiftUI and WebKit.
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
