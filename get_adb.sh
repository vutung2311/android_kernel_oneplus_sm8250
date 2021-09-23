#!/bin/bash

ADB=$(which adb)
if [ $ADB -eq ""]; then
ADB=$(which adb.exe)
fi
echo $ADB