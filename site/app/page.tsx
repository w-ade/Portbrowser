export default function Home() {
  return (
    <main className="flex flex-1 items-center justify-center px-6">
      <p
        className="max-w-md text-left text-[15px] leading-snug"
        style={{ fontFamily: "ui-rounded, -apple-system, system-ui, sans-serif" }}
      >
        <strong className="font-semibold">Portbrowser</strong> is a native
        macOS app for previewing websites at true iPhone dimensions. Open
        localhost, LAN, or HTTPS URLs in accurate iPhone frames, powered by
        SwiftUI and WebKit.
      </p>
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
