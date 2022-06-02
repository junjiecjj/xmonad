import XMonad
import Data.Monoid
import System.Exit
import Graphics.X11.ExtraTypes.XF86

import XMonad.ManageHook

import XMonad.Actions.Minimize

import Data.Map as M
import Data.Maybe

import XMonad.Layout.Accordion
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Simplest

import XMonad.Layout.Gaps
import XMonad.Layout.Spacing
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.Minimize
import XMonad.Layout.LayoutModifier
import XMonad.Layout.SubLayouts

import XMonad.Hooks.ManageDocks
import XMonad.Hooks.SetWMName
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat)
import XMonad.Hooks.WindowSwallowing

import XMonad.Util.Run
import XMonad.Util.SpawnOnce
import XMonad.Util.WorkspaceCompare
import XMonad.Util.EZConfig (additionalKeysP)

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

myTerminal          = "st"
myEmacs             = "emacsclient -c -a 'emacs' "
myFocusFollowsMouse = True
myClickJustFocuses  = False
myBorderWidth       = 2
myModMask           = mod4Mask
myWorkspaces        = ["1","2","3","4","5","6","7","8","9"]
myNormalBorderColor  = "#282C34"
myFocusedBorderColor = "#61AFEF"

mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw True (Border i i i i) True (Border i i i i) True

-- Layouts
tall          = renamed [Replace "Tall"]
                $ minimize
                $ addTabs shrinkText tabTheme
                $ subLayout [] (Simplest)
                $ mySpacing 5
                $ ResizableTall 1 (3/100) (3/5) []

tabs          = renamed [Replace "Tabs"]
                $ tabbed shrinkText tabTheme

floats        = renamed [Replace "Float"]
                $ simplestFloat

accordionTall = renamed [Replace "Tall Accordion"]
                $ mySpacing 5
                $ addTabs shrinkText tabTheme
                $ Accordion

accordionWide = renamed [Replace "Wide Accordion"]
                $ mySpacing 5
                $ addTabs shrinkText tabTheme
                $ Mirror Accordion

tabTheme = def { activeColor         = "#4D4D4D"
               , inactiveColor       = "#282A36"
               , activeBorderColor   = myFocusedBorderColor 
               , inactiveBorderColor = "#282A36"
               }

