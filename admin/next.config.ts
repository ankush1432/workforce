import type { NextConfig } from "next";

const nextConfig: NextConfig = {
   output: "export",
   trailingSlash: true,
  images: {
    unoptimized: true,
  },
  basePath: "/admin",
  assetPrefix: "/admin",
};

export default nextConfig;
