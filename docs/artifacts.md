# Binary release policy

I deliberately did not include a firmware image. The newer kernel booted, but automatic vendor/Zigbee startup did not survive the experimental bootstrap, and a failed kernel boot might require UART recovery.

Before any future binary release: verify rights for every included component; check original kernel source/patch licenses; remove IP/MAC-specific bootstrap data, passwords, certificates, provisioning keys and vendor blobs; record the exact target board revision, upstream commit, build toolchain, image hashes and partition geometry; and document every non-working feature and recovery method.

The full original flash backup and provisioning partitions will not be published. Source-first release is safer and makes the engineering work more inspectable.
