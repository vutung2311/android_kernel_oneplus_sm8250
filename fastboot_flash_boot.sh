#!/bin/bash

FASTBOOT=$(./get_fastboot.sh)

RDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

$FASTBOOT flash boot_a $RDIR/boot.img/out/boot.img
$FASTBOOT flash boot_b $RDIR/boot.img/out/boot.img