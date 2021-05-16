TARGET := iphone:clang:latest:12.2

include $(THEOS)/makefiles/common.mk

TOOL_NAME = dynamicPaper
GO_EASY_ON_ME = 1

dynamicPaper_FILES = main.m InternalSetWallpaper.m EDSunriseSet.m
dynamicPaper_PRIVATE_FRAMEWORKS = PersistentConnection
dynamicPaper_CFLAGS = -fobjc-arc -w
dynamicPaper_CODESIGN_FLAGS = -Sentitlements.plist
dynamicPaper_INSTALL_PATH = /usr/local/bin

include $(THEOS_MAKE_PATH)/tool.mk
