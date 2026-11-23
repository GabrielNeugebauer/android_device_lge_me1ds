LOCAL_PATH := $(call my-dir)

ifeq ($(TARGET_DEVICE),me1ds)
include $(call all-makefiles-under,$(LOCAL_PATH))
endif
