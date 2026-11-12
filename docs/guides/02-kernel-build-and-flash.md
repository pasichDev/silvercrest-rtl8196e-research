# Manual 2: build and install Linux 6.18 without UART

**Tested on:** SilverCrest SGWZ 1 A1 (Realtek RTL8196E / Lexra RLX4181) on 1 October 2026.  
**Result:** a new Linux `6.18.54-rtl8196e-v4.7.0` kernel booted after an authenticated SSH update. The stock bootloader, SquashFS rootfs, provisioning and JFFS2 partitions remained.

**Warning:** This is a destructive kernel-partition update, *not* a full vendor firmware release. A failed boot can still require opening the case and using UART to recover. Do not flash another revision by copying commands and assuming it has the same layout. No full-flash image is distributed here.

## 1. Hardware and prerequisites

The test board has 32 MiB RAM and 16 MiB NOR flash. The actual partition map was:

| MTD | Offset | Size | Purpose |
| --- | --- | --- | --- |
| `mtd0` | `0x000000` | `0x020000` | Bootloader/config |
| `mtd1` | `0x020000` | `0x1e0000` | Kernel: 1,966,080 bytes |
| `mtd2` | `0x200000` | `0x200000` | Stock rootfs |
| `mtd3` | `0x400000` | `0x020000` | Provisioning label |
| `mtd4` | `0x420000` | `0xbe0000` | JFFS2 data |

You need a Linux build host, Git, standard build tools, the **Lexra-compatible** `mips-lexra-linux-musl-*` toolchain, existing *authorized* root SSH access to the device, a verified complete off-device backup and a UART recovery plan.

