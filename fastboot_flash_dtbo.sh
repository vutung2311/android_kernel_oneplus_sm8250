#!/bin/bash

FASTBOOT=$(./get_fastboot.sh)

RDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

$FASTBOOT flash dtbo_a $RDIR/dtbo.img/out/dtbo.img
$FASTBOOT flash dtbo_b $RDIR/dtbo.img/out/dtbo.img