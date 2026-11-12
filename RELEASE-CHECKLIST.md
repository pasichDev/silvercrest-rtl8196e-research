# Before merging or tagging

- [x] New public repository; no imported private Git history
- [x] No private home-security C/Go source or antivirus work
- [x] No credentials, factory secrets, SSH host identities or flash backups
- [x] Prior researchers and upstream code credited
- [x] Original work licensed; kernel-derived files left with their upstream licenses
- [x] Single-board test limits and negative findings documented
- [x] Researcher received a vendor response stating that the issue was fixed
- [ ] Record vendor report ID, response date, affected firmware versions and corrected build
- [ ] Independently verify remediation on the corrected firmware if hardware/update access permits
- [ ] Review exact root-access reproduction material separately if disclosure permits
- [ ] Re-run the toolchain build from a clean host before tagging a tested release
- [ ] Audit image provenance and component licenses before any binary upload

Do **not** merge the history of private `BrightCodeHub/lab_liddle` or copy its files wholesale.
