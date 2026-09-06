# Touchpad Gesture Daemon

A Linux daemon with an interactive GUI for mapping multi-finger touchpad gestures to shell commands. Built with `libinput`, `GLFW`, `OpenGL`, and `Dear ImGui`.

## Features

- Detects swipe gestures (3-finger and 4-finger) in all directions
- Recognizes pinch (zoom in/out) and hold gestures
- Tracks scroll and pointer movement
- Configurable gesture-to-command bindings via ImGui GUI
- Built-in presets (`playerctl`, `notify-send`, etc.)
- Custom shell command support
- Simple CLI usage with interactive GUI
- Lightweight and easy to use

---

## Quick Start (Windows via WSL)

This project is **Linux-only** (it uses `libinput` and `/dev/input/*`). On Windows, use **WSL2 with Ubuntu** and WSLg for the GUI.

### 1. Open the project in WSL

From PowerShell or Windows Terminal:

```powershell
wsl
cd /mnt/c/Users/khush/TouchDaemon-1
```

### 2. Run setup (installs deps + clones ImGui)

```bash
chmod +x setup.sh build.sh
./setup.sh
```

### 3. Build and test

```bash
# GUI-only mode (works in WSL even without a touchpad device)
./build.sh release gui

# Full build + run (requires a Linux touchpad device)
./build.sh
```

> **Note:** WSL usually does **not** expose your laptop touchpad at `/dev/input/*`. Use `./build.sh release gui` to verify the UI and bindings in WSL. For real gesture detection, run on native Linux (dual-boot, VM with USB passthrough, or a Linux machine).

---

## Quick Start (Native Linux)

### 1. Clone and enter the repo

```bash
git clone https://github.com/S0r4-0/TouchDaemon
cd TouchDaemon
```

### 2. Run setup

```bash
chmod +x setup.sh build.sh
./setup.sh
```

### 3. Build and run

```bash
./build.sh                  # release build, auto-detect touchpad, run
./build.sh debug            # debug build and run
./build.sh release build    # build only
./build.sh release gui      # GUI-only test mode
./build.sh release /dev/input/event5
```

Find your touchpad device path:

```bash
libinput list-devices | grep -iA10 "Touchpad"
```

---

## Dependencies

### Required Libraries

- `libinput`
- `libudev`
- `libx11`
- `libgl1-mesa-dev`
- `libglfw3` / `libglfw3-dev`
- `libpthread`
- `cmake`, `build-essential`, `pkg-config`

### 3rd Party

- [Dear ImGui](https://github.com/ocornut/imgui) — cloned automatically by `setup.sh`

### Manual install (Debian/Ubuntu)

```bash
sudo apt install build-essential cmake pkg-config \
  libinput-dev libudev-dev libglfw3-dev libx11-dev libgl1-mesa-dev
```

---

## Usage

### Build script options

| Command | Description |
|---------|-------------|
| `./build.sh` | Release build, auto-detect touchpad, run |
| `./build.sh debug` | Debug build and run |
| `./build.sh release build` | Build only (output: `build/gesture_daemon`) |
| `./build.sh release gui` | Open GUI without a touchpad device |
| `./build.sh release /dev/input/eventX` | Run on a specific input device |

### Direct binary usage

```bash
./build/gesture_daemon /dev/input/event5
./build/gesture_daemon --gui-only
```

---

## How It Works

- Initializes a GUI window using ImGui
- Listens to `libinput` gesture events (unless `--gui-only`)
- Identifies swipes, pinches, and holds
- Lets you assign commands to each gesture
- Runs assigned shell commands on gesture detection

---

## UI Overview

- Dropdown selectors to map gestures
- Text box for adding custom commands
- UI handles cleanup of unused mappings

![UI Interface - 1](assets/UI-1.png)

![UI Interface - 2](assets/UI-2.png)

---

## Example Bindings

| Gesture             | Action Command                 |
|---------------------|---------------------------------|
| 3-finger swipe up   | `gnome-terminal`               |
| 4-finger swipe left | `playerctl previous`           |
| 4-finger swipe down | `notify-send 'Swipe Detected'` |

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `Dear ImGui not found` | Run `./setup.sh` |
| `No touchpad device found` | Use `./build.sh release gui`, or pass the correct `/dev/input/eventX` path |
| GUI does not appear in WSL | Ensure WSLg is enabled (Windows 11); update WSL: `wsl --update` |
| `Failed to open: /dev/input/...` | Run on native Linux, or check permissions (`input` group) |
| Build fails on OpenGL | Install `libgl1-mesa-dev` via `./setup.sh` |

---

## License

This project is licensed under the [MIT License](./LICENSE).
