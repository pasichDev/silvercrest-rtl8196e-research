# Root access: combining two existing findings

**Observed:** 30 September 2026 on one SGWZ 1 A1, stock firmware 1.2.12. No UART, password guessing or firmware changes were needed for the access test.

## First piece: device password research

[Paul Banks](https://paulbanks.org/projects/lidl-zigbee/) previously described how a device-specific Tuya provisioning value relates to the gateway's root SSH password. That relationship is not my discovery.

## Second piece: local production-test service

On my unit, a Tuya production-test service was reachable on **TCP 12130**. Its configuration-reading function returned provisioning data without authenticating the caller. This is part of the class of functionality described in [Tuya's production-test documentation](https://developer.tuya.com/en/docs/iot/tuya-gateway-extension-sdk-production-test-description?id=K9dudr9liqkgc).

## What I verified

I combined the local response with the previously documented password relationship, then authenticated once to Dropbear SSH on **TCP 2333**. The shell reported **UID 0**. The test used an owner's device on an owner's LAN. I did not probe unrelated hardware or Tuya cloud infrastructure.

The significant finding was **LAN disclosure of credential-related material leading to administrative access**. It is not a break of the SSH protocol. A single affected firmware build does not establish the status of every SilverCrest gateway or a current fixed version.

## Vendor response

Tuya subsequently replied that the issue had been **fixed**, according to my correspondence. This updates the disclosure status, but I have not yet documented the exact corrected firmware build or independently retested it. A fix reported by the vendor does not establish that every previously shipped gateway is patched.

The exact request frames, raw replies and automation remain in my private lab record. Neither passwords nor device identifiers are included here. I intend to publish a separate, sanitized reproduction note once the affected and corrected firmware versions and disclosure dates are recorded.
