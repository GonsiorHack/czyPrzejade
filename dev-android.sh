#!/usr/bin/env bash
# Uruchamia wszystko jedną komendą: backend + emulator (headless) + podgląd scrcpy + aplikację.
# Użycie:  ./dev-android.sh        (zatrzymanie: q w terminalu flutter, potem ./dev-android.sh stop)
set -u
ROOT="$(cd "$(dirname "$0")" && pwd)"
ADB="$HOME/Android/Sdk/platform-tools/adb"
EMU="$HOME/Android/Sdk/emulator/emulator"
SCRCPY="$HOME/.local/opt/scrcpy-linux-x86_64-v5.0.1/scrcpy"
LOG=/tmp/czyprzejade
mkdir -p "$LOG"

if [ "${1:-}" = "stop" ]; then
  "$ADB" emu kill 2>/dev/null
  pkill -f "uvicorn main:app" 2>/dev/null
  pkill scrcpy 2>/dev/null
  echo "Zatrzymano emulator, backend i scrcpy."
  exit 0
fi

# 1. Backend (tylko jeśli nie działa)
if ! curl -s -o /dev/null http://localhost:8000/api/zones; then
  echo "[1/4] Startuję backend..."
  (cd "$ROOT/backend" && source .venv/bin/activate \
    && nohup uvicorn main:app --host 0.0.0.0 --port 8000 > "$LOG/backend.log" 2>&1 &)
else
  echo "[1/4] Backend już działa."
fi

# 2. Emulator (tylko jeśli nie ma urządzenia)
if ! "$ADB" devices | grep -q "emulator-5554"; then
  echo "[2/4] Startuję emulator (headless)..."
  nohup "$EMU" -avd Pixel_8_API36 -no-window -no-audio -no-snapshot-load \
    -gpu swiftshader_indirect > "$LOG/emulator.log" 2>&1 &
else
  echo "[2/4] Emulator już działa."
fi
"$ADB" wait-for-device
echo "      Czekam na pełny start Androida (do ~2 min)..."
until [ "$("$ADB" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = 1 ]; do sleep 3; done

# 3. Podgląd ekranu
echo "[3/4] Otwieram okno podglądu (scrcpy)..."
pgrep -x scrcpy > /dev/null || ADB="$ADB" nohup "$SCRCPY" -s emulator-5554 --window-title czyPrzejade > "$LOG/scrcpy.log" 2>&1 &

# 4. Aplikacja
echo "[4/4] Uruchamiam aplikację (r = hot reload, R = restart, q = wyjście)..."
cd "$ROOT/mobile" && flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8000
