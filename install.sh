#!/bin/sh
# Alerion Hub installieren (Debian/Ubuntu, x86_64).
#   curl -fsSL https://raw.githubusercontent.com/P3rc1v4l/alerion-hub-ablage/main/install.sh | sudo sh
# Prüft die Signatur des Katalogs (Schlüssel von Luka Kalinka) und die
# Prüfsumme des Pakets, dann installiert es über apt.
set -eu
BASE="https://raw.githubusercontent.com/P3rc1v4l/alerion-hub-ablage/main"
KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIENWzAjR6K0rDnb8vA7IBLpXknJOPAed9TQrgNOLhiRN"

[ "$(id -u)" = 0 ] || { echo "Bitte mit sudo starten." >&2; exit 1; }
[ "$(uname -m)" = x86_64 ] || { echo "Nur x86_64 wird unterstützt." >&2; exit 1; }
command -v apt-get >/dev/null || { echo "Nur Debian/Ubuntu (apt) wird unterstützt." >&2; exit 1; }

need=""
for t in curl ssh-keygen python3; do command -v "$t" >/dev/null || need="$need $t"; done
if [ -n "$need" ]; then
  echo "Installiere Hilfsprogramme …"
  apt-get update -qq
  pkgs=""
  for t in $need; do case $t in ssh-keygen) pkgs="$pkgs openssh-client";; *) pkgs="$pkgs $t";; esac; done
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq $pkgs
fi

W=$(mktemp -d); trap 'rm -rf "$W"' EXIT
echo "Lade Katalog …"
NOW=$(date +%s)
curl -fsSL "$BASE/catalog.json?t=$NOW" -o "$W/catalog.json"
curl -fsSL "$BASE/catalog.json.sig?t=$NOW" -o "$W/catalog.json.sig"
echo "alerion $KEY" > "$W/signers"
ssh-keygen -Y verify -f "$W/signers" -I alerion -n alerion-hub-catalog \
  -s "$W/catalog.json.sig" < "$W/catalog.json" >/dev/null \
  || { echo "Signatur des Katalogs ungültig – Abbruch." >&2; exit 1; }

set -- $(python3 -c '
import json,sys
c=json.load(open(sys.argv[1]))
r=[p for p in c["products"] if p["id"]=="alerion-hub"][0]["releases"]["linux-x86_64"]
print(r["version"], r["url"], r["sha256"])' "$W/catalog.json")
VER=$1 URL=$2 SUM=$3
case "$URL" in https://github.com/P3rc1v4l/*) ;; *) echo "Unerwartete Adresse: $URL" >&2; exit 1;; esac

echo "Lade Alerion Hub $VER …"
curl -fSL --progress-bar "$URL" -o "$W/alerion-hub.deb"
echo "$SUM  $W/alerion-hub.deb" | sha256sum -c --quiet - \
  || { echo "Prüfsumme falsch – Abbruch." >&2; exit 1; }

echo "Installiere …"
apt-get update -qq || true
DEBIAN_FRONTEND=noninteractive apt-get install -y "$W/alerion-hub.deb"
echo "Fertig: Alerion Hub $VER ist installiert. Im App-Menü unter „Alerion Hub“."
