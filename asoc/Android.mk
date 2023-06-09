# Android makefile for audio kernel modules

# Assume no targets will be supported

# Check if this driver needs be built for current target
ifeq ($(call is-board-platform,sdm845),true)
TARGET := sdm845
AUDIO_SELECT  := CONFIG_SND_SOC_SDM845=m
endif

ifeq ($(call is-board-platform-in-list,msm8953 sdm670 qcs605),true)
TARGET := sdm670
AUDIO_SELECT  := CONFIG_SND_SOC_SDM670=m
endif

ifeq ($(call is-board-platform-in-list,msm8937),true)
TARGET := sdm450
endif

ifeq ($(call is-board-platform-in-list,sdmshrike msmnile),true)
TARGET := msmnile
ifeq ($(TARGET_BOARD_AUTO),true)
AUDIO_SELECT  := CONFIG_SND_SOC_SA8155=m
else
AUDIO_SELECT  := CONFIG_SND_SOC_SM8150=m
endif
endif

ifeq ($(call is-board-platform-in-list,$(MSMSTEPPE) atoll),true)
TARGET := talos
ifeq ($(TARGET_BOARD_AUTO),true)
AUDIO_SELECT  := CONFIG_SND_SOC_SA6155=m
else
AUDIO_SELECT  := CONFIG_SND_SOC_SM6150=m
endif
endif

ifeq ($(call is-board-platform,$(TRINKET)),true)
TARGET := trinket
AUDIO_SELECT  := CONFIG_SND_SOC_SM6150=m
endif

AUDIO_CHIPSET := audio
# Build/Package only in case of supported target
ifeq ($(call is-board-platform-in-list,msm8953 msm8937 sdm845 sdm670 qcs605 sdmshrike msmnile $(MSMSTEPPE) $(TRINKET)),true)

LOCAL_PATH := $(call my-dir)

# This makefile is only for DLKM
ifneq ($(findstring vendor,$(LOCAL_PATH)),)

ifneq ($(findstring opensource,$(LOCAL_PATH)),)
  ifneq ($(BOARD_OPENSOURCE_DIR), )
	AUDIO_BLD_DIR := $(shell pwd)/$(BOARD_OPENSOURCE_DIR)/audio-kernel
  else
	AUDIO_BLD_DIR := $(shell pwd)/vendor/qcom/opensource/audio-kernel
  endif # BOARD_OPENSOURCE_DIR
endif # opensource

ifeq ($(TARGET_SUPPORTS_WEARABLES),true)
DLKM_DIR := $(BOARD_COMMON_DIR)/dlkm
else
DLKM_DIR := $(TOP)/device/qcom/common/dlkm
endif

# Build audio.ko as $(AUDIO_CHIPSET)_audio.ko
###########################################################
# This is set once per LOCAL_PATH, not per (kernel) module
KBUILD_OPTIONS := AUDIO_ROOT=$(AUDIO_BLD_DIR)

# We are actually building audio.ko here, as per the
# requirement we are specifying <chipset>_audio.ko as LOCAL_MODULE.
# This means we need to rename the module to <chipset>_audio.ko
# after audio.ko is built.
KBUILD_OPTIONS += MODNAME=platform_dlkm
KBUILD_OPTIONS += BOARD_PLATFORM=$(TARGET_BOARD_PLATFORM)
KBUILD_OPTIONS += $(AUDIO_SELECT)

###########################################################
include $(CLEAR_VARS)
LOCAL_MODULE              := $(AUDIO_CHIPSET)_platform.ko
LOCAL_MODULE_KBUILD_NAME  := platform_dlkm.ko
LOCAL_MODULE_TAGS         := optional
LOCAL_MODULE_DEBUG_ENABLE := true
LOCAL_MODULE_PATH         := $(KERNEL_MODULES_OUT)
include $(DLKM_DIR)/AndroidKernelModule.mk
###########################################################
ifeq ($(call is-board-platform-in-list,msm8953 msm8937 sdm670 qcs605 $(TRINKET)),true)
include $(CLEAR_VARS)
LOCAL_MODULE              := $(AUDIO_CHIPSET)_cpe_lsm.ko
LOCAL_MODULE_KBUILD_NAME  := cpe_lsm_dlkm.ko
LOCAL_MODULE_TAGS         := optional
LOCAL_MODULE_DEBUG_ENABLE := true
LOCAL_MODULE_PATH         := $(KERNEL_MODULES_OUT)
include $(DLKM_DIR)/AndroidKernelModule.mk
endif
###########################################################
include $(CLEAR_VARS)
LOCAL_MODULE              := $(AUDIO_CHIPSET)_machine_$(TARGET).ko
LOCAL_MODULE_KBUILD_NAME  := machine_dlkm.ko
LOCAL_MODULE_TAGS         := optional
LOCAL_MODULE_DEBUG_ENABLE := true
LOCAL_MODULE_PATH         := $(KERNEL_MODULES_OUT)
include $(DLKM_DIR)/AndroidKernelModule.mk
###########################################################

endif # DLKM check
endif # supported target check
