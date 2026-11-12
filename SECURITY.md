# Disclosure and security notes

**Tested:** 30 September 2026, one personally owned SilverCrest SGWZ 1 A1 running stock Tuya firmware 1.2.12, on my private LAN.

I confirmed that an unauthenticated production-test configuration response could be combined with an already public password relationship to obtain authenticated root SSH access. This was a local configuration disclosure and credential design problem, not an SSH vulnerability.

A private technical report was prepared for the vendor. The exact vendor case number, confirmation date and fixed firmware release are **not independently verified in the public records here**. I therefore make no CVE, reward or universal-remediation claim.

Until those details are checked, this repository does not ship raw production-test request frames, credential extraction scripts or an automated root-login chain. It contains enough information to understand the finding and its provenance without redistributing device secrets.

Please report additional platform vulnerabilities through the vendor's security channel, not a public GitHub issue containing keys, firmware dumps or identifiable device responses. Research here was limited to owned hardware; do not test other people's networks without permission.
