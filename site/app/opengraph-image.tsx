import { ImageResponse } from "next/og";
import { readFile } from "node:fs/promises";
import { join } from "node:path";

// Link-preview card: the six stat-card icons, small, in one centered row on
// white. Same files as the landing page's cards (public/stat-icons).

export const alt = "Portbrowser";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";

const ICONS = ["app-size", "launch", "memory", "chromium", "presets", "native"];
const ICON = 48;
const GAP = 56;

const icons = await Promise.all(
  ICONS.map(async (name) => {
    const svg = await readFile(join(process.cwd(), "public/stat-icons", `${name}.svg`));
    return { name, src: `data:image/svg+xml;base64,${svg.toString("base64")}` };
  }),
);

export default function Image() {
  return new ImageResponse(
    (
      <div
        style={{
          width: "100%",
          height: "100%",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          gap: GAP,
          background: "#fff",
        }}
      >
        {icons.map((i) => (
          // eslint-disable-next-line @next/next/no-img-element -- ImageResponse renders plain img
          <img key={i.name} src={i.src} width={ICON} height={ICON} alt="" />
        ))}
      </div>
    ),
    { ...size },
  );
}
