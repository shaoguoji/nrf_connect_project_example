# make        incremental build
# make flash  flash build/zephyr/zephyr.uf2 (enter UF2 bootloader first: double-tap RESET)
# make monitor  open USB serial console (exit: Ctrl+])
# make clean  delete the build directory

BOARD     := xiao_ble/nrf52840/sense
BUILD_DIR := build
TOOLCHAIN := /opt/nordic/ncs/toolchains/fa36dcc52a

# Same toolchain environment the nRF Connect extension uses
export ZEPHYR_BASE := $(HOME)/zephyrproject/zephyr
export ZEPHYR_SDK_INSTALL_DIR := $(TOOLCHAIN)/opt/zephyr-sdk
export PATH := $(TOOLCHAIN)/bin:$(TOOLCHAIN)/opt/python@3.12/bin:$(PATH)
PYTHON := $(TOOLCHAIN)/opt/python@3.12/bin/python3.12
WEST   := $(PYTHON) -m west

# Serial port of the board's USB CDC console (override: make monitor PORT=/dev/cu.xxx)
PORT ?= $(firstword $(wildcard /dev/cu.usbmodem*))

.PHONY: all flash monitor clean

all:
	$(WEST) build -d $(BUILD_DIR) -b $(BOARD) .

flash:
	$(WEST) flash -d $(BUILD_DIR) -r uf2 --no-rebuild

monitor:
	$(if $(PORT),,$(error No /dev/cu.usbmodem* port found, is the board running?))
	$(PYTHON) -m serial.tools.miniterm --raw $(PORT) 115200

clean:
	rm -rf $(BUILD_DIR)
