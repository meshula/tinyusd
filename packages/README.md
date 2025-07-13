# Packages Directory

This directory contains the USD source code and dependencies needed for building TinyUSD.

## Getting USD Source

Shallow clone USD dev branch here:

```bash
git clone --depth 1 https://github.com/PixarAnimationStudios/USD.git -b dev
```

## Project Structure

TinyUSD follows a structured build convention:

```
tinyusd/
├── packages/           # Dependencies and USD source (gitignored)
│   └── USD/           # USD source code (clone here)
├── recipes/           # Build instructions for different platforms
│   └── macos-cmake-dynamic.md
├── build-*/           # Build directories (gitignored, named by recipe)
│   └── build-macos-cmake-dynamic/
├── db9/               # Project knowledge databases (gitignored)
│   ├── todos.db9      # Task tracking
│   └── facts.db9      # Project knowledge
└── src/               # TinyUSD minimal implementation

```

## Build Convention

Each recipe gets its own build directory following the pattern `build-<recipe-name>`:

- **macos-cmake-dynamic** → `build-macos-cmake-dynamic/`
- **macos-cmake-static** → `build-macos-cmake-static/` 
- **windows-msvc** → `build-windows-msvc/`

All `build-*` directories are automatically gitignored to keep the repository clean.

## Getting Started

1. Clone USD source into this packages directory (see command above)
2. Follow the appropriate recipe in `/recipes/` for your platform
3. Build artifacts will be organized in the corresponding `build-*` directory

This structure keeps builds isolated and makes it easy to maintain multiple configurations simultaneously.

