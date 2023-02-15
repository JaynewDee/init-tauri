#!/bin/bash

set -e

curl https://sh.rustup.rs -sSf | sh

rustup update

cargo create-tauri-app $1 --template vanilla --manager cargo

cd "${1}"
rm -rf src

npm create vite@latest src

cd src
npm i
npm i "@tauri-apps/api" "@types/node"

rm vite.config.ts
touch vite.config.ts

cat > ./vite.config.ts <<EOL
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  clearScreen: false,
  server: {
    strictPort: true,
    port: 1420
  },
  envPrefix: ["VITE_", "TAURI_"],
  build: {
    target: process.env.TAURI_PLATFORM == "windows" ? "chrome105" : "safari13",
    minify: !process.env.TAURI_DEBUG ? "esbuild" : false,
    sourcemap: !!process.env.TAURI_DEBUG,
    outDir: "../build",
    watch: {}
  }
});
EOL
npm run dev &
npm run build &

cd ../

rm ./src-tauri/tauri.conf.json
touch ./src-tauri/tauri.conf.json
cat > ./src-tauri/tauri.conf.json <<EOL
{
  "build": {
    "devPath": "http://localhost:1420",
    "distDir": "../build",
    "withGlobalTauri": true
  },
  "package": {
    "productName": "src-tauri",
    "version": "0.0.0"
  },
  "tauri": {
    "allowlist": {
      "all": false,
      "shell": {
        "all": false,
        "open": true
      }
    },
    "bundle": {
      "active": true,
      "category": "DeveloperTool",
      "copyright": "",
      "deb": {
        "depends": []
      },
      "externalBin": [],
      "icon": [
        "icons/32x32.png",
        "icons/128x128.png",
        "icons/128x128@2x.png",
        "icons/icon.icns",
        "icons/icon.ico"
      ],
      "identifier": "com.tauri.dev",
      "longDescription": "",
      "macOS": {
        "entitlements": null,
        "exceptionDomain": "",
        "frameworks": [],
        "providerShortName": null,
        "signingIdentity": null
      },
      "resources": [],
      "shortDescription": "",
      "targets": "all",
      "windows": {
        "certificateThumbprint": null,
        "digestAlgorithm": "sha256",
        "timestampUrl": ""
      }
    },
    "security": {
      "csp": null
    },
    "updater": {
      "active": false
    },
    "windows": [
      {
        "fullscreen": false,
        "height": 800,
        "resizable": true,
        "title": "src-tauri",
        "width": 600
      }
    ]
  }
}
EOL

echo "build" >> ".gitignore"

code .

cargo tauri dev
