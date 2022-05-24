--  https://github.com/ayamir/nord-and-light/blob/master/.config/xmobar/xmobarrc0
-- http://projects.haskell.org/xmobar/
-- install xmobar with these flags: --flags="with_alsa" --flags="with_mpd" --flags="with_xft"  OR --flags="all_extensions"
-- you can find weather location codes here: http://weather.noaa.gov/index.html

Config { font    = "xft:Sarasa UI SC:weight=regular:pixelsize=13:antialias=true:hinting=true"
       , additionalFonts = [ "xft:Input Nerd Font:pixelsize=11:antialias=true:hinting=true"
                           , "xft:FontAwesome5:pixelsize=13"
                           ]
       , bgColor = "#D8DEE9"
       , fgColor = "#BF616A"
       , position = Static { xpos = 0 , ypos = 0, width = 1920, height = 24 }
       , lowerOnStart = True
       , hideOnStart = False
       , allDesktops = True
       , persistent = True
       , iconRoot = "/home/jack/.xmonad/xpm/"  -- default: "."
       , commands = [ 
                      -- Time and date
                      Run Date "<fn=1>\xf133 </fn> %b %d %Y (%H:%M)" "date" 50
                      -- Network up and down
                    , Run Network "wlan0" ["-t", "<fn=1>\xf0ab </fn> <rx>kb  <fn=1>\xf0aa </fn> <tx>kb"] 20
                      -- Cpu usage in percent
                    , Run Cpu ["-t", "<fn=1>\xf108 </fn> cpu: (<total>%)","-H","50","--high","red"] 20
                      -- Ram used number and percent
                    , Run Memory ["-t", "<fn=1>\xf233 </fn> mem: <used>M (<usedratio>%)"] 20
                      -- Mpd
                    , Run MPD ["-t","<composer> <title>"] 10
                      -- Battery
                    , Run Battery ["-t", "<acstatus>"
                             , "--Low"      , "20"        -- units: %
                             , "--High"     , "90"        -- units: %
                             , "--low"      , "#bf616a"
                             , "--normal"   , "#88c0d0"
                             , "--high"     , "#81a1c1"

                             , "--" -- battery specific options
                                       -- discharging status
                                       , "-o"	, "<left>% (<timeleft>)"
                                       -- AC "on" status
                                       , "-O"	, "Charging <left>%"
                                       -- charged status
                                       , "-i"	, "Charged"
                             ] 50
                      -- Runs custom script to check for pacman updates.
                      -- This script is in my dotfiles repo in .local/bin.
                    , Run Com "/home/mir/.local/bin/pacupdate" [] "pacupdate" 36000
                      -- Prints out the left side items such as workspaces, layout, etc.
                      -- The workspaces are 'clickable' in my configs.
                    , Run UnsafeStdinReader
                    ]
       , sepChar = "%"
       , alignSep = "}{"
       , template = " <action=`xdotool key control+alt+g`><icon=haskell_20.xpm/> </action><fc=#666666>  |</fc> %UnsafeStdinReader% }{<fc=#666666><fn=2>|</fn> </fc><fc=#666666> <fc=#3B4252> %date%  </fc><fn=2>|</fn></fc> <fc=#D08770> %cpu% </fc><fc=#666666> <fn=2>|</fn></fc> <fc=#BF616A> %memory% </fc><fc=#666666> <fn=2>|</fn></fc> <fc=#81A1C1> <fn=1>  </fn> %battery% </fc><fc=#666666> <fn=2>|</fn></fc> <fc=#8FBCBB> %wlan0% </fc><fc=#666666> <fn=2>|</fn></fc> <fc=#B48EAD><fn=1> </fn> %pacupdate% </fc>"
       }
