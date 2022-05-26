#! /usr/bin/env bash
#########################################################################
# File Name: autostart.sh
# Author:陈俊杰
# mail: 2716705056@qq.com
# Created Time: 2022年05月26日 星期四 14时14分39秒

# 此程序的功能是：
#########################################################################



# System tray
if [ -z "$(pgrep trayer)" ] ; then
    trayer --edge top \
           --align right \
           --widthtype percent \
           --height 24 \
           --alpha 0 \
           --transparent true \
           --width 5 \
           --tint 0x282c34 &
fi

# Power manager
if [ -z "$(pgrep xfce4-power-manager)" ] ; then
    xfce4-power-manager &
fi

# Taffybar
# if [ -z "$(pgrep taffybar)" ] ; then
#     taffybar &
# fi

# Redshift
if [ -z "$(pgrep redshift)" ] ; then
    redshift-gtk &
fi

# Autolock
# if [ -z "$(pgrep xautolock)" ] ; then
    # xautolock -time 1 -locker "if ! grep 'RUNNING' /proc/asound/card*/pcm*/sub*/status;then xscreensaver-command -lock; else echo 'Sound on'; fi"
# fi

# Wallpaper
if [ -z "$(pgrep nitrogen)" ] ; then
    nitrogen --restore &
fi

# Screensaver
if [ -z "$(pgrep xscreensaver)" ] ; then
    xscreensaver -no-splash &
fi

# compton
if [ -z "$(pgrep compton)" ] ; then
    compton -b &
fi

# Network Applet
if [ -z "$(pgrep nm-applet)" ] ; then
    nm-applet &
fi

# Google Drive
if [ -z "$(pgrep insync)" ] ; then
    insync start &
fi
# xbindkeys
xbindkeys
