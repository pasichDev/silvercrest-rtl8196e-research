# Board and flash layout

This table comes from my **SGWZ 1 A1**. Check the real partition table on your own hardware before even considering a firmware write.

| MTD | Start | Size | Contents |
| --- | --- | --- | --- |
| `mtd0` | `0x000000` | `0x020000` | boot + config |
| `mtd1` | `0x020000` | `0x1e0000` | Linux kernel |
| `mtd2` | `0x200000` | `0x200000` | SquashFS rootfs |
| `mtd3` | `0x400000` | `0x020000` | Tuya provisioning label |
| `mtd4` | `0x420000` | `0xbe0000` | JFFS2 data |

RTL8196E / Lexra RLX4181, roughly 400 MHz; 32 MiB RAM and 16 MiB flash. The stock image ran Linux 3.10.90. Its userspace was big-endian ELF32, MIPS-I class and soft-float.

The complete 16 MiB flash backup was saved off-device before kernel work. It is not public because it includes device-specific provisioning and other secrets.

The stock BusyBox omitted several utilities normally taken for granted. The clock initially started in 1970, and some newer MIPS instructions did not run. These details affected software portability much more than the nominal CPU frequency.
