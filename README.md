# SilverCrest SGWZ 1 A1: RTL8196E research

I wanted to see how far I could get with a stock SilverCrest Zigbee gateway without opening the case: root access, a newer Linux kernel, and native software on its Lexra CPU.

These are the results from **one board**, tested in September–October 2026. Some experiments failed. Those are included too.

- **Root over LAN:** confirmed on stock Tuya firmware 1.2.12. I combined a known device-password relationship from Paul Banks's work with an exposed Tuya production-test interface. No UART or password guessing.
- **Linux without UART:** booted Linux 6.18.54 after an authenticated SSH kernel-only update. The original bootloader, root filesystem and data partitions stayed in place.
- **MIPS/Lexra userspace:** compiled and ran C code, diagnosed an unexpected musl `rdhwr` instruction fault, and tested a narrowly scoped single-threaded patch.
- **WireGuard:** the kernel patches and A/B measurements have their own repository: [rtl8196e-wireguard](https://github.com/pasichDev/rtl8196e-wireguard).

This is my engineering notebook, trimmed for public release. It is **not** a complete firmware replacement or a turnkey root tool.

## Tested hardware

| | Board |
| --- | --- |
| Device | SilverCrest Smart Home Gateway SGWZ 1 A1 |
| SoC / CPU | Realtek RTL8196E / Lexra RLX4181, about 400 MHz |
| Memory | 32 MiB RAM; 16 MiB flash |
| ABI | ELF32 big-endian, MIPS-I class, soft-float |
| Stock | Tuya-based firmware 1.2.12; Linux 3.10.90 |
| Experiment | Linux 6.18.54-rtl8196e-v4.7.0 |

## Read the notes

| Subject | Notes |
| --- | --- |
| Root access without opening the case | [The two research paths and what I actually verified](docs/root-access.md) |
| Kernel-only upgrade | [Building, installing and booting Linux over SSH](docs/uartless-kernel.md) |
| Native programs | [MIPS toolchain, libc and instruction compatibility](docs/mips-userspace.md) |
| Patches | [What helped, what made things worse](docs/patches.md) |
| Flash and baseline | [Hardware notes](docs/hardware.md) |
| Chronology | [Experiment timeline](docs/lab-notes.md) |
| Firmware releases | [Artifact policy](docs/artifacts.md) |

## A few results

On **1 October 2026**, a 1,523,712-byte kernel image booted in the stock 1,966,080-byte kernel partition. SSH returned after reboot. WireGuard loaded, completed a handshake and returned **5 of 5 encrypted pings**. The board's vendor Zigbee/Tuya services were *not* automatically started by the experimental bootstrap. This is not stock feature parity.

In the separate [WireGuard project](https://github.com/pasichDev/rtl8196e-wireguard), a measured single-core NAPI crypto change increased median TCP throughput **to** the board from 9.44 to **18.84 Mbit/s** on the same wired bench. That repo has the patch series and raw results; I don't duplicate it here.

## Boundaries

No root passwords, provisioning keys, raw device responses, SSH identity files, full flash dumps, private C/Go home-security code, local network captures or prebuilt firmware images are published. The observed security issue was reported to Tuya; see [SECURITY.md](SECURITY.md) for the brief disclosure note.

The initial access is **not claimed as a new password discovery**. The relationship between provisioning data and the root password was described by [Paul Banks](https://paulbanks.org/projects/lidl-zigbee/). The Linux port/toolchain foundation is [jnilo1/rtl8196e-gateway](https://github.com/jnilo1/rtl8196e-gateway); Tuya documents its [production-test interface](https://developer.tuya.com/en/docs/iot/tuya-gateway-extension-sdk-production-test-description?id=K9dudr9liqkgc). My own work here is the tested combination, kernel-only upgrade, compatibility experiments and linked kernel optimizations.

**Andrii Pasichnyk, [@pasichDev](https://github.com/pasichDev)**. Independent research on personally owned hardware; not affiliated with Lidl, SilverCrest, Realtek or Tuya.

**License:** MIT for original material here. Linux-derived work in the linked repository and upstream projects retains its original license. See [LICENSE](LICENSE) and [THIRD_PARTY.md](THIRD_PARTY.md).
