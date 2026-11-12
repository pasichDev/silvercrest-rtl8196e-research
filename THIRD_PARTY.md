# Credits and licensing

This repo keeps upstream work as links instead of copying vendor code or kernel trees.

- **Paul Banks:** original documentation of the SilverCrest gateway's device-specific root password relationship: https://paulbanks.org/projects/lidl-zigbee/. This repository does not claim that discovery.
- **jnilo1/rtl8196e-gateway:** Linux platform port, build system and Lexra toolchain foundation: https://github.com/jnilo1/rtl8196e-gateway. Check that project's licenses for its original files.
- **Linux / WireGuard:** kernel-derived patches and measurements are in https://github.com/pasichDev/rtl8196e-wireguard. Their Linux-derived files retain the applicable GPL-2.0 terms; they are not relicensed by this repo.
- **musl libc:** the included `951-stock-kernel-no-rdhwr.patch` modifies musl 1.2.6 interfaces. Preserve original musl copyright notices and license when applying it. The original contribution to the patch is offered under MIT.
- **SilverCrest, Lidl, Tuya, Realtek:** brand names only identify the test platform; no endorsement is implied. No proprietary blobs are bundled.

The top-level [MIT license](LICENSE) covers my original documentation and code here, not the contents of external links or other people's code.
