#!/bin/bash

FASTBOOT=$(which fastboot)
if [ $FASTBOOT -eq ""]; then
FASTBOOT=$(which fastboot.exe)
fi
echo $FASTBOOT