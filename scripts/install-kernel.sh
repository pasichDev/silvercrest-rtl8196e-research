#!/bin/sh
# SPDX-License-Identifier: MIT
# Experimental SGWZ 1 A1 kernel-only updater. Only target: /dev/mtd1.
# --check is read-only; --write ERASES flash. No auto-reboot.
# A failed boot can require UART recovery and an off-device backup.
set -eu
mode=$1
expected=$2
old_expected=$3
image=/var/rtl8196e-kernel.img
backup=/var/rtl8196e-kernel-before.bin
device=/dev/mtd1
hook=/tuya/rtl8196e-kernel/kernel-start.sh
startup=/tuya/tuya_net_start.sh

case "$mode" in --check|--write) ;; *) echo 'usage: install-kernel.sh --check|--write NEW_MD5 OLD_MTD1_MD5' >&2; exit 2;; esac
case "$expected$old_expected" in *[!0-9a-f]*) echo 'Invalid digest' >&2; exit 2;; esac
[ "$(printf %s "$expected" | wc -c)" -eq 32 ]
[ "$(printf %s "$old_expected" | wc -c)" -eq 32 ]
[ ! -e /var/rtl8196e-kernel-written ]

grep -q -e 'Linux version 3.10.90 ' -e 'Linux version 6.18.54-rtl8196e-' /proc/version
grep -q '^mtd1: 001e0000 00010000 "linux"$' /proc/mtd
[ "$(cat /sys/class/mtd/mtd1/size)" -eq 1966080 ]
[ "$(cat /sys/class/mtd/mtd1/erasesize)" -eq 65536 ]
[ -c "$device" ] && [ -f "$image" ] && [ -x "$hook" ]
grep -q "$hook" "$startup"
sh -n "$hook"
sh -n "$startup"

size=$(wc -c < "$image")
[ "$size" -ge 4096 ] && [ "$size" -le 1966080 ]
[ "$((size % 4096))" -eq 0 ]

actual=$(md5sum "$image" | awk '{print $1}')
old_actual=$(md5sum "$device" | awk '{print $1}')
[ "$actual" = "$expected" ]
[ "$old_actual" = "$old_expected" ]
echo "Checked $size bytes; would update $device only."
[ "$mode" = --write ] || exit 0

# Keep a second copy in RAM for same-session, best-effort recovery.
# Not safe against loss of power or an unbootable new kernel.
dd if="$device" of="$backup" bs=65536 count=30
saved=$(md5sum "$backup" | awk '{print $1}')
[ "$saved" = "$old_expected" ]
write_started=0

restore_on_error() {
  result=$?
  trap - EXIT HUP INT TERM
  if [ "$write_started" = 1 ]; then
    echo 'Write failed. Attempting old kernel restore. DO NOT REBOOT.' >&2
    if /bin/flash_erase -q "$device" 0 30 && dd if="$backup" of="$device" bs=4096; then
      restored=$(md5sum "$device" | awk '{print $1}')
      if [ "$restored" = "$old_expected" ]; then
        echo 'Original partition restored and verified' >&2
      else
        echo 'Restoration digest mismatch. Keep power ON' >&2
      fi
    else
      echo 'Restoration failed. Keep power ON' >&2
    fi
  fi
  [ "$result" -ne 0 ] || result=1
  exit "$result"
}
trap restore_on_error EXIT HUP INT TERM

write_started=1
/bin/flash_erase -q "$device" 0 30
dd if="$image" of="$device" bs=4096
readback=$(dd if="$device" bs=4096 count="$((size / 4096))" | md5sum | awk '{print $1}')
[ "$readback" = "$expected" ]
write_started=0
trap - EXIT HUP INT TERM
echo "$expected" > /var/rtl8196e-kernel-written
echo 'Kernel write verified; reboot NOT performed.'
