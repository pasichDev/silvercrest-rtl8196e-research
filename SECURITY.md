# Disclosure and security notes

**Tested:** 30 September 2026, one personally owned SilverCrest SGWZ 1 A1 running stock Tuya firmware 1.2.12, on my private LAN.

I confirmed that an unauthenticated production-test configuration response could be combined with an already public password relationship to obtain authenticated root SSH access. This was a local configuration disclosure and credential design problem, not an SSH vulnerability.

A private technical report was prepared for Tuya. **Tuya replied that the issue had already been resolved some time before their response**, according to my correspondence. This is Tuya's description of the remediation timeline, not a claim that my report caused the fix. As of 12 November 2026, I have not recorded the exact fixed firmware version, affected-version range or an independent retest in this public repository. The vendor's statement is not presented as proof that every deployed device has been updated. No CVE, bounty payment or universal-remediation claim is made.

Tuya's response gives context for this public technical write-up, but I am keeping raw production-test request frames, credential extraction scripts and automated root-login tooling out of this initial release until the fixed release and disclosure dates are documented. It contains enough information to understand the finding and its provenance without redistributing device secrets.

Please report additional platform vulnerabilities through the vendor's security channel, not a public GitHub issue containing keys, firmware dumps or identifiable device responses. Research here was limited to owned hardware; do not test other people's networks without permission.
