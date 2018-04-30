THEOS_DEVICE_IP = 192.168.255.253

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = RotateWall
RotateWall_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += rotatewall
include $(THEOS_MAKE_PATH)/aggregate.mk
