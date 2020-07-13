obj-y += rmnet_perf.o rmnet_shs.o
rmnet_perf-objs := rmnet_perf_config.o rmnet_perf_core.o rmnet_perf_opt.o \
		rmnet_perf_tcp_opt.o rmnet_perf_udp_opt.o

rmnet_shs-objs := rmnet_shs_config.o rmnet_shs_main.o rmnet_shs_wq.o \
		rmnet_shs_freq.o rmnet_shs_wq_mem.o rmnet_shs_wq_genl.o

rmnet_perf-objs	:= $(addprefix data/drivers/rmnet/perf/,$(rmnet_perf-objs))

rmnet_shs-objs	:= $(addprefix data/drivers/rmnet/shs/,$(rmnet_shs-objs))

ccflags-rmnet_perf-objs := -I$(src)/data/drivers/rmnet/perf -I$(obj)/data/drivers/rmnet/perf

ccflags-rmnet_shs-objs := -I$(src)/data/drivers/rmnet/shs -I$(obj)/data/drivers/rmnet/shs