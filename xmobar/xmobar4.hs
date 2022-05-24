

--  https://www.jianshu.com/p/9bb4c13fa687


Config {

    font = "xft:CaskaydiaCove Nerd Font Mono-12",
    bgColor =      "#7a7a7a",
    fgColor =      "#ffffff",
    position = TopP 0 276,
    -- border =       TopB,
    borderColor =  "#646464",
    additionalFonts = [ "xft:JetBrainsMono Nerd Font Mono:pixelsize=16",
                         "xft:FontAwesome5:pixelsize=13",
                         "xft:CaskaydiaCove Nerd Font Mono:pixelsize=12",
                         "xft:YaHei Consolas Hybrid:pixelsize=12",
                         "xft:CaskaydiaCove Nerd Font Mono:style=SemiLight:pixelsize=12"
                           ],
    alpha = 255,
    textOffset = -1,
    iconOffset = -1,
    iconRoot = ".",


    -- general behavior
    -- send to bottom of window stack on start,
    lowerOnStart =     True,

    -- start with window unmapped (hidden),
    hideOnStart =      False,

    -- show on all desktops,
    allDesktops =      True,

    -- set the Override Redirect flag (Xlib),
    overrideRedirect = True,

    -- choose widest display (multi-monitor),
    pickBroadest =     False,

    -- enable/disable hiding (True = disabled),
    persistent =       False,

    commands = [
       -- network activity monitor (dynamic interface resolution)
       Run Network "wlp59s0" ["-t","Net:<rx>KB/s <tx>KB/s","-H","200","-L","10","-h","#FFB6B0","-l","#CEFFAC","-n","#FFFFCC"] 10,
       Run MPD ["-t","<composer><file> <remaining> /<plength> <statei> [<flags>]", "--", "-P", ">>", "-Z", "|", "-S", "><"] 10,

       -- cpu activity monitor
       Run MultiCpu       [ "--template" , "Cpu: <total0>%|<total1>%"
                            , "--Low"      , "50"         -- units: %
                            , "--High"     , "85"         -- units: %
                            , "--low"      , "darkgreen"
                            , "--normal"   , "darkorange"
                            , "--high"     , "darkred"
                            ] 10,

       -- cpu core temperature monitor
       Run CoreTemp       [ "--template" , "Temp: <core0>°C| <core1>°C"
                            , "--Low"      , "70"        -- units: °C
                            , "--High"     , "80"        -- units: °C
                            , "--low"      , "darkgreen"
                            , "--normal"   , "darkorange"
                            , "--high"     , "darkred"
                            ] 50,

         -- memory usage monitor
        Run Memory         [ "--template" ,"Mem: <usedratio>%"
                            , "--Low"      , "20"        -- units: %
                            , "--High"     , "90"        -- units: %
                            , "--low"      , "darkgreen"
                            , "--normal"   , "darkorange"
                            , "--high"     , "darkred"
                            ] 10,

         -- battery monitor
         Run Battery        [ "--template" , "Batt: <acstatus>", "--Low", "10" , "--High" , "80" , "--low" , "darkred","--normal" , "darkorange", "--high" , "darkgreen" ,  "-o" , "<left>% (<timeleft>)", "-O" , "<fc=#dAA520>Charging</fc>", "-i" , "<fc=#006000>Charged</fc>"] 50,

        -- time and date indicator
          --   (%F = y-m-d date, %a = day of week, %T = h:m:s time)
         Run Com "~/.xmonad/bin/getMasterVolume" [] "vol" 10,

         Run Date           "<fc=#FFA500>%F (%a) %T</fc>" "date" 10,

         Run Weather "ZGGG" [ "--template", "<station>: | <fc=#FFFFFF><tempC></fc>°C | <windMs>" ] 36000,

         Run StdinReader
    ],

    -- layout
    -- delineator between plugin names and straight text,
    sepChar =  "%",
    -- separator between left-right alignment,
    alignSep = "}{",
    template = "%StdinReader% }{  %network%  %mpd% %ZGGG%"
}
