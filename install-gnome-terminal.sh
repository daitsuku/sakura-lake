#!/usr/bin/env bash
# Cherry Blossom Sakura Lake — GNOME Terminal profile installer
# Sampled from three sakura wallpapers (see README.md for sources)
# GNOME Terminal has no portable theme file, so this script creates the
# profile via dconf. Run on the Linux machine using GNOME Terminal:
#
#   chmod +x install-gnome-terminal.sh
#   ./install-gnome-terminal.sh
#
# Then select the "Cherry Blossom Sakura Lake" profile in
# Terminal > Preferences > Profiles.

set -euo pipefail

PROFILE_NAME="Cherry Blossom Sakura Lake"
BASE="/org/gnome/terminal/legacy/profiles:"

rgb() { printf 'rgb(%s,%s,%s)' "$1" "$2" "$3"; }

# Cherry Blossom Sakura Lake palette (normal 0-7, bright 8-15)
PALETTE="rgb(46,42,38):rgb(216,149,159):rgb(154,168,107):rgb(214,183,135):rgb(127,163,184):rgb(190,138,162):rgb(134,181,172):rgb(230,223,211):rgb(78,73,61):rgb(234,179,186):rgb(179,192,132):rgb(232,208,162):rgb(157,188,205):rgb(212,169,190):rgb(164,207,198):rgb(245,239,227)"
BG="rgb(27,25,23)"
FG="rgb(230,223,211)"
CURSOR_BG="rgb(216,149,159)"
CURSOR_FG="rgb(27,25,23)"

# Reuse an existing profile with the same name, or create a new UUID.
UUID=""
for id in $(dconf list "$BASE" | tr -d ':/'); do
    name=$(dconf read "$BASE/:$id/visible-name" 2>/dev/null || echo "")
    if [ "$name" = "'$PROFILE_NAME'" ]; then
        UUID="$id"
        break
    fi
done
if [ -z "$UUID" ]; then
    if command -v uuidgen >/dev/null 2>&1; then
        UUID=$(uuidgen)
    else
        UUID=$(cat /proc/sys/kernel/random/uuid)
    fi
    UUID=$(echo "$UUID" | tr '[:upper:]' '[:lower:]')
fi

P="$BASE/:$UUID"
dconf write "$P/visible-name" "'$PROFILE_NAME'"
dconf write "$P/palette" "['${PALETTE//:/\', \'}']"
dconf write "$P/background-color" "'$BG'"
dconf write "$P/foreground-color" "'$FG'"
dconf write "$P/bold-color" "'$FG'"
dconf write "$P/bold-color-same-as-fg" "true"
dconf write "$P/cursor-colors-set" "true"
dconf write "$P/cursor-background-color" "'$CURSOR_BG'"
dconf write "$P/cursor-foreground-color" "'$CURSOR_FG'"
dconf write "$P/use-theme-colors" "false"
dconf write "$P/use-theme-transparency" "false"
dconf write "$P/use-transparent-background" "true"
dconf write "$P/background-transparency-percent" "15"

# Append the profile UUID to the profile list if missing.
LIST=$(dconf read "$BASE/list" 2>/dev/null || echo "[]")
if [[ "$LIST" != *"$UUID"* ]]; then
    if [ "$LIST" = "[]" ] || [ -z "$LIST" ]; then
        dconf write "$BASE/list" "['$UUID']"
    else
        dconf write "$BASE/list" "${LIST%]*} , '$UUID']"
    fi
fi

echo "Profile '$PROFILE_NAME' installed ($UUID)."
