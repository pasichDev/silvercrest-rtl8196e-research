# Booting Linux 6.18.54 without UART

On **1 October 2026** I booted a newly compiled kernel on my SGWZ 1 A1 using the existing authenticated root SSH connection. No disassembly or UART was used for installation.

This was a **kernel-only** change. The original bootloader, SquashFS rootfs, provisioning label and JFFS2 data stayed intact. It is not a complete replacement firmware.

## Build source

I used [jnilo1/rtl8196e-gateway](https://github.com/jnilo1/rtl8196e-gateway) at commit `30eb5e5b9ee334d2c6d76812acd4a6cdf2923423` with the configuration and patch tooling maintained in [rtl8196e-wireguard](https://github.com/pasichDev/rtl8196e-wireguard).

With a compatible Lexra cross-compiler already installed, a host-side build looks like:

```sh
git clone https://github.com/jnilo1/rtl8196e-gateway.git port
git -C port checkout --detach 30eb5e5b9ee334d2c6d76812acd4a6cdf2923423
git clone https://github.com/pasichDev/rtl8196e-wireguard.git wireguard
cd wireguard
LABGW_CRYPTO_O2=1 LABGW_CRYPTO_TUNE=1 LABGW_WG_NAPI=1 \
  ./build-wireguard-kernel.sh "$PWD/../port" clean
```

That command **builds** an image; it does not flash a device. See the linked project's requirements for the toolchain.

## Checks that mattered

1. Verified the tested board's MTD map, erase geometry, bootloader behavior and the original kernel hash.
2. Verified a complete off-device flash backup.
3. Inspected the compiled DTB, image header, load and entry addresses, partition sizes and expanded memory requirements.
4. Confirmed that the new kernel could use the existing rootfs while bringing up Ethernet and authenticated SSH.
5. Transferred the image into RAM, not a flash filesystem. The board-specific updater supported a non-writing preflight, required the expected original partition digest and targeted **only `mtd1`**. It verified the written data and **did not reboot automatically**.
6. Rebooted separately, then checked the kernel version, flash map, SSH access and WireGuard runtime.

The recorded image was **1,523,712 bytes** inside a **1,966,080-byte** kernel partition. The new kernel reported `6.18.54-rtl8196e-v4.7.0`; WireGuard loaded, completed a handshake and returned **5/5 encrypted test pings**.

## What remained broken or untested

The experimental startup restored Ethernet and SSH. It **did not automatically launch Tuya/Zigbee services**, so don't claim full stock functionality or a supported firmware upgrade. A successful install *without* UART does not mean recovery *without* UART. Power loss or a non-booting image can still require physical rescue.

The original updater and bootstrap were board-specific and contain local configuration assumptions. I haven't published them as generic flash scripts. Do not replace those checks with a copied `dd` or `flash_erase` command.
