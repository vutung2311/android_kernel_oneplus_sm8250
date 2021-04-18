#!/bin/bash

RDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

fastboot flash dtbo_a $RDIR/dtbo.img/out/dtbo.img
fastboot flash dtbo_b $RDIR/dtbo.img/out/dtbo.img