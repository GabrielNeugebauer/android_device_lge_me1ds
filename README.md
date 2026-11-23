# TWRP device tree for LG K130 (me1ds)

- SoC: MediaTek MT6735M, 1 GB RAM, 8 GB eMMC
- Stock: Android 5.1.1 (LMY47V), LG K13010g
- Kernel: arm64 port of LG's 3.10.65 source, see
  [android_kernel_lge_me1ds](https://github.com/GabrielNeugebauer/android_kernel_lge_me1ds)
- Recovery: 64-bit TWRP built on the `twrp-5.1` minimal manifest
  (kernel SELinux tops out at policy v29, so 6.0+ bases do not boot)

Requires an unlocked bootloader (`fastboot oem unlock`, MTK seccfg).

## Build
```
repo init -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-5.1
git clone <this repo> device/lge/me1ds
. build/envsetup.sh && lunch omni_me1ds-eng && make recoveryimage
```
