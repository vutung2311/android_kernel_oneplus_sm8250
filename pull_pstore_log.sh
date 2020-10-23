#!/bin/bash

adb shell 'mount -t pstore pstore /sys/fs/pstore'
adb pull /sys/fs/pstore/console-ramoops-0 last_console.log
adb pull /sys/fs/pstore/dmesg-ramoops-0 last_dmesg.log