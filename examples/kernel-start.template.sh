#!/bin/sh
# SPDX-License-Identifier: MIT
# Experimental bootstrap for SGWZ 1 A1 + stock rootfs and Linux 6.18.
# MAKE A LOCAL COPY, replace EVERY placeholder, check syntax, and NEVER
# commit the populated copy. Vendor Zigbee services are not started.
set -eu

LAN_MAC='REPLACE_WITH_YOUR_OWN_MAC'
LAN_IP='REPLACE_WITH_YOUR_OWN_IP'
LAN_MASK='REPLACE_WITH_YOUR_NETMASK'
LAN_GW='REPLACE_WITH_YOUR_GATEWAY'
LAN_DNS='REPLACE_WITH_YOUR_DNS'

for value in "$LAN_MAC" "$LAN_IP" "$LAN_MASK" "$LAN_GW" "$LAN_DNS"; do
  case "$value" in REPLACE_*|'') echo 'Set all device-specific network values' >&2; exit 1;; esac
done

mount -t devpts devpts /dev/pts || true
mkdir -p /dev/net
[ -c /dev/net/tun ] || mknod /dev/net/tun c 10 200
ifconfig lo 127.0.0.1 up
ifconfig eth0 hw ether "$LAN_MAC"
ifconfig eth0 "$LAN_IP" netmask "$LAN_MASK" up
route add default gw "$LAN_GW" eth0 || true
echo "nameserver $LAN_DNS" > /var/resolv.conf

# Remain in the foreground so stock rcS does not resume old interfaces.
while :; do
  /tuya/tuyadropbear -F -E -P /var/run/dropbear.tuya.pid -p 2333 -K 300 -T 1 || true
  sleep 3
done