myKeys :: [(String, X ())]
myKeys =
    -- Xmonad
    [ ("M-q", spawn "xmonad --recompile; xmonad --restart")
    , ("M-S-q", io (exitWith ExitSuccess))

    -- Push window back into tiling
    , ("M-t", withFocused $ windows . W.sink)
    -- Close focused window
    , ("M-S-c", kill)
     -- Rotate through the available layout algorithms
    , ("M-<Tab>", sendMessage NextLayout)

    -- Dmenu scripts
    , ("M-p r", spawn "dmenu_run -p 'Run: ' -h 22 -nb '#282C34' -sf '#282C34' -sb '#61AFEF' -fn 'Hack:pixelsize=12:antohint=true'")
    , ("M-p u", spawn "dm-mount")
    , ("M-p S-u", spawn "dm-unmount")
    , ("M-p a", spawn "dm-android-mount")
    , ("M-p S-a", spawn "dm-android-unmount")
    , ("M-p h", spawn "dm-holoch")

    -- Minimize/maximize window
    , ("M-m", withFocused minimizeWindow)
    , ("M-S-m", withLastMinimized maximizeWindowAndFocus)

    -- Window motion
    , ("M-S-<Return>", windows W.swapMaster)
    , ("M-S-j", windows W.swapDown)
    , ("M-S-k", windows W.swapUp)

    -- Resize master area
    , ("M-h", sendMessage Shrink)
    , ("M-l", sendMessage Expand)

    -- Resize stack
    , ("M-S-h", sendMessage MirrorShrink)
    , ("M-S-l", sendMessage MirrorExpand)

    -- Increase/decrease windows in master area
    , ("M-,", sendMessage (IncMasterN 1))
    , ("M-.", sendMessage (IncMasterN (-1)))

    -- Move focus
    , ("M-j", windows W.focusDown)
    , ("M-k", windows W.focusUp)
    , ("M-<Backspace>", windows W.focusMaster)

      -- Merge/Unmerge focused window to sublayout
    , ("M-C-n", withFocused (sendMessage . UnMerge))

    , ("M-C-h", withFocused (sendMessage . mergeDir W.focusUp')) -- Merge up
    , ("M-C-k", onGroup W.focusUp') -- Switch focus up tabs
    , ("M-C-j", onGroup W.focusDown') -- Switch focus down tabs
    , ("M-C-l", withFocused (sendMessage . mergeDir W.focusDown')) -- Merge Down

    -- Media keys
    , ("M-<F9>", spawn "pamixer -t")
    , ("M-<F10>", spawn "pamixer --allow-boost -d 1")
    , ("M-<F11>", spawn "pamixer --allow-boost -i 1")

    -- Start programs
    , ("M-<Return>", spawn (myTerminal))
    , ("M-a", spawn (myTerminal ++ " pulsemixer"))
    , ("M-o", spawn "scrot -s '%Y-%m-%d_$wx$h.png' -e 'mv $f ~/Pictures/Screenshot/'")
    , ("M-f", spawn (myTerminal ++ " ranger"))
    , ("M-S-f", spawn "pcmanfm")
    , ("M-b", spawn "firefox")
    , ("M-S-b", spawn "qutebrowser")
    , ("M-v", spawn "emacsclient -c")
    , ("M-S-p", spawn "keepassxc")

    -- Emacs
    , ("C-e <Return>", spawn (myEmacs ++ ("--eval '(vterm)'")))
    , ("C-e S-<Return>", spawn (myEmacs ++ ("--eval '(eshell)'")))
    , ("C-e f", spawn (myEmacs ++ ("--eval '(dired nil)'")))
    ]

myWorkspaceIndices = M.fromList $ zipWith (,) myWorkspaces [1..]

clickable ws = "<action=xdotool key super+"++show i++">"++ws++"</action>"
    where i = fromJust $ M.lookup ws myWorkspaceIndices

myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w >> windows W.shiftMaster))
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w >> windows W.shiftMaster))
    ]

myLayout = smartBorders . avoidStruts $ myLayoutConf
  where
    myLayoutConf =  tall
                    ||| tabs
                    ||| accordionTall
                    ||| accordionWide
                    ||| floats 
                    ||| Full

myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll
    [ className =? "confirm"         --> doFloat
    , className =? "file_progress"   --> doFloat
    , className =? "dialog"          --> doFloat
    , className =? "download"        --> doFloat
    , className =? "error"           --> doFloat
    , className =? "notification"    --> doFloat
    , className =? "splash"          --> doFloat
    , className =? "toolbar"         --> doFloat

    , className =? "Signal" --> doShift "3"
    , className =? "discord" --> doShift "3"
    , className =? "Steam" --> doShift "2"

    , isFullscreen -->  doFullFloat
    ]

myHandleEventHook = swallowEventHook (className =? "St") (return True)

myStartupHook = do
  setWMName "LG3D"

main = do
  xmproc0 <- spawnPipe "xmobar $HOME/.config/xmobar/xmobarrc"
  xmonad $ ewmhFullscreen $ docks $ ewmh def{
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,
        mouseBindings      = myMouseBindings,
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myHandleEventHook,
        startupHook        = myStartupHook,
        logHook            = dynamicLogWithPP $ xmobarPP
          { ppOutput = \x -> hPutStrLn xmproc0 x
          , ppCurrent = xmobarColor "#61AFEF" "" . wrap "[" "]"
          , ppHidden = xmobarColor "#ffffff" ""
          , ppHiddenNoWindows = xmobarColor "#5c6370" ""
          , ppTitle = xmobarColor "#56B6C2" "" . shorten 80
          , ppSep =  " | "
          , ppUrgent = xmobarColor "#BE5046" "" . wrap "!" "!"
          , ppLayout = xmobarColor "#98C379" ""
          }
    } `additionalKeysP` myKeys
