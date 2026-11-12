# Manual 1: root access on the SilverCrest SGWZ 1 A1

**Tested:** 30 September 2026, SilverCrest SGWZ 1 A1, stock Tuya firmware 1.2.12 and Linux 3.10.90. I used one personally owned gateway on my LAN. No UART, password guessing or firmware modification was needed.

This was a combination of **two known observations**, not a new root-password algorithm.

## The two parts

**1. Paul Banks's research.** [Paul Banks](https://paulbanks.org/projects/lidl-zigbee/) documented the relationship between a device-specific Tuya provisioning value and the gateway's SSH root password.

**2. Tuya's production-test service.** My stock gateway exposed TCP **12130**. The configuration-read operation returned the device's provisioning fields without authenticating the LAN client. Tuya [documents this production-test protocol](https://developer.tuya.com/en/docs/iot/tuya-gateway-extension-sdk-production-test-description?id=K9dudr9liqkgc).

Putting those observations together gave a root credential that the existing Dropbear SSH server on TCP **2333** accepted.

## Reproducing the observations on an owned gateway

Work only on devices you own or have explicit permission to test. Replace the example address with your own device's address:

~~~sh
export GATEWAY_IP="192.0.2.10"  # replace with the address of YOUR gateway
nc -vz -w 3 "$GATEWAY_IP" 12130
nc -vz -w 3 "$GATEWAY_IP" 2333
~~~

The tests on my firmware identified TCP 12130 as Tuya's production-test interface and TCP 2333 as Dropbear 2018.76. TCP 6668 was also present, but was not part of the root chain. This is not an exhaustive port scan or a claim about other product variants.

### The read-only requests

The manufacturing/test protocol distinguishes firmware version and configuration queries:

| Request | Purpose | Result on my board |
| --- | --- | --- |
| \`0x01\` | Version read | Reported firmware 1.2.12 |
| \`0x02\` | Child firmware version | Returned a negative result |
| \`0x04\` | Configuration read | Returned JSON with device-specific provisioning data |

I sent **read-only** operations. No factory-write request, firmware update or cloud endpoint was involved. The configuration included a field named \`auzkey\`; the unredacted response must be handled as a secret.

The response structure can be inspected using the [documented vendor protocol](https://developer.tuya.com/en/docs/iot/tuya-gateway-extension-sdk-production-test-description?id=K9dudr9liqkgc). I am not publishing a scanner or an automated credential extractor. Do not paste provisioning responses, UUIDs or derived passwords into an issue, log or Git repository.

### Combining the results

On the tested stock firmware, the **last eight characters of the device-specific \`auzkey\`** matched the root-password relationship described in the earlier research. I tried the credential once against the existing SSH service and authenticated successfully. That is a device-specific password, **not** a reusable default password.

With credentials from your authorized device, confirm the session using read-only commands:

~~~sh
ssh -p 2333 "root@$GATEWAY_IP" 'cat /proc/self/status | grep Uid'
ssh -p 2333 "root@$GATEWAY_IP" 'cat /proc/version; cat /proc/mtd'
~~~

The status on my gateway reported \`Uid: 0 0 0 0\`. Its BusyBox build lacked standalone \`id\` and \`uname\`, so the \`/proc\` interface was the direct evidence. Verify the SSH host key by a trusted method rather than disabling host-key checking.

## What this finding does and does not show

The vulnerable boundary was a **LAN-accessible configuration read returning credential-related material**. The SSH protocol itself was not broken. The test proves an authenticated root login on the one firmware version above; it does not establish cloud exposure, universal impact or the state of updated devices.

I reported this finding to Tuya; their reply said it had already been addressed. I did not independently retest an updated firmware build.

The next step after obtaining authorized root is not automatic flashing. For that experiment see [Manual 2: build and kernel-only SSH installation](02-kernel-build-and-flash.md), with backups and recovery requirements.

**Credits:** Paul Banks for the password relationship; Tuya's documentation for the manufacturing/test protocol; my own test for the combined, observed LAN access chain.
