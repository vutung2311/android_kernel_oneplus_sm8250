vendor := $(srctree)/$(src)

ifneq "$(wildcard $(vendor)/qcom)" ""
	subdir-y += qcom
else
ifneq "$(wildcard $(vendor)/oneplus)" ""
	subdir-y += oneplus
endif
endif