The base toolchain and platform port are by [jnilo1](https://github.com/jnilo1/rtl8196e-gateway). The build script, kernel patch series and benchmarks are in [rtl8196e-wireguard](https://github.com/pasichDev/rtl8196e-wireguard). Do not use a generic MIPS cross-compiler for this board.

## 2. Build the kernel on Linux

In a new work directory:

~~~sh
mips-lexra-linux-musl-gcc --version

git clone https://github.com/jnilo1/rtl8196e-gateway.git rtl8196e-port
git -C rtl8196e-port checkout --detach 30eb5e5b9ee334d2c6d76812acd4a6cdf2923423

git clone https://github.com/pasichDev/rtl8196e-wireguard.git

LABGW_CRYPTO_O2=1 LABGW_CRYPTO_TUNE=1 LABGW_WG_NAPI=1 \
  ./rtl8196e-wireguard/build-wireguard-kernel.sh "$PWD/rtl8196e-port" clean
~~~

This builds Linux 6.18.54 against the pinned upstream port revision. The options select the later, measured single-CPU NAPI WireGuard variant. The build script enables the necessary WireGuard, TUN, routing, legacy iptables and NAT features, preserves the stock layout through patch `0001`, uses `IMEM_POLICY_DISABLE=1` and checks the generated image header. It does **not** write to a device.

The expected output path is:

~~~text
rtl8196e-port/3-Main-SoC-Realtek-RTL8196E/32-Kernel/kernel-img/lidl/kernel-6.18.img
~~~

From the original work directory:

~~~sh
IMAGE="$PWD/rtl8196e-port/3-Main-SoC-Realtek-RTL8196E/32-Kernel/kernel-img/lidl/kernel-6.18.img"
test -f "$IMAGE"
wc -c < "$IMAGE"
sha256sum "$IMAGE"
md5sum "$IMAGE"
~~~

The **first** kernel-only image I booted on 1 October 2026 had size **1,523,712 bytes** and SHA-256 `0c1a84ad2b948cc1faac779919528d041a24957bc3b7561e95d21ff272ca5f1b`. The NAPI variant was built later and has a **different digest**. Build timestamps and toolchain variations can change output bytes. Never use the first image's hash to validate a newly compiled image.

### Preflash validation

The builder checks the Realtek `cs6c` format, flash offset `0x20000`, image length, payload checksum and required kernel options. Independently verify the **compiled** device tree still retains all five stock MTD partitions and the uncompressed zboot memory footprint fits into RAM. The first successfully booted image loaded at `0x805a0000`; this is an observation, not a universal address.

## 3. Make and verify an off-device flash backup

Set your actual device address:

~~~sh
export DEVICE_IP="192.0.2.10" # REPLACE with your own device
export SSH_PORT=2333

ssh -p "$SSH_PORT" "root@$DEVICE_IP" \
  'cat /proc/version; cat /proc/mtd; cat /sys/class/mtd/mtd1/size; cat /sys/class/mtd/mtd1/erasesize'
~~~

On the tested board the `mtd1` size was **1,966,080** bytes and erase size **65,536** bytes. Stop if any values differ.

Read the five partitions to the **host**, without copying the backup into the device's limited RAM:

~~~sh
umask 077
ssh -p "$SSH_PORT" "root@$DEVICE_IP" \
  'for n in 0 1 2 3 4; do dd if=/dev/mtd$n bs=4096; done' \
  > sgwz-private-full-flash.bin

wc -c sgwz-private-full-flash.bin
sha256sum sgwz-private-full-flash.bin
~~~

For the exact table above, the output must contain **16,777,216 bytes**. A matching length alone is not sufficient: verify the backup can be read and the partition hashes agree with the live device. Keep this backup private and offline. It can include provisioning material, identifiers and passwords.

## 4. Prepare network/SSH startup for the new kernel

This is **mandatory** for the stock-rootfs hybrid tested here. The original Tuya scripts assume Linux 3.10 networking and are not suitable as-is for the new kernel. My working bootstrap started Ethernet and Dropbear SSH, deliberately **not** the stock Tuya/Zigbee services.

Use the supplied [network bootstrap template](../../examples/kernel-start.template.sh) as a reference. Its MAC, IPv4, netmask, gateway and DNS are intentionally placeholders. Make a local copy, fill the actual settings and **do not commit that populated copy**. The script must keep Dropbear alive and prevent the old vendor boot sequence from reconfiguring obsolete interfaces.

Stage the edited script as `/tuya/rtl8196e-kernel/kernel-start.sh` and make it executable. Run `sh -n` and inspect it for correct network parameters. Review [prepare-kernel-start.sh](../../scripts/prepare-kernel-start.sh) before using it to preserve the stock `/tuya/tuya_net_start.sh` and install a version-dependent wrapper.

**If you cannot verify that your SSH path will return on the new kernel, stop.** A kernel can boot successfully and still leave the device unreachable.

## 5. Stage and check the kernel in RAM

The provided [installer](../../scripts/install-kernel.sh) follows the tested board-only procedure: reject unexpected MTD geometry, check the old partition digest, stage a backup in RAM, write only `mtd1` and check readback. It requires a **separate explicit `--write`** request; there is no automatic reboot.

Once you have installed and reviewed the network boot hook:

~~~sh
ssh -p "$SSH_PORT" "root@$DEVICE_IP" \
  'cat > /var/rtl8196e-kernel.img' < "$IMAGE"

ssh -p "$SSH_PORT" "root@$DEVICE_IP" \
  'cat > /var/rtl8196e-install-kernel.sh' < scripts/install-kernel.sh

NEW_MD5="$(md5sum "$IMAGE" | awk '{print $1}')"
OLD_MD5="$(ssh -p "$SSH_PORT" "root@$DEVICE_IP" 'md5sum /dev/mtd1' | awk '{print $1}')"

ssh -p "$SSH_PORT" "root@$DEVICE_IP" \
  'md5sum /var/rtl8196e-kernel.img'
~~~

Compare the staged image's digest to `NEW_MD5`. Also compare the current `mtd1` digest against your **off-device backup**, not only against the device itself. Check there is enough free RAM for the staged image and a second ~1.9 MiB kernel backup.

The following is non-writing preflight:

~~~sh
ssh -p "$SSH_PORT" "root@$DEVICE_IP" \
  "sh /var/rtl8196e-install-kernel.sh --check '$NEW_MD5' '$OLD_MD5'"
~~~

Only after independently reviewing the image, checks, startup hook, backup and UART recovery path is the separate flash operation appropriate:

~~~sh
# DESTRUCTIVE. Writes /dev/mtd1 on the tested board layout only.
ssh -p "$SSH_PORT" "root@$DEVICE_IP" \
  "sh /var/rtl8196e-install-kernel.sh --write '$NEW_MD5' '$OLD_MD5'"
~~~

The helper attempts best-effort same-session rollback if writing fails. It **cannot** recover after power loss or a failed boot. The old BusyBox's MD5 is used for **transfer/readback equality**, not for image publisher authenticity: verify the source and SHA-256 on the host first.

## 6. Reboot separately and verify

The flash installer **does not reboot**. After a verified write, reboot as a separate operator decision:

~~~sh
ssh -p "$SSH_PORT" "root@$DEVICE_IP" 'reboot'
# After the board comes up:
ssh -p "$SSH_PORT" "root@$DEVICE_IP" \
  'cat /proc/version; cat /proc/mtd; cat /proc/misc'
~~~

My board reported `6.18.54-rtl8196e-v4.7.0`, retained the five MTD partitions, loaded WireGuard and returned **5/5 encrypted ICMP replies** through a test tunnel. This is a kernel boot and WireGuard interoperability check, **not** proof of full stock functionality.

If SSH never returns, keep the private off-device backup and use physical recovery. Do not keep trying remote flash commands against an unreachable gateway.

## Known limitations and source

- One tested board. Other revisions, IPv6, long-term reliability and complete Tuya/Zigbee compatibility are not verified.
- The experimental startup does **not** launch the stock Zigbee services.
- No device-specific flash dump, provisioning key or binary firmware is included here.
- Kernel patches and their GPL license remain in [rtl8196e-wireguard](https://github.com/pasichDev/rtl8196e-wireguard); original documentation and helper scripts here are MIT.

See [the original dated experiment](../uartless-kernel.md) for the engineering observations and [Manual 1](01-root-access.md) for the historical root-access finding.
