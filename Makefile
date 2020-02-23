THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 10000

export ARCHS = arm64 arm64e
TARGET = iphone:12.4

include $(THEOS)/makefiles/common.mk

RotateWall_CFLAGS = -fobjc-arc
CCFLAGS += -std=c++11

TWEAK_NAME = RotateWall
RotateWall_FILES = Tweak.xm RotateWall.mm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += rotatewall
include $(THEOS_MAKE_PATH)/aggregate.mk
