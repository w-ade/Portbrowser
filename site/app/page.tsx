export default function Home() {
  return (
    <main className="flex flex-1 items-center justify-center px-6">
      <p
        className="max-w-md text-left text-[15px] leading-snug"
        style={{ fontFamily: "ui-rounded, -apple-system, system-ui, sans-serif" }}
      >
        Portbrowser is a native macOS app for previewing websites at true
        iPhone dimensions. Open localhost, LAN, or HTTPS URLs in accurate
        iPhone frames, powered by SwiftUI and WebKit.
      </p>
    </main>
  );
}
