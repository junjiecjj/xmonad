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
    -- position = TopP 0 276,
    -- position 指定了 xmobar 的位置：左上，长度 90%，而 trayer 的则为右上，长度 10%。刚好能够接上。
    position = TopW L 89,
    -- position = Static { xpos = 0 , ypos = 0, width = 1920, height = 24 }
    -- font = "xft:monospace:pixelsize=8",
    -- font = "xft:Ubuntu Mono-13",
    font = "xft:WenQuanYi Micro Hei:style=Regular:pixelsize=15",
    -- font = "xft:CaskaydiaCove Nerd Font Mono:style=ExtraLight:pixelsize=15",
    -- font = "xft:CaskaydiaCove Nerd Font Mono:style=Light:pixelsize=15",
    -- font = "xft:CaskaydiaCove Nerd Font Mono:style=SemiLight:pixelsize=14",
    additionalFonts = [ "xft:Inconsolata:size=10:style=Bold","xft:FontAwesome:size=8.5"],
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
        Run Weather "ZGGG" ["-t","<station>:<tempC>°C <skyCondition>","-L","64","-H","77","-n","#FFD700","-h","#ff0fda","-l","#96CBFE"] 3600,
        -- Run Weather "ZGGG" [ "--template", "<station>: | <fc=#FFFFFF><tempC></fc>°C  <windMs>" ] 36000,

        -- Run MultiCpu ["-t","<fn=2></fn>:<total>%","-L","20","-H","60","-h","#ff0f37","-l","#00F5FF","-n","#FFD700","-w","3"] 10,
        Run MultiCpu ["-t","CPU: <total>%","-L","30","-H","60","-h","#dc322f","-l","#859900","-n","#839496","-w","3"] 10,

        -- Run MultiCpu [ "-t", "<fn=2></fn>:<total>"
        --              , "-L", "30"
        --              , "-H", "60"
        --              , "-h", "#dc322f"
        --              , "-l", "#859900"
        --              , "-n", "#839496"
        --              , "-w", "3"] 10,

        Run Memory ["-t","Mem: <used>M (<usedratio>%)","-H","8192","-L","4096","-h","#ff0f37","-l","#859900","-n","#839496"] 10,
        -- Run Memory [ "-t", "<fn=2></fn>:<usedratio>%"
        --            , "-H", "8192"
        --            , "-L", "4096"
        --            , "-h", "#dc322f"
        --            , "-l", "#859900"
        --            ,"-n", "#839496"] 10,

        Run Swap ["-t","Swap: <usedratio>%","-H","1024","-L","512","-h","#FFB6B0","-l","#859900","-n","#839496"] 10,
        -- Run Swap [ "-t", "<fn=2></fn>:<usedratio>%"
        --          , "-H", "1024"
        --          , "-L", "512"
        --          , "-h", "#dc322f"
        --          , "-l", "#859900"
        --          , "-n", "#839496"] 10,

        Run Com "/home/jack/.xmonad/xmobar/trayer-padding-icon.sh" [] "trayerpad" 20,

        Run DiskU [("/", "/:<free>"),("/home", "/home:<free>")] [] 60,
        -- Run DiskU [("/", "<fn=2></fn>:<free>"),("/home", "<fn=2></fn>:<free>")] [] 60,
        -- Run DiskH [("/home", "/:<free>")] [] 60,

        Run  DiskIO [("/", "<fn=2></fn>:<read> <write>"),  ("/home", "<fn=2></fn>:<read> <write>")] [] 10,

        Run Com "uname" ["-r"] "" 3600,

        Run Kbd [ ("us(dvp)" , "<fc=#cb4b16>DV</fc>")
                , ("ru(winkeys)", "<fc=#dc322f>RU</fc>")
                ],

        -- Run Volume "default" "Master" [ "--template", "<fn=2></fn> <volume>%" -- " <status>" -- mute status
        --                               , "--"
        --                               , "-O", "<fn=2></fn>"
        --                               , "-o", "<fn=2></fn>"
        --                               , "-C", "#859900"
        --                               , "-c", "#dc322f"
        --                               , "--highd", "-5.0"
        --                               , "--lowd", "-30.0"
        --                               ] 5,

        -- Run Network "wlp59s0" ["-t","直:<rx>kB/s <tx>kB/s","-H","200","-L","10","-h","#FFB6B0","-l","#CEFFAC","-n","#FFFFCC"] 10,

        Run Wireless "wlp59s0" [ "-a", "l"
                              , "-w", "4"
                              , "-t", "<essid><quality>%"
                              , "-L", "50"
                              , "-H", "75"
                              , "-l", "#dc322f"
                              , "-n", "#cb4b16"
                              , "-h", "#859900"
                              ] 1000,

        Run DynNetwork ["-t","<fn=2></fn>:<fc=#4db5bd><fn=2></fn></fc><rx>kB/s <fc=#c678dd><fn=2></fn></fc><tx>kB/s"
                                     ,"-H","200"
                                     ,"-L","10"
                                     ,"-h","#bbc2cf"
                                     ,"-l","#bbc2cf"
                                     ,"-n","#bbc2cf"] 50,

        -- Run DynNetwork   [ "--template", "<fn=2></fn>:<fc=#4db5bd><fn=2></fn></fc><rx>kB/s <fc=#c678dd><fn=2></fn></fc><tx>kB/s"
        --                , "--Low", "1000"
        --                , "--High", "5000"
        --                , "--low", "#859900"
        --                , "--normal", "#cb4b16"
        --                , "--high", "#dc322f"
        --                ] 10,

        -- Run Battery   [ "-t", "<fn=2></fn>: <acstatus>", "--Low", "20", "--High","80", "--low","darkred", "--normal","darkorange", "--high","#81a1c1"
        --                              , "--" -- battery specific options
        --                                -- discharging status
        --                                , "-o", "<left>% (<timeleft>)"
        --                                -- AC "on" status
        --                                , "-O", "<left>%<fc=#cb4b16><fn=2></fn></fc>"
        --                                -- charged status
        --                                , "-i", "<fc=#859900><fn=2></fn></fc>"
        --                      ] 50,

        Run Battery [ "-t", "<fn=2></fn> <acstatus>"
                    , "-L", "25"
                    , "-H", "75"
                    , "-h", "#859900"
                    , "-n", "#b58900"
                    , "-l", "#dc322f"
                    , "--"
                    , "-o", ":<left>% (<timeleft>)"
                    , "-O", "<left>% <fc=#cb4b16><fn=2></fn></fc>"
                    , "-i", "<fc=#859900><fn=2></fn></fc>"] 30,

         -- Run Battery
         --               [ "--template" , "<acstatus>"
         --                     , "--Low"      , "10"        -- units: %
         --                     , "--High"     , "80"        -- units: %
         --                     , "--low"      , "#BF616A"
         --                     , "--normal"   , "#EBCB8B"
         --                     , "--high"     , "#A3BE8C"
         --                     , "--" 
         --                               , "--lows"     , ": <left>% <timeleft>"
         --                               , "--mediums"  , ": <left>% <timeleft>"
         --                               , "--highs"    , ": <left>% <timeleft>"
         --                               -- AC "on" status
         --                               , "-O"  , ": <left>% <timeleft>"
         --                               -- charged status
         --                               , "-i"  , ""
         --                               , "-a", "notify-send -u critical 'Battery running out!!'"
         --                               , "-A", "20"
         --                     ] 50,

        -- Run Date "%a %b %_d %l:%M" "date" 10,
        Run Date "<fc=#ECBE7B><fn=1></fn></fc>%Y-%m-%d %a %H:%M:%S" "date" 10,
        -- Run Date "<fc=#ECBE7B><fn=1></fn></fc> %a %b %_d %I:%M" "date" 300,
        -- Run Volume "default" "Master" [] 10,

        -- Run StdinReader,

        Run UnsafeStdinReader
    ],

    sepChar = "%",
    alignSep = "}{",
    -- template = "%StdinReader% }{ %multicpu% | %memory% | %swap% | %disku% |  %uname% | <fc=#00ff00>%wlp59s0%</fc> | %battery% | Vol:<fc=#b2b2ff>%volumelevel%</fc> | %ZGGG% | :<fc=#00ff00>%date%</fc> | %trayerpad%"
    -- template = "%UnsafeStdinReader% }{ <fc=#00FFFF>%multicpu% | %memory% | %swap% | %disku%  %diskio%</fc><fc=#00ff00> | %dynnetwork% %wlp59s0% </fc> | <fc=#FFD700>%battery% </fc>| %kbd% |<fc=#00ff00>:%date%</fc>"
    template = "%UnsafeStdinReader% }{ <fc=#00FFFF>%multicpu% | %memory% | %swap% | %disku% </fc><fc=#00ff00> | %dynnetwork% </fc> | <fc=#FFD700>%battery% </fc>| %kbd% |<fc=#00ff00>:%date%</fc>"
}
