vendor := $(srctree)/$(src)

ifneq "$(wildcard $(vendor)/oneplus)" ""
	subdir-y += oneplus
else
ifneq "$(wildcard $(vendor)/qcom)" ""
	subdir-y += qcom
endif
endif
