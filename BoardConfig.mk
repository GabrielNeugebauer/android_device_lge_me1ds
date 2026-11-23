LOCAL_PATH := device/lge/me1ds

# Architecture
# ME1DS_ARM64=true builds 64-bit TWRP on the arm64 kernel port
# (GabrielNeugebauer/android_kernel_lge_me1ds); default is the stock 32-bit kernel.
ME1DS_ARM64 ?= false

ifeq ($(ME1DS_ARM64),true)
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_VARIANT := generic
TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv7-a-neon
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := cortex-a7
TARGET_USES_64_BIT_BINDER := true
# bootopt last field 64N2 tells lk/ATF to start the kernel in AArch64
BOARD_KERNEL_CMDLINE := bootopt=64S3,32N2,64N2 androidboot.hardware=me1ds
BOARD_MKBOOTIMG_ARGS := --kernel_offset 0x00080000 --ramdisk_offset 0x04000000 --tags_offset 0x0e000000
TARGET_PREBUILT_KERNEL := $(LOCAL_PATH)/prebuilt/Image.gz-dtb
else
TARGET_ARCH := arm
TARGET_ARCH_VARIANT := armv7-a-neon
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_CPU_VARIANT := cortex-a7
# Stock LG kernel (K13010g), LZ4 zImage with appended DTB
BOARD_KERNEL_CMDLINE := bootopt=64S3,32N2,32N2 androidboot.hardware=me1ds
BOARD_MKBOOTIMG_ARGS := --kernel_offset 0x00008000 --ramdisk_offset 0x04000000 --tags_offset 0x0e000000
TARGET_PREBUILT_KERNEL := $(LOCAL_PATH)/prebuilt/zImage-dtb
endif

# Platform
TARGET_BOARD_PLATFORM := mt6735m
TARGET_BOOTLOADER_BOARD_NAME := me1ds
TARGET_NO_BOOTLOADER := true
BOARD_KERNEL_BASE := 0x40000000
BOARD_KERNEL_PAGESIZE := 2048

# Partitions (sizes from /proc/partitions)
BOARD_BOOTIMAGE_PARTITION_SIZE := 16777216
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 16777216
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 2583691264
BOARD_USERDATAIMAGE_PARTITION_SIZE := 4596432896
BOARD_CACHEIMAGE_PARTITION_SIZE := 209715200
BOARD_FLASH_BLOCK_SIZE := 131072
TARGET_USERIMAGES_USE_EXT4 := true
BOARD_HAS_LARGE_FILESYSTEM := true
BOARD_SUPPRESS_SECURE_ERASE := true

# Recovery
TARGET_RECOVERY_FSTAB := $(LOCAL_PATH)/recovery.fstab
BOARD_HAS_NO_SELECT_BUTTON := true
RECOVERY_SDCARD_ON_DATA := true
TARGET_RECOVERY_PIXEL_FORMAT := "RGBA_8888"
RECOVERY_GRAPHICS_USE_LINELENGTH := true
TARGET_USE_CUSTOM_LUN_FILE_PATH := /sys/class/android_usb/android0/f_mass_storage/lun/file

# TWRP
TW_THEME := portrait_mdpi
TW_EXTRA_LANGUAGES := false
TW_DEFAULT_LANGUAGE := en
TW_BRIGHTNESS_PATH := "/sys/class/leds/lcd-backlight/brightness"
TW_MAX_BRIGHTNESS := 255
TW_DEFAULT_BRIGHTNESS := 170
TW_CUSTOM_BATTERY_PATH := "/sys/class/power_supply/battery"
TW_INTERNAL_STORAGE_PATH := "/data/media"
TW_INTERNAL_STORAGE_MOUNT_POINT := "data"
TW_EXTERNAL_STORAGE_PATH := "/external_sd"
TW_EXTERNAL_STORAGE_MOUNT_POINT := "external_sd"
TW_EXCLUDE_SUPERSU := true
TW_USE_TOOLBOX := true
TW_NO_SCREEN_BLANK := true
TW_INCLUDE_NTFS_3G := false
TWRP_INCLUDE_LOGCAT := true
TARGET_USES_LOGD := true

# Keep the image under the 16 MB recovery partition
TW_EXCLUDE_TWRPAPP := true
TW_EXCLUDE_MTP := false
