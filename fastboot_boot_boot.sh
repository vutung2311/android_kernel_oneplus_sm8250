#!/bin/bash

FASTBOOT=$(./get_fastboot.sh)

RDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

$FASTBOOT boot $RDIR/boot.img/out/boot.img