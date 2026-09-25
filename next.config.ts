import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: "standalone",
  images: {
    unoptimized: true,
  },
  poweredByHeader: false,
  async redirects() {
    return [
      {
        source: "/:path*",
        has: [
          {
            type: "host",
            value: "www.tared.co.uk",
          },
        ],
        destination: "https://tared.co.uk/:path*",
        permanent: true,
      },
    ];
  },
};

export default nextConfig;
