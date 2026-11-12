#!/bin/sh
# SPDX-License-Identifier: MIT
# Alters stock startup on an OWNED SGWZ 1 A1. Review before use.
set -eu
base=/tuya/rtl8196e-kernel
current=/tuya/tuya_net_start.sh
original="$base/stock-net-start.sh"
new="$base/net-start.new"
hook="$base/kernel-start.sh"

grep -q 'Linux version 3.10.90 ' /proc/version
[ -f "$current" ]
[ -x "$hook" ]
sh -n "$hook"

if grep -q "$hook" "$current"; then
  echo 'Kernel boot hook already installed'
  exit 0
fi

[ ! -e "$original" ] || { echo 'Startup backup already exists; review before changing anything' >&2; exit 1; }
mkdir -p "$base"
cp -p "$current" "$original"
{
  echo '#!/bin/sh'
  echo 'case "$(cat /proc/sys/kernel/osrelease)" in'
  echo "  6.18.54*) exec $hook ;;"
  echo 'esac'
  cat "$original"
} > "$new"
sh -n "$new"
chmod 755 "$new"
mv "$new" "$current"
echo 'Startup hook installed, with original stock script saved.'
