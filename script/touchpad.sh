#! /usr/bin/env bash
#########################################################################
# File Name: touchpad.sh
# Author:陈俊杰
# mail: 2716705056@qq.com
# Created Time: 2022年05月10日 星期二 23时54分58秒

# 此程序的功能是：
#########################################################################


tID=$(xinput list|grep Touchpad|sed 's/^.*id=//g'|awk '{print $1}')
res=$(xinput list-props "${tID}"|grep "Device Enabled"|sed 's/.*:[ \t\n]*//g')
if [ "$res" = "1" ];then
    xinput set-prop "${tID}" "Device Enabled" 0
    notify-send "触摸板关闭"
else
    xinput set-prop "${tID}" "Device Enabled" 1
    notify-send "触摸板开启"
fi
