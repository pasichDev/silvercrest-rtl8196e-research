# Native code on Lexra RLX4181

The RTL8196E is not a generic modern MIPS target. My stock gateway used big-endian ELF32/MIPS-I-class userspace, soft-float, Linux 3.10.90 and very little spare memory.

A small Go hello-world build crashed with exit 139; I did **not** prove why. A 4 KB freestanding C probe ran. A larger static C program built with Lexra-patched GCC and musl failed with `SIGILL` before it could do useful work.

The culprit was musl 1.2.6 reading a thread pointer via **`rdhwr`**. An isolated board test showed that `rdhwr` failed; `lwl/lwr`, `swl/swr`, `ll/sc` and `sync` worked in that test. My earlier suspicion that `ll/sc` was faulty was wrong.

## Toolchain and libc

Start with the Lexra-patched GCC tooling in [jnilo1/rtl8196e-gateway](https://github.com/jnilo1/rtl8196e-gateway). The included [musl patch 951](../patches/musl/951-stock-kernel-no-rdhwr.patch) keeps the thread pointer in a global variable for the tested `__mlx4380` case.

**That patch is single-threaded only.** It does not provide correct thread-local storage to multiple threads. It is a compatibility experiment, not a universal musl fix.

## Compile a tiny program

With the compatible cross-toolchain and patched libc on `PATH`, from the repository root:

```sh
mips-lexra-linux-musl-gcc -Os -static -o hello-mips examples/hello.c
file hello-mips
readelf -h hello-mips
mips-lexra-linux-musl-objdump -d hello-mips > hello-mips.disasm
```

Check endianness, ABI and the emitted instructions. Running under generic `qemu-mips` helps catch basic bugs, but QEMU success is not proof of Lexra instruction compatibility. Test on an authorized board.

## Practical rules

- Use explicit byte-order conversions for network fields; don't reinterpret wire buffers as native integers.
- Cap allocations and track peak RSS.
- Use a monotonic clock for intervals; the stock wall clock began in 1970.
- Keep steady-state logs and caches in RAM, not NOR flash.
- Prove libc/ISA startup with the smallest program first.

The separate home-security software, including its Go/C implementations, is not part of this publication.
