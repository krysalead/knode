#!/bin/sh
sentence="Successfully built 40ad25f0b3f6"
stringarray=($sentence)
echo ${stringarray[${#stringarray[@]} - 1]]}