-- ~/.xmonad/xmobar.hs
--  https://gist.github.com/Pitometsu/3b73effc45ab21f88a758c9bee883126#file-xmonad-hs
Config {
    font = "xft:Inconsolata LGC:size=8.6:style=Medium",
    additionalFonts = ["xft:Inconsolata:size=10:style=Bold","xft:FontAwesome:size=7.5"],
    bgColor = "#eee8d5",
    fgColor = "#657b83",
    position = TopW L 100,
    lowerOnStart = True,
    commands = [
        Run Date "%a %b %_d %_H:%M" "date" 10,
        Run Kbd [ ("us(dvp)" , "<fc=#cb4b16>DV</fc>")
                , ("ru(winkeys)", "<fc=#dc322f>RU</fc>")
                ],
        Run Battery [ "-t", "<fn=2></fn> <acstatus>"
                    , "-L", "25"
                    , "-H", "75"
                    , "-h", "#859900"
                    , "-n", "#b58900"
                    , "-l", "#dc322f"
                    , "--"
                    , "-o", "<left>% (<timeleft>)"
                    , "-O", "<left>% <fc=#cb4b16><fn=2></fn></fc>"
                    , "-i", "<fc=#859900><fn=2></fn></fc>"] 30,
        Run Volume "default" "Master" [ "--template", "<fn=2></fn> <volume>%" -- " <status>" -- mute status
                                      , "--"
                                      , "-O", "<fn=2></fn>"
                                      , "-o", "<fn=2></fn>"
                                      , "-C", "#859900"
                                      , "-c", "#dc322f"
                                      , "--highd", "-5.0"
                                      , "--lowd", "-30.0"
                                      ] 5,
        Run Wireless "wlp4s0" [ "-a", "l"
                              , "-w", "4"
                              , "-t", "<fn=2></fn> <essid><quality>%"
                              , "-L", "50"
                              , "-H", "75"
                              , "-l", "#dc322f"
                              , "-n", "#cb4b16"
                              , "-h", "#859900"
                              ] 10,
        Run DynNetwork [ "--template", "<fn=2></fn> <tx> <fn=2></fn> <rx> kB/s"
                       , "--Low", "1000"
                       , "--High", "5000"
                       , "--low", "#859900"
                       , "--normal", "#cb4b16"
                       , "--high", "#dc322f"
                       ] 10,
        Run Memory [ "-t", "<fn=2></fn> <usedratio>%"
                   , "-H", "8192"
                   , "-L", "4096"
                   , "-h", "#dc322f"
                   , "-l", "#859900"
                   ,"-n", "#839496"] 10,
        Run Swap [ "-t", "<fn=2></fn> <usedratio>%"
                 , "-H", "1024"
                 , "-L", "512"
                 , "-h", "#dc322f"
                 , "-l", "#859900"
                 , "-n", "#839496"] 10,
        Run DiskIO [ ("/", "<fn=2></fn> <total>")
                   , ("/home", "<fn=2></fn> <total>")] [] 10,
        Run MultiCpu [ "-t", "<fn=2></fn> <total0><total1><total2><total3><total4><total5><total6><total7>"
                     , "-L", "30"
                     , "-H", "60"
                     , "-h", "#dc322f"
                     , "-l", "#859900"
                     , "-n", "#839496"
                     , "-w", "3"] 10,
        Run UnsafeStdinReader
    ],
    sepChar  = "%",
    alignSep = "}{",
    template = "%UnsafeStdinReader% }{ %multicpu%   %diskio%   %swap%   %memory%   %dynnetwork%   %wlp4s0wi%   %default:Master%   %battery%   %kbd% <fc=#fdf6e3>|</fc> <fn=1><fc=#2aa198>%date%</fc></fn> "
}
