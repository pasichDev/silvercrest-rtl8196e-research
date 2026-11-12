# Patch notes

## musl 1.2.6

The included `951-stock-kernel-no-rdhwr.patch` changes musl's MIPS thread-pointer access on the tested Lexra target. It avoided an observed startup `SIGILL` in a **single-threaded** program. It is **not** correct for pthread-based programs.

I have **not** included `950-stock-kernel-no-llsc.patch`. That came from an initial incorrect diagnosis. Later tests showed `ll/sc` and `sync` worked; replacing atomics with ordinary loads/stores is not a safe general fix.

## Linux and WireGuard

The complete patch series belongs in [pasichDev/rtl8196e-wireguard](https://github.com/pasichDev/rtl8196e-wireguard), including its GPL notices and measurement logs. Highlights:

| Patch | Finding |
| --- | --- |
| 0001 | Preserve stock flash layout |
| 0002 / 0003 | Optimize generic ChaCha compiler flags |
| 0004 | One-worker attempt: **slower** |
| 0005 / 0007 | Earlier inline variant, superseded |
| 0006 | Byte-swap change: **slower** in A/B tests |
| 0008 | Single-CPU NAPI crypto path |

On the same wired board-as-endpoint test, 0008 moved median TCP toward the board from **9.44 to 18.84 Mbit/s** and outbound from **8.18 to 13.79 Mbit/s**. These numbers depend on board, kernel and test setup. See that repo for CSV results and test conditions.
