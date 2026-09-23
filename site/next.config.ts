import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Let Portbrowser (or a phone) open the dev server by LAN IP. Without this,
  // Next blocks dev resources from non-localhost origins and the page never
  // hydrates, so client components like the theme toggle don't respond.
  allowedDevOrigins: ["192.168.*.*"],
};

export default nextConfig;
