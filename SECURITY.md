# Disclosure and security notes

**Tested:** 30 September 2026, one personally owned SilverCrest SGWZ 1 A1 running stock Tuya firmware 1.2.12, on my private LAN.

I confirmed that an unauthenticated production-test configuration response could be combined with an already public password relationship to obtain authenticated root SSH access. This was a local configuration disclosure and credential design problem, not an SSH vulnerability.

I reported the finding to Tuya. They replied that it had already been addressed. I have not independently tested an updated device, so this repository only documents the behavior observed on my firmware.

Raw production-test responses, device credentials and automated root-login tooling are not published.

Please report additional platform vulnerabilities through the vendor's security channel, not a public GitHub issue containing keys, firmware dumps or identifiable device responses. Research here was limited to owned hardware; do not test other people's networks without permission.
