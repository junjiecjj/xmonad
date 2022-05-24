-- xmobar config used by Vic Fryzel
-- Author: Vic Fryzel
-- https://github.com/vicfryzel/xmonad-config

-- This xmobar config is for dual 2560x1440 displays and meant to be used with
-- the stalonetrayrc-dual config.
--   https://github.com/vicfryzel/xmonad-config/blob/master/xmobar-dual.hs
-- If you're using dual displays with different resolutions, adjust the
-- position argument below using the given calculation.
Config {
    -- Position xmobar along the top, with stalonetray in the top right.
    -- Shrink xmobar width to ensure stalonetray and xmobar don't overlap.
    -- stalonetrayrc-dual is configured for 12 icons, each 19px wide.
    -- Because of the dual display setup, we statically position xmobar.
    -- Each display is 2560px wide. Offset left (x position) by one width.
    -- xpos = display_width = 1920
    -- If your left display is primary, then set xpos = 0.
    -- ypos = 0 (top)
    -- width = display_width - (num_icons * icon_width)
    -- width = 1920 - (12 * 19) = 1692
    -- height = 19
    -- position = Static { xpos = 1920, ypos = 0, width = 1692, height = 19 },
    position = TopP 0 276,
    -- position = Static { xpos = 0 , ypos = 0, width = 1920, height = 24 }
    -- font = "xft:monospace:pixelsize=8",
    -- font = "xft:WenQuanYi Micro Hei:style=Regular:pixelsize=15",
    -- font = "xft:CaskaydiaCove Nerd Font Mono:style=ExtraLight:pixelsize=15",
    -- font = "xft:CaskaydiaCove Nerd Font Mono:style=Light:pixelsize=15",
    font = "xft:CaskaydiaCove Nerd Font Mono:style=SemiLight:pixelsize=15",
    bgColor = "#000000",
    fgColor = "#ffffff",
    border =  BottomB,
    borderColor = "black",
    lowerOnStart = False,
    overrideRedirect = False,
    -- We don't want xmobar on all desktops in a dual display setup.
    allDesktops = False,
    persistent = True,
    commands = [

        -- Run MPD ["-t", "<composer> <title> (<album>) <track>/<plength> <statei> [<flags>]",  "--", "-P", ">>", "-Z", "|", "-S", "><"] 10,

        -- Run MPD ["-t","<composer><file> <remaining> /<plength> <statei> [<flags>]", "--", "-P", ">>", "-Z", "|", "-S", "><"] 10,

        -- Run Weather "ZGGG" ["-t","<station>:<tempC>°C <skyCondition> <windMs>m/s","-L","64","-H","77","-n","#CEFFAC","-h","#FFB6B0","-l","#96CBFE"] 36000,
        Run Weather "ZGGG" ["-t","<station>:<tempC>°C <skyCondition>","-L","64","-H","77","-n","#CEFFAC","-h","#ff0fda","-l","#96CBFE"] 3600,
        -- Run Weather "ZGGG" [ "--template", "<station>: | <fc=#FFFFFF><tempC></fc>°C  <windMs>" ] 36000,

        Run MultiCpu ["-t","CPU:<total>%","-L","30","-H","60","-h","#ff0f37","-l","#CEFFAC","-n","#FFFFCC","-w","3"] 10,
        -- Run MultiCpu ["-t","Cpu: <total0> <total1> <total2> <total3>","-L","30","-H","60","-h","#FFB6B0","-l","#CEFFAC","-n","#FFFFCC","-w","3"] 10,

        Run Memory ["-t","Mem: <used>M (<usedratio>%)","-H","8192","-L","4096","-h","#FFB6B0","-l","#CEFFAC","-n","#FFFFCC"] 10,
        Run Swap ["-t","Swap: <usedratio>%","-H","1024","-L","512","-h","#FFB6B0","-l","#CEFFAC","-n","#FFFFCC"] 10,


        Run Com "/home/jack/.xmonad/xmobar/trayer-padding-icon.sh" [] "trayerpad" 20,

        Run DiskU [("/", "/:<free>")] [] 60,
        -- Run DiskH [("/home", "/:<free>")] [] 60,

        Run Com "uname" ["-r"] "" 3600,


        Run Network "wlp59s0" ["-t","直:<rx>kB/s <tx>kB/s","-H","200","-L","10","-h","#FFB6B0","-l","#CEFFAC","-n","#FFFFCC"] 10,

        Run Battery        [ "-t", "BAT: <acstatus>", "--Low", "20", "--High","80", "--low","darkred", "--normal","darkorange", "--high","#81a1c1"
                                     , "--" -- battery specific options
                                       -- discharging status
                                       , "-o"	, "<left>% (<timeleft>)"
                                       -- AC "on" status
                                       , "-O"	, "Charging <left>%"
                                       -- charged status
                                       , "-i"	, "Charged"
                             ] 50,

        -- Run Date "%a %b %_d %l:%M" "date" 10,
        Run Date "%Y-%m-%d %a %H:%M:%S" "date" 10,

        -- Run Volume "default" "Master" [] 10,

        Run StdinReader
    ],

    sepChar = "%",
    alignSep = "}{",
    -- template = "%StdinReader% }{ %multicpu% | %memory% | %swap% | %disku% |  %uname% | <fc=#00ff00>%wlp59s0%</fc> | %battery% | Vol:<fc=#b2b2ff>%volumelevel%</fc> | %ZGGG% | :<fc=#00ff00>%date%</fc> | %trayerpad%"
    template = "%StdinReader% }{ <fc=#FFDAB9>%multicpu% %memory% %swap% %disku%</fc><fc=#32CD32> | %wlp59s0%</fc> | %battery% | %ZGGG% | :<fc=#00ff00>%date%</fc>"
}
