#!/bin/bash

ADB=$(./get_adb.sh)

$ADB shell 'mount -t pstore pstore /sys/fs/pstore'
$ADB pull /sys/fs/pstore/console-ramoops-0 last_console.log
$ADB pull /sys/fs/pstore/dmesg-ramoops-0 last_dmesg.log