

import System.IO                   -- hPutStrLn scope
import XMonad
import XMonad.Core

import XMonad.Prompt
import XMonad.Prompt.Shell
import XMonad.Prompt.Man

import XMonad.Layout
import XMonad.Layout.ResizableTile
import XMonad.Layout.Named         -- custom layout names
import XMonad.Layout.NoBorders     -- smart borders on solo clients

import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.DynamicLog     -- statusbar
import XMonad.Hooks.EwmhDesktops   -- fullscreenEventHook fixes chrome fullscreen
import XMonad.Hooks.ManageDocks    -- dock/tray mgmt
import XMonad.Hooks.UrgencyHook    -- window alert bells

import qualified Data.Map as M
import Graphics.X11.Xlib

import XMonad.Util.Run
import XMonad.Util.EZConfig        -- append key/mouse bindings
import XMonad.Util.Run(spawnPipe)  -- spawnPipe and hPutStrLn


import XMonad.Config.Desktop


import XMonad.Actions.CycleWindows -- classic alt-tab
import XMonad.Actions.CycleWS      -- cycle thru WS', toggle last WS
import XMonad.Actions.DwmPromote   -- swap master like dwm

import qualified XMonad.StackSet as W   -- manageHook rules


trayer = "trayer --edge top --align right --SetDockType true --SetPartialStrut true " ++ "--expand true --width 7 --transparent true --tint 0x0c1014 --alpha 0 --height 15"


main = do
        status <- spawnPipe myDzenStatus    -- xmonad status on the left
        -- conky  <- spawnPipe myDzenConky     -- conky stats on the right
        xmonad $ withUrgencyHook NoUrgencyHook $ defaultConfig
            { modMask            = mod4Mask      --快捷前置键, 4是win键，1是alt也是默认的
            , terminal           = "st"          --默认终端
            , borderWidth        = 3             --边框宽度
            , normalBorderColor  = "#dddddd"
            , focusedBorderColor = "#0000ff"
--          , handleEventHook    = fullscreenEventHook -- Only in darcs xmonad-contrib
            , workspaces = myWorkspaces
            , layoutHook = myLayoutHook
            , manageHook = manageDocks <+> myManageHook <+> manageHook defaultConfig
            , logHook    = myLogHook status
            }
            `additionalKeysP` myKeys

-- Prefered terminal
myTerminal = "st"

-- Rebind Mod to Windows key
myModMask = mod4Mask

-- Prompt config
myXPConfig = defaultXPConfig {
  position = Bottom,
  promptBorderWidth = 0,
  font = myFont,
  height = 15,
  bgColor = myBgColor,
  fgColor = myFgColor,
  fgHLight = myHighlightedFgColor,
  bgHLight = myHighlightedBgColor
  }

-- Fonts
myFont = "xft:monospace:size=8"
mySmallFont = "xft:monospace:size=5"

-- Paths
myBitmapsPath = "/home/jack/.dzen/bitmaps/"

-- Colors
myBgBgColor = "black"
myFgColor = "gray80"
myBgColor = "gray20"

myHighlightedFgColor = "white"
myHighlightedBgColor = "gray40"

myActiveBorderColor = "gray20"
myInactiveBorderColor = "gray20"

myCurrentWsFgColor = "white"
myCurrentWsBgColor = "gray40"
myVisibleWsFgColor = "gray80"
myVisibleWsBgColor = "gray20"
myHiddenWsFgColor = "gray80"
myHiddenEmptyWsFgColor = "gray50"
myUrgentWsBgColor = "brown"
myTitleFgColor = "white"

myUrgencyHintFgColor = "white"
myUrgencyHintBgColor = "brown"

-- Bars
myDzenBarGeneralOptions = "-h 15 -fn '" ++ myFont ++ "' -fg '" ++ myFgColor ++
                          "' -bg '" ++ myBgColor ++ "'"

myStatusBar = "dzen2 -w 956 -ta l " ++ myDzenBarGeneralOptions
myCPUBar = "conky -c ~/.conky_cpu | sh | dzen2 -x 956 -w 90 -ta l " ++
           myDzenBarGeneralOptions
myBatteryBar = "conky -c ~/.conky_battery | sh | dzen2 -x 1046 -w 63 -ta l " ++
               myDzenBarGeneralOptions
myTimeBar = "conky -c ~/.conky_time | dzen2 -x 1109 -w 156 -ta c " ++
            myDzenBarGeneralOptions
myXxkbBar = "xxkb" -- configuration in ~/.xxkbrc
myXsetRate = "xset r rate 250 30"


-- Tags/Workspaces
-- clickable workspaces via dzen/xdotool
myWorkspaces            :: [String]
myWorkspaces            = clickable . (map dzenEscape) $ ["1","2","3","4","5"]

  where clickable l     = [ "^ca(1,xdotool key super+" ++ show (n) ++ ")" ++ ws ++ "^ca()" |
                            (i,ws) <- zip [1..] l,
                            let n = i ]

-- Layouts
-- the default layout is fullscreen with smartborders applied to all
myLayoutHook = avoidStruts $ smartBorders ( full ||| mtiled ||| tiled )
  where
    full    = named "X" $ Full
    mtiled  = named "M" $ Mirror tiled
    tiled   = named "T" $ Tall 1 (5/100) (2/(1+(toRational(sqrt(5)::Double))))
    -- sets default tile as: Tall nmaster (delta) (golden ratio)

-- Window management
--
myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Vlc"            --> doFloat
    , className =? "Gimp"           --> doFloat
    , className =? "XCalc"          --> doFloat
    , className =? "Chromium"       --> doF (W.shift (myWorkspaces !! 1)) -- send to ws 2
    , className =? "Nautilus"       --> doF (W.shift (myWorkspaces !! 2)) -- send to ws 3
    , className =? "Gimp"           --> doF (W.shift (myWorkspaces !! 3)) -- send to ws 4
    , className =? "stalonetray"    --> doIgnore
    ]

-- Statusbar
--
myLogHook h = dynamicLogWithPP $ myDzenPP { ppOutput = hPutStrLn h }

myDzenStatus = "dzen2 -w '320' -ta 'l'" ++ myDzenStyle
myDzenStyle  = " -h '20' -fg '#777777' -bg '#222222' -fn 'arial:bold:size=11'"
-- myDzenConky  = "conky -c ~/.xmonad/conkyrc | dzen2 -x '320' -w '704' -ta 'r'" ++ myDzenStyle

myDzenPP  = dzenPP
    { ppCurrent = dzenColor "#3399ff" "" . wrap " " " "
    , ppHidden  = dzenColor "#dddddd" "" . wrap " " " "
    , ppHiddenNoWindows = dzenColor "#777777" "" . wrap " " " "
    , ppUrgent  = dzenColor "#ff0000" "" . wrap " " " "
    , ppSep     = "     "
    , ppLayout  = dzenColor "#aaaaaa" "" . wrap "^ca(1,xdotool key super+space)· " " ·^ca()"
    , ppTitle   = dzenColor "#ffffff" ""
                    . wrap "^ca(1,xdotool key super+k)^ca(2,xdotool key super+shift+c)"
                           "                          ^ca()^ca()" . shorten 20 . dzenEscape
    }

-- Key bindings
--
myKeys = [ ("M-b"                                   , sendMessage ToggleStruts                                  ) -- toggle the status bar gap
         , ("M1-<Tab>"                              , cycleRecentWindows [xK_Alt_L] xK_Tab xK_Tab               ) -- classic alt-tab behaviour
         , ("M-<Return>"                            , dwmpromote                                                ) -- swap the focused window and the master window
         , ("M-<Tab>"                               , toggleWS                                                  ) -- toggle last workspace (super-tab)
         , ("M-<Right>"                             , nextWS                                                    ) -- go to next workspace
         , ("M-<Left>"                              , prevWS                                                    ) -- go to prev workspace
         , ("M-S-<Right>"                           , shiftToNext                                               ) -- move client to next workspace
         , ("M-S-<Left>"                            , shiftToPrev                                               ) -- move client to prev workspace
         , ("M-c"                                   , spawn "xcalc"                                             ) -- calc
         , ("M-p"                                   , spawn "gmrun"                                             ) -- app launcher
         , ("M-n"                                   , spawn "wicd-client -n"                                    ) -- network manager
         , ("M-r"                                   , spawn "xmonad --restart"                                  ) -- restart xmonad w/o recompiling
         , ("M-w"                                   , spawn "chromium"                                          ) -- launch browser
         , ("M-S-w"                                 , spawn "chromium --incognito"                              ) -- launch private browser
         , ("M-e"                                   , spawn "nautilus"                                          ) -- launch file manager
         , ((controlMask, xK_Print)                 , spawn "sleep 0.2; scrot -s"                               ) --
         , ("C-M1-l"                                , spawn "gnome-screensaver-command --lock"                  ) -- lock screen
         , ("M-s"                                   , spawn "urxvtcd -e bash -c 'screen -dRR -S $HOSTNAME'"     ) -- launch screen session
         , ((myModMask  .|.  Control ,  xK_x)       , spawn "xscreensaver-command -lock"                        )
         , ("C-M1-<Delete>"                         , spawn "sudo shutdown -r now"                              ) -- reboot
         , ("C-M1-<Insert>"                         , spawn "sudo shutdown -h now"                              ) -- poweroff
         ]

-- vim:sw=4 sts=4 ts=4 tw=0 et ai
