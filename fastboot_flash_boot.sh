#!/bin/bash

RDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

fastboot flash boot_a $RDIR/boot.img/out/boot.img
fastboot flash boot_b $RDIR/boot.img/out/boot.img