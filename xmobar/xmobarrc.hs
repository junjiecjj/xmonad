Config {
       --  🚨🧠📅🧭
       -- font = "xft:Zekton:size=13:bold:antialias=true",
        font = "xft:WenQuanYi Micro Hei:style=Regular:pixelsize=15",
        -- font = "xft:CaskaydiaCove Nerd Font Mono:style=SemiLight:pixelsize=14",
        additionalFonts = [ "xft:FontAwesome:size=11" ]
       , allDesktops = True
       , bgColor = "#282c34"
       , fgColor = "#bbc2cf"
       , position = TopW L 90
       , commands = [ Run Cpu [ "--template", "<fc=#a9a1e1><fn=1></fn></fc> <total>%"
                              , "--Low","3"
                              , "--High","50"
                              , "--low","#bbc2cf"
                              , "--normal","#bbc2cf"
                              , "--high","#fb4934"] 50


                    , Run Memory ["-t","<fc=#51afef><fn=1></fn></fc>: <used>Mb (<usedratio>%)","-H","8192","-L","4096","-h","#ff0f37","-l","#859900","-n","#839496"] 10
                    -- , Run Memory ["-t","<fc=#51afef><fn=1></fn></fc> <used><usedratio>%"
                    --              ,"-H","80"
                    --              ,"-L","10"
                    --              ,"-l","#bbc2cf"
                    --              ,"-n","#bbc2cf"
                    --              ,"-h","#fb4934"] 50

                    , Run Weather "ZGGG" ["-t","<tempC>°C/<skyCondition>","-L","64","-H","77","-n","#FFD700","-h","#ff0fda","-l","#96CBFE"] 3600
                    , Run Date "<fc=#ECBE7B><fn=1></fn></fc> %Y-%m-%d %a %H:%M:%S" "date" 10
                    -- , Run DynNetwork ["-t", "<fc=#00ff00><fn=1> </fn></fc><fc=#4db5bd><fn=1></fn></fc> <rx>, <fc=#c678dd><fn=1></fn></fc> <tx>"
                    --                  ,"-H","200"
                    --                  ,"-L","10"
                    --                  ,"-h","#bbc2cf"
                    --                  ,"-l","#bbc2cf"
                    --                  ,"-n","#bbc2cf"] 50

                    ,  Run DynNetwork ["-t","<fc=#00ff00><fn=1> </fn></fc><fc=#4db5bd><fn=1></fn></fc><rx>kB/s <fc=#c678dd><fn=1></fn></fc><tx>kB/s"
                                     ,"-H","5000"
                                     ,"-L","1000"
                                     ,"-h","#fb4934"
                                     ,"-l","#bbc2cf"
                                     ,"-n","#bbc2cf"] 50

                    -- , Run DynNetwork   [ "--template", "<fc=#00ff00><fn=1> </fn></fc><fc=#4db5bd><fn=1></fn></fc><rx>kB/s <fc=#c678dd><fn=1></fn></fc><tx>kB/s"
                    --                , "--Low", "1000"
                    --                , "--High", "5000"
                    --                , "--low", "#859900"
                    --                , "--normal", "#cb4b16"
                    --                , "--high", "#dc322f"
                    --                ] 50


                    , Run DiskU [("/", "/:<free>"),("/home", "/home:<free>")] [] 60

                    , Run  DiskIO [("/", "<fn=2></fn>:<read> <write>"),  ("/home", "<fn=2></fn>:<read> <write>")] [] 10

                    , Run CoreTemp ["-t", "<fc=#CDB464><fn=1></fn></fc> <core0>°"
                                   , "-L", "30"
                                   , "-H", "75"
                                   , "-l", "lightblue"
                                   , "-n", "#bbc2cf"
                                   , "-h", "#aa4450"] 50

                    -- battery monitor
                    , Run BatteryP       [ "BAT0" ]
                                         [ "--template" , "<fc=#B1DE76><fn=1></fn></fc> <acstatus>"
                                         , "--Low"      , "10"        -- units: %
                                         , "--High"     , "80"        -- units: %
                                         , "--low"      , "#fb4934" -- #ff5555
                                         , "--normal"   , "#bbc2cf"
                                         , "--high"     , "#98be65"

                                         , "--" -- battery specific options
                                                   -- discharging status
                                                   , "-o"   , "<left>% (<timeleft>)"
                                                   -- AC "on" status
                                                   , "-O"   , "<left>% (<fc=#98be65>Charging</fc>)" -- 50fa7b
                                                   -- charged status
                                                   , "-i"   , "<fc=#98be65>Charged</fc>"
                                         ] 50


                   ,  Run Kbd [ ("us(dvp)" , "<fc=#cb4b16>DV</fc>")
                              , ("ru(winkeys)", "<fc=#dc322f>RU</fc>")
                               ]
                    -- , Run StdinReader
                    , Run UnsafeStdinReader
                    ]
       , sepChar = "%"
       , alignSep = "}{"
       , template = "%UnsafeStdinReader%}{ %cpu% | %coretemp% | %memory% | <fc=#00FFFF>%disku%</fc> | %battery% | %dynnetwork% | %kbd% | %ZGGG% <fc=#00ff00>%date%</fc> |"   -- #69DFFA
       }
