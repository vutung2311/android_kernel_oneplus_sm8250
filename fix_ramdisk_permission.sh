#!/bin/bash

RDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

find $RDIR/recovery.img/in/ramdisk -type d -exec chmod 755 {} \;
find $RDIR/recovery.img/in/ramdisk -type f -exec chmod 644 {} \;
find $RDIR/recovery.img/in/ramdisk -name "*.rc" -exec chmod 755 {} \;
chmod +x $RDIR/recovery.img/in/ramdisk/system/bin/*
chmod 0555 $RDIR/recovery.img/in/ramdisk/config/