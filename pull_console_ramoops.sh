#!/bin/bash

adb shell 'mount -t pstore pstore /sys/fs/pstore'
adb pull /sys/fs/pstore/console-ramoops-0 last_kmsg.log