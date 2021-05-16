TARGET := iphone:clang:latest:12.2

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = dynamicPaperExtra

dynamicPaperExtra_FILES = extra.x
dynamicPaperExtra_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
