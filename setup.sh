#!/bin/bash
set -euo pipefail

echo "=== TouchDaemon setup ==="

missing_deps=()
for pkg in build-essential cmake pkg-config libinput-dev libudev-dev libglfw3-dev libx11-dev libgl1-mesa-dev; do
    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
        missing_deps+=("$pkg")
    fi
done

if [ "${#missing_deps[@]}" -gt 0 ]; then
    if command -v apt-get >/dev/null 2>&1; then
        echo "Installing missing packages: ${missing_deps[*]}"
        sudo apt-get update
        sudo apt-get install -y "${missing_deps[@]}"
    else
        echo "Missing packages: ${missing_deps[*]}" >&2
        echo "Install them manually (see README.md)." >&2
        exit 1
    fi
else
    echo "All build dependencies already installed."
fi

# Clone Dear ImGui if missing
if [ ! -d "imgui" ]; then
    echo "Cloning Dear ImGui..."
    git clone --depth 1 https://github.com/ocornut/imgui.git
else
    echo "Dear ImGui already present."
fi

echo ""
echo "Setup complete."
echo "Next steps:"
echo "  1. Find your touchpad device (Linux only):"
echo "       libinput list-devices | grep -iA10 Touchpad"
echo "  2. Build and run:"
echo "       ./build.sh                  # release build + run"
echo "       ./build.sh debug            # debug build + run"
echo "       ./build.sh release build    # build only, no run"
echo "       ./build.sh release /dev/input/event5"
echo "  3. GUI-only test (no touchpad required):"
echo "       ./build.sh release gui"
