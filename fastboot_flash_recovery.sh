#!/bin/bash

RDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

fastboot flash recovery_a $RDIR/recovery.img/out/recovery.img
fastboot flash recovery_b $RDIR/recovery.img/out/recovery.img