ARCHS = arm64 arm64e
TARGET = iphone:clang:16.5:15.0

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = RegionShotBridge
RegionShotBridge_FILES = main.m
RegionShotBridge_FRAMEWORKS = UIKit Foundation
RegionShotBridge_CFLAGS = -fobjc-arc
RegionShotBridge_CODESIGN_FLAGS = -S

include $(THEOS_MAKE_PATH)/application.mk

after-install::
	install.exec "uicache -a >/dev/null 2>&1 || /var/jb/usr/bin/uicache -a >/dev/null 2>&1 || true"
