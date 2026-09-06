#!/bin/bash
set -euo pipefail

BUILD_TYPE="Release"
RUN_MODE="run"
DEVICE_PATH=""

usage() {
    cat <<EOF
Usage: ./build.sh [debug|release] [build|gui|/dev/input/eventX]

Examples:
  ./build.sh                         Build (release) and run with auto-detected touchpad
  ./build.sh debug                   Build (debug) and run with auto-detected touchpad
  ./build.sh release build           Build only; do not run
  ./build.sh release gui             Build and open GUI without a touchpad device
  ./build.sh release /dev/input/event5   Build and run on a specific device
EOF
}

detect_touchpad_device() {
    if ! command -v libinput >/dev/null 2>&1; then
        echo "libinput CLI not found; cannot auto-detect touchpad." >&2
        return 1
    fi

    local device_path
    device_path="$(libinput list-devices 2>/dev/null | awk '
        /Touchpad/ { in_tp=1; next }
        in_tp && /Kernel:/ {
            sub(/^[ \t]*Kernel:[ \t]*/, "", $0)
            print $0
            exit
        }
        in_tp && /^Device:/ { in_tp=0 }
    ')"

    if [ -n "${device_path:-}" ] && [ -e "$device_path" ]; then
        echo "$device_path"
        return 0
    fi

    return 1
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    usage
    exit 0
fi

INPUT_TYPE=$(echo "${1:-release}" | tr '[:upper:]' '[:lower:]')
case "$INPUT_TYPE" in
    debug) BUILD_TYPE="Debug" ;;
    release) BUILD_TYPE="Release" ;;
    *) echo "Unknown build type: $INPUT_TYPE" >&2; usage; exit 1 ;;
esac

SECOND_ARG="${2:-}"
case "$SECOND_ARG" in
    build)
        RUN_MODE="build"
        ;;
    gui)
        RUN_MODE="gui"
        ;;
    "")
        RUN_MODE="run"
        ;;
    *)
        if [[ "$SECOND_ARG" == /dev/input/* ]]; then
            DEVICE_PATH="$SECOND_ARG"
            RUN_MODE="run"
        else
            echo "Unknown option: $SECOND_ARG" >&2
            usage
            exit 1
        fi
        ;;
esac

if [ ! -d "imgui" ]; then
    echo "Dear ImGui not found. Run ./setup.sh first." >&2
    exit 1
fi

echo "Building in $BUILD_TYPE mode..."

mkdir -p build
cd build

cmake -DCMAKE_BUILD_TYPE="$BUILD_TYPE" ..
cmake --build . --parallel "$(nproc 2>/dev/null || echo 2)"

if [ "$RUN_MODE" = "build" ]; then
    echo "Build finished: $(pwd)/gesture_daemon"
    exit 0
fi

if [ "$RUN_MODE" = "gui" ]; then
    echo "Running gesture_daemon in GUI-only mode (no touchpad device)."
    ./gesture_daemon --gui-only
    exit 0
fi

if [ -z "$DEVICE_PATH" ]; then
    if DEVICE_PATH="$(detect_touchpad_device)"; then
        echo "Auto-detected touchpad: $DEVICE_PATH"
    else
        echo "No touchpad device found." >&2
        echo "Try one of the following:" >&2
        echo "  libinput list-devices | grep -iA10 Touchpad" >&2
        echo "  ./build.sh $INPUT_TYPE gui            # test the GUI only" >&2
        echo "  ./build.sh $INPUT_TYPE /dev/input/eventX" >&2
        exit 1
    fi
fi

if [ ! -e "$DEVICE_PATH" ]; then
    echo "Device path does not exist: $DEVICE_PATH" >&2
    exit 1
fi

echo "Running gesture_daemon on $DEVICE_PATH"
./gesture_daemon "$DEVICE_PATH"
