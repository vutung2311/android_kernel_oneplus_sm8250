#!/bin/bash

FASTBOOT=$(./get_fastboot.sh)

RDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

$FASTBOOT flash recovery_a $RDIR/recovery.img/out/recovery.img
$FASTBOOT flash recovery_b $RDIR/recovery.img/out/recovery.img