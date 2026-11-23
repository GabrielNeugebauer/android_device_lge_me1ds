ifeq ($(ME1DS_ARM64),true)
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
endif
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)
$(call inherit-product, vendor/omni/config/common.mk)


PRODUCT_DEVICE := me1ds
PRODUCT_NAME := omni_me1ds
PRODUCT_BRAND := lge
PRODUCT_MODEL := LG-K130
PRODUCT_MANUFACTURER := LGE
