# Lab timeline

| Date | Result |
| --- | --- |
| 2026-09-30 | Verified local production-test exposure and root SSH on stock 1.2.12 |
| 2026-09-30 | Go binary crashed; freestanding MIPS-I C probe worked |
| 2026-09-30 | Traced musl startup fault to `rdhwr`; corrected an earlier `ll/sc` misdiagnosis |
| 2026-10-01 | Booted Linux 6.18.54 after kernel-only installation over SSH |
| 2026-10-01 | Verified WireGuard handshake and 5/5 encrypted pings |
| 2026-10-02 | Benchmarked crypto flags and inline WireGuard changes, including regressions |
| 2026-10-03 | Measured the newer single-CPU NAPI variant; see the WireGuard repository |

This is one board and a bounded set of experiments, not a compatibility matrix. Full vendor functionality, long-term stability and current firmware remediation status are not established here. Raw device responses and unredacted lab logs stay private.
