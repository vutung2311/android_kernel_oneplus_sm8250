ifeq ($(CONFIG_BUILD_ARM64_DT_OVERLAY),y)
        dtbo-$(CONFIG_ARCH_KONA) += \
                instantnoodle.5.dtbo
endif

instantnoodle.5.dtbo-base := kona-v1.dtb kona-v2.dtb kona-v2.1.dtb

always		:= $(dtb-y)
subdir-y	:= $(dts-dirs)
clean-files    := *.dtb *.dtbo
