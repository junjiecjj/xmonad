#! /usr/bin/env bash
#########################################################################
# File Name: autostart.sh
# Author:陈俊杰
# mail: 2716705056@qq.com
# Created Time: 2022年05月26日 星期四 14时14分39秒

# 此程序的功能是：
#########################################################################





# tray icons(eDP1 is the display device's name, use the command "xrandr" to see the display device name.)
# 其中的eDP1便是我的显示设备名称。如果你的显示设备名称不是eDP1 ，那么需要修改
exec --no-startup-id xrandr --output eDP-1 --primary

# 如果为笔记本外接两个显示器，关闭笔记本的显示器
# exec --no-startup-id xrandr --output DP-1-8 --mode 1920x1080 --primary
# exec --no-startup-id  xrandr --output DP-1-9 --mode 1920x1080  --right-of DP-1-8  --auto
# exec --no-startup-id xrandr  --output eDP-1 --off


# 如果为笔记本外接1个显示器
# exec --no-startup-id xrandr --output eDP-1 --mode 1920x1080 --primary
#exec --no-startup-id xrandr --output HDMI1 1920*1080 --right-of eDP1



# 如果为台式机外接2个显示器
# exec --no-startup-id xrandr --output HDM-1 --mode 1920x1080 --primary
# exec --no-startup-id xrandr --output HDMI-2  1920*1080 --right-of HDM-1



feh --recursive --randomize --bg-fill   $(xdg-user-dir PICTURES)'/Wallpapers/'
# feh --recursive  --bg-fill $(xdg-user-dir PICTURES)'/Wallpapers/background.jpg'


# Power manager
if [ -z "$(pgrep xfce4-power-manager)" ] ; then
    xfce4-power-manager &
fi




# Network Applet用于显示网络托盘图标，
if [ -z "$(pgrep nm-applet)" ] ; then
    nm-applet &
fi


# blue Applet蓝牙系统托盘
if [ -z "$(pgrep blueman-applet)" ] ; then
    blueman-applet &
fi

# Screensaver 锁屏工具
if [ -z "$(pgrep xscreensaver)" ] ; then
    xscreensaver -no-splash &
fi


# Redshift
# 护眼工具
if [ -z "$(pgrep redshift)" ] ; then
    redshift-gtk &
fi

# 启用窗口透明
if [ -z "$(pgrep picom)" ] ; then
    picom --experimental-backends -b
fi


# 火焰截图
if [ -z "$(pgrep   flameshot)" ] ; then
    nohup flameshot >/dev/null 2>&1  &
fi


# 桌面通知
if [ -z "$(pgrep   dunst)" ] ; then
    dunst &
fi



# 剪切板管理器
if [ -z "$(pgrep  copyq )" ] ; then
    copyq &
fi



# 开启小键盘
if [ -z "$(pgrep   numlockx)" ] ; then
   numlockx on
fi


if [ -z "$(pgrep  fcitx )" ] ; then
    fcitx   &
    fcitx5   &
fi



#音频相关的托盘
if [ -z "$(pgrep  pasystray )" ] ; then
     nohup   pasystray     >  /dev/null  2>&1 &
fi


if [ -z "$(pgrep  kmix )" ] ; then
     nohup   kmix     >  /dev/null  2>&1 &
fi


if [ -z "$(pgrep  pa-applet )" ] ; then
     nohup   /foo/bar/bin/pa-applet       >  /dev/null  2>&1 &
fi

if [ -z "$(pgrep  mictray )" ] ; then
     nohup   mictray       >  /dev/null  2>&1 &
fi


#  xautolock锁屏工具
if [ -z "$(pgrep  xautolock)" ] ; then
     xautolock -time 30 -locker '/usr/bin/betterlockscreen -l'   -corners +000 -cornersize 5 -cornerdelay 5 -cornerredelay 180 &
fi



# System tray
if [ -z "$(pgrep trayer)" ] ; then
    trayer --edge top --align right --widthtype percent --width 10 --heighttype pixel --height 22  --SetPartialStrut true --transparent true --alpha 60 --tint 0x777777 --expand true
fi


# if [ -z "$(pgrep stalonetray)" ] ; then
#     # stalonetray  -geometry  "10x1-0+0" -bg "#777777" --icon-size 17 --transparent false --sticky true --window-layer "bottom"  &
#     stalonetray  -geometry  "10x1-0+0" -bg "#777777" --icon-size 16 --transparent false --sticky true --window-layer "bottom" --grow-gravity  NW  --icon-gravity NW  --max-geometry 0x0 --scrollbars none --sticky  true  --window-type  dock
# fi
