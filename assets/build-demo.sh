#!/bin/bash
# build-demo.sh — render assets/demo.html frame-by-frame with headless Chrome and
# stitch them into assets/demo.gif with ffmpeg. Reproducible; no screen recording needed.
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
TMP="$(mktemp -d)"

# per-frame hold time in seconds (index = frame number)
holds=(1.4 1.0 0.5 1.1 1.6 0.8 1.8 1.9)

for f in "${!holds[@]}"; do
  "$CHROME" --headless=new --disable-gpu --hide-scrollbars --force-device-scale-factor=2 \
    --window-size=1000,600 --screenshot="$TMP/frame-$f.png" \
    "file://$DIR/demo.html?frame=$f" >/dev/null 2>&1
done

# concat list with per-frame durations
: > "$TMP/list.txt"
for f in "${!holds[@]}"; do
  printf "file '%s/frame-%s.png'\nduration %s\n" "$TMP" "$f" "${holds[$f]}" >> "$TMP/list.txt"
done
# ffmpeg needs the last frame repeated once more for the final duration to apply
printf "file '%s/frame-%s.png'\n" "$TMP" "$((${#holds[@]}-1))" >> "$TMP/list.txt"

# two-pass palette for a clean GIF, downscaled to 1000px wide
ffmpeg -y -f concat -safe 0 -i "$TMP/list.txt" -vf "scale=1000:-1:flags=lanczos,palettegen=stats_mode=diff" "$TMP/pal.png" >/dev/null 2>&1
ffmpeg -y -f concat -safe 0 -i "$TMP/list.txt" -i "$TMP/pal.png" \
  -lavfi "scale=1000:-1:flags=lanczos[x];[x][1:v]paletteuse=dither=bayer:bayer_scale=3" \
  "$DIR/demo.gif" >/dev/null 2>&1

echo "wrote $DIR/demo.gif"
ls -lh "$DIR/demo.gif"
