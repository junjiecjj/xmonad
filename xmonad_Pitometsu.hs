

--  https://gist.github.com/Pitometsu/3b73effc45ab21f88a758c9bee883126#file-xmobar-hs

-- ~/.xmonad/xmonad.hs

import           System.Exit
import           System.IO
import           XMonad
import           XMonad.Actions.Commands
import           XMonad.Actions.CycleWindows
import           XMonad.Actions.CycleWS
import           XMonad.Actions.UpdatePointer
import           XMonad.Hooks.DynamicLog
import           XMonad.Hooks.EwmhDesktops
import           XMonad.Hooks.ManageDocks
import           XMonad.Hooks.ManageHelpers
import           XMonad.Hooks.SetWMName
import           XMonad.Hooks.UrgencyHook
-- import XMonad.Actions.MouseResize
-- import XMonad.Actions.DynamicWorkspaces
import           XMonad.Layout.Fullscreen            hiding
                                                      (fullscreenEventHook)
-- import XMonad.Layout.BorderResize
import           XMonad.Layout.NoBorders
-- import XMonad.Layout.Grid
-- import XMonad.Layout.Spiral
-- import XMonad.Layout.Circle
import           XMonad.Layout.ResizableTile
-- import           XMonad.Layout.MouseResizableTile
import           XMonad.Layout.MultiColumns
import           XMonad.Layout.MultiToggle
import           XMonad.Layout.MultiToggle.Instances
import           XMonad.Layout.Tabbed
-- import XMonad.Layout.ThreeColumns
import           XMonad.Layout.Spacing
-- import XMonad.Layout.WindowArranger
import           Data.List                           (isPrefixOf)
import qualified Data.Map                            as M
import           Data.Maybe                          (isJust)
import           Graphics.X11.ExtraTypes.XF86
import           XMonad.Core                         (whenJust)
import qualified XMonad.StackSet                     as W
import           XMonad.Util.EZConfig                (additionalKeys)
import           XMonad.Util.Run                     (spawnPipe)

------------------------------------------------------------------------
-- Terminal
-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal = "st"


------------------------------------------------------------------------
-- Workspaces
-- The default number of workspaces (virtual screens) and their names.
--
-- myWorkspaces = {- clickable . (map xmobarEscape) $ -} ["<fn=2>\xf120</fn>","<fn=2>\xf0ac</fn>","<fn=2>\xf0ad</fn>","<fn=2>\xf0eb</fn>","<fn=2>\xf085</fn>"] ++ map show [6..12]
named_ws = [ "<fn=2>\xf120</fn>" -- term
	   , "<fn=2>\xf121</fn>" -- code
           , "<fn=2>\xf0ac</fn>" -- web
           , "<fn=2>\xf0ad</fn>" -- sys
           , "<fn=2>\xf0eb</fn>" -- chat
           , "<fn=2>\xf085</fn>" -- media
           , "<fn=2>\xf1fc</fn>" -- art
           ]
myWorkspaces = clickable workspaces
  where
    workspaces = named_ws ++ unnamed_ws
    unnamed_ws = let l = length named_ws
                     s = max 0 $ 12 - l
                 in take s [[c] | c <- ['Α'..]]
    clickable ws = [ "<action=wmctrl -s " ++ w ++ ">"
                     ++ wrap "." "." name ++
                     "</action>"
                   | (n, name) <- zip [1..length named_ws] ws
                   , let w = show $ n - 1
                   ]

------------------------------------------------------------------------
-- Window rules
-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = composeAll [] {-
  [ className =? "Chromium"       --> doShift (named_ws !! 2)
  , className =? "Google-chrome"  --> doShift (named_ws !! 2)
  , className =? "conkeror"       --> doShift (named_ws !! 2)
  , className =? "firefox"        --> doShift (named_ws !! 2)
  , className =? "Nightly"        --> doShift (named_ws !! 2)
  , resource  =? "desktop_window" --> doIgnore
  , className =? "Steam"          --> doFloat
  , className =? "Gimp"           --> doShift (named_ws !! 5)
  , className =? "Inkscape"       --> doShift (named_ws !! 5)
  , className =? "MPlayer"        --> doFloat
  , className =? "VirtualBox"     --> doShift (named_ws !! 5)
  , className =? "Xchat"          --> doShift (named_ws !! 4)
  , className =? "Skype"          --> doShift (named_ws !! 4)
  , className =? "Emacs"          --> doShift (named_ws !! 3)
  , className =? "stalonetray"    --> doIgnore
  , isFullscreen --> (doF W.focusDown <+> doFullFloat)
  ]
-}

------------------------------------------------------------------------
-- Layouts
-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--

-- TODO: merge behaviour of MultiCol and MouseResizableTile
myLayout =
  mkToggle (NOBORDERS ?? SMARTBORDERS ?? NBFULL ?? EOT) . avoidStruts . smartBorders . mkToggle (single MIRROR) $
    spacing 5 (ResizableTall 1 delta ratio [])
    -- spacing 5 (mouseResizableTile { fracIncrement = delta, masterFrac = ratio, slaveFrac = 0.2, draggerType = BordersDragger }) -- FIXME: mouse focus
    -- ||| spacing 5 (mouseResizableTile { fracIncrement = delta, masterFrac = ratio, slaveFrac = 0.2, draggerType = BordersDragger, isMirrored = True })
    ||| spacing 5 (multiCol [1] 1 delta (-0.5))  -- Many equal columns!
    -- ||| spacing 5 (Mirror $ multiCol [1] 1 delta (-0.5))
            -- ||| ThreeColMid 1 delta ratio
            -- ||| Circle
            -- ||| Grid
            -- ||| spiral ratio
    ||| tabbed shrinkText tabConfig
            -- ||| Full
  -- ) ||| noBorders (fullscreenFull Full)
  where
    ratio = toRational $ 2 / (1 + sqrt 5 :: Double)
    delta = 0.03


------------------------------------------------------------------------
-- Colors and borders
-- Currently based on the ir_black theme.
--
myNormalBorderColor  = "#eee8d5"
myFocusedBorderColor = "#839496"

-- Colors for text and backgrounds of each tab when in "Tabbed" layout.
tabConfig = def
  { activeBorderColor   = "#eee8d5"
  , activeTextColor     = "#657b83"
  , activeColor         = "#fdf6e3"
  , inactiveBorderColor = "#839496"
  , inactiveTextColor   = "#839496"
  , inactiveColor       = "#eee8d5"
  , fontName            = "xft:Inconsolata LGC-8.6"
  , decoHeight          = 18
  }

-- Color of current window title in xmobar.
xmobarTitleColor = "#93a1a1"

-- Color of current workspace in xmobar.
xmobarCurrentWorkspaceColor = "#cb4b16"

-- Width of the window border in pixels.
myBorderWidth = 0


------------------------------------------------------------------------
-- Key bindings
--
-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask = mod4Mask

myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
  ----------------------------------------------------------------------
  -- Custom key bindings
  --

  -- Start a terminal.  Terminal to start is specified by myTerminal variable.
  [ ((modMask .|. shiftMask, xK_Return)
    , spawn $ XMonad.terminal conf)

  -- Lock the screen using xscreensaver.
  , ((modMask .|. controlMask, xK_l)
    , spawn "xscreensaver-command -lock")

  -- Launch clipmenu clipboard manager.
  -- , ((modMask .|. shiftMask, xK_v)
  --   , spawn "$(clipmenu -p 'copy:')")

  -- Launch dmenu via yeganesh.
  -- Use this to launch programs without a key binding.
  -- , ((modMask, xK_p)
  --   , spawn "$(yeganesh -x -- -p 'run:')")

  -- Launch rofi run.
  -- Use this to launch programs without a key binding.
  , ((modMask, xK_r)
    , spawn "$(rofi -show run)")

  -- Launch gmrun.
  -- , ((modMask .|. shiftMask, xK_p)
  --   , spawn "gmrun")

  -- Take a screenshot in select mode.
  -- After pressing this key binding, click a window, or draw a rectangle with
  -- the mouse.
  , ((modMask, xK_Print)
    , spawn "sleep 0.3 ; scrot -s -b \"$HOME/Pictures/%Y-%m-%d-%H%M%S_\\$wx\\$h.png\" -e \"xdg-open \\$f\"")

  -- Take full screenshot in multi-head mode.
  -- That is, take a screenshot of everything you see.
  , ((modMask .|. shiftMask, xK_Print)
    , spawn "scrot -m \"$HOME/Pictures/%Y-%m-%d-%H%M%S_\\$wx\\$h.png\" -e \"xdg-open \\$f\"")

  -- Fetch a single use password.
  , ((modMask .|. shiftMask, xK_o)
    , spawn "fetchotp -x")


  -- Mute volume.
  -- , ((0, xF86XK_AudioMute)
  --   , spawn "amixer -q set Master toggle")

  -- Decrease volume.
  , ((0, xF86XK_AudioLowerVolume)
    , spawn "amixer -q set Master 5%- && ${SHELL} ~/.xmonad/getvolume.sh >> /tmp/.volume-pipe")

  -- Increase volume.
  , ((0, xF86XK_AudioRaiseVolume)
    , spawn "amixer -q set Master 5%+ && ${SHELL} ~/.xmonad/getvolume.sh >> /tmp/.volume-pipe")

  -- Audio previous.
  , ((0, 0x1008FF16)
    , spawn "")

  -- Play/pause.
  , ((0, 0x1008FF14)
    , spawn "")

  -- Audio next.
  , ((0, 0x1008FF17)
    , spawn "")

  -- Eject CD tray.
  , ((0, 0x1008FF2C)
    , spawn "eject -T")

  --------------------------------------------------------------------
  -- "Standard" xmonad key bindings
  --

  -- Close focused window.
  , ((modMask .|. shiftMask, xK_c)
    , kill)

  -- Cycle through the available layout algorithms.
  , ((modMask, xK_space)
    , sendMessage NextLayout)

  --  Reset the layouts on the current workspace to default.
  , ((modMask .|. shiftMask, xK_space)
    , setLayout $ XMonad.layoutHook conf)

  -- Resize viewed windows to the correct size.
  , ((modMask, xK_n)
    , refresh)

  -- Next / Previous workspace
  -- , ((modMask .|. shiftMask,   xK_Page_Down), do
  --        shiftToNext
  --        nextWS)
  -- , ((modMask .|. shiftMask, xK_Page_Up),     do
  --        shiftToPrev
  --        prevWS)
  , ((modMask,                 xK_Page_Down), nextWS)
  , ((modMask,                 xK_Page_Up),   prevWS)
  , ((modMask .|. controlMask, xK_Page_Down),   shiftToNext)
  , ((modMask .|. controlMask, xK_Page_Up),     shiftToPrev)
  , ((modMask .|. shiftMask, xK_Page_Down),   shiftToNext >> nextWS)
  , ((modMask .|. shiftMask, xK_Page_Up),     shiftToPrev >> prevWS)
  -- , ((modMask,                 xK_Down),      nextScreen)
  -- , ((modMask,                 xK_Up),        prevScreen)
  -- , ((modMask .|. controlMask, xK_Down),      shiftNextScreen >> nextScreen)
  -- , ((modMask .|. controlMask, xK_Up),        shiftPrevScreen >> prevScreen)
  , ((modMask .|. mod1Mask,    xK_s),         toggleWS)
  -- , ((modMask .|. shiftMask,  xK_Page_Down), do
  --        shiftNextScreen
  --        nextScreen)
  -- , ((modMask .|. shiftMask, xK_Page_Up),    do
  --        shiftPrevScreen
  --        prevScreen)

  -- Move focus to the next window.
  , ((modMask, xK_g)
    , spawn "$(rofi -show window)")

  -- Move focus to the previous window.
  -- , ((modMask, xK_Tab)
  --  , cycleRecentWindows [xK_Super_L] xK_Shift_R xK_Tab)

  -- Move focus to the next window.
  , ((modMask, xK_k)
    , windows W.focusDown)
  , ((modMask .|. shiftMask, xK_Tab)
    , windows W.focusDown)

  -- Move focus to the previous window.
  , ((modMask, xK_j)
    , windows W.focusUp  )
  , ((modMask, xK_Tab)
    , windows W.focusUp  )

  -- Move focus to the master window.
  , ((modMask, xK_m)
    , windows W.focusMaster)

  -- Swap the focused window and the master window.
  , ((modMask, xK_Return)
    , windows W.swapMaster)

  -- Swap the focused window with the next window.
  , ((modMask .|. shiftMask, xK_k)
    , windows W.swapDown  )

  -- Swap the focused window with the previous window.
  , ((modMask .|. shiftMask, xK_j)
    , windows W.swapUp    )

  -- Shrink the master area.
  , ((modMask, xK_h)
    , sendMessage Shrink)

  -- Expand the master area.
  , ((modMask, xK_l)
    , sendMessage Expand)

  -- Mirror toggle
  , ((modMask, xK_x)
    , sendMessage $ Toggle MIRROR)

  -- Full toggle
  , ((modMask, xK_f)
    , sendMessage $ Toggle NBFULL)

  -- Borders style toggle
  , ((modMask, xK_d)
    , sendMessage (Toggle NOBORDERS) >> sendMessage (Toggle SMARTBORDERS)) -- FIXME not work

  -- Vertical shrink
  , ((modMask, xK_u)
    , sendMessage MirrorShrink)

  -- Vertical expand
  , ((modMask, xK_i)
    , sendMessage MirrorExpand)

  -- -- %! Shrink a slave area
  -- , ((modMask, xK_u)
  --   , sendMessage ShrinkSlave)

  -- -- %! Expand a slave area
  -- , ((modMask, xK_i)
  --   , sendMessage ExpandSlave)

  -- Push window back into tiling.
  , ((modMask, xK_t)
    , withFocused $ windows . W.sink)

  -- Increment the number of windows in the master area.
  , ((modMask, xK_comma)
    , sendMessage (IncMasterN 1))

  -- Decrement the number of windows in the master area.
  , ((modMask, xK_period)
    , sendMessage (IncMasterN (-1)))

  -- Toggle the status bar gap.
  -- TODO: update this binding with avoidStruts, ((modMask, xK_b),

  -- Toggle the status bar gap
  -- Use this binding with avoidStruts from Hooks.ManageDocks.
  -- See also the statusBar function from Hooks.DynamicLog.
  --
  , ((modMask, xK_b )
    , sendMessage ToggleStruts)

  -- Quit xmonad.
  , ((modMask .|. shiftMask, xK_Escape)
    , io (exitWith ExitSuccess))

  -- Restart xmonad.
  , ((modMask, xK_Escape)
    , restart "xmonad" True)
  ]
  ++

  -- mod-[F1..F9], Switch to workspace N
  -- mod-shift-[F1..F9], Move client to workspace N
  [((m .|. modMask, k), windows $ f i)
      | (i, k) <- zip (XMonad.workspaces conf) [xK_F1 .. xK_F9]
      , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]

  -- -- mod-[1..9], Switch to workspace N
  -- -- mod-shift-[1..9], Move client to workspace N
  -- [((m .|. modMask, k), windows $ f i)
  --     | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
  --     , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
  -- ++

  -- -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
  -- -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
  -- [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
  --     | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
  --     , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

------------------------------------------------------------------------
-- Mouse bindings
--
-- Focus rules
-- True if your focus should follow your mouse cursor.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $
  [
    -- mod-button1, Set the window to floating mode and move by dragging
    ((modMask, button1),
     (\w -> focus w >> mouseMoveWindow w))

    -- mod-button2, Raise the window to the top of the stack
    , ((modMask, button2),
       (\w -> focus w >> windows W.swapMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modMask, button3),
       (\w -> focus w >> mouseResizeWindow w))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
  ]


------------------------------------------------------------------------
-- Status bars and logging
-- Perform an arbitrary action on each internal state change or X event.
-- See the 'DynamicLog' extension for examples.
--
-- To emulate dwm's status bar
--
-- > logHook = dynamicLogDzen
--


------------------------------------------------------------------------
-- Startup hook
-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = do
  spawn "xsetroot -cursor_name left_ptr"
  spawn "feh --bg-fill ~/Pictures/nixos_haskell.png"
  spawn "ps cax | grep compton ; if ! [ $? -eq 0 ]; then optirun compton; fi"
  spawn "ps cax | grep stalonetray ; if ! [ $? -eq 0 ]; then stalonetray; fi"
  spawn "ps cax | grep unclutter ; if ! [ $? -eq 0 ]; then unclutter; fi"
  -- spawn "ps cax | grep clipmenud ; if ! [ $? -eq 0 ]; then clipmenud; fi"
  -- spawn "export XMONAD_VOLUME_PIPE=/tmp/.volume-pipe ; if ! [ -p $XMONAD_VOLUME_PIPE ] ; then ; mkfifo $XMONAD_VOLUME_PIPE ; fi && ${SHELL} ~/.xmonad/getvolume.sh >> $XMONAD_VOLUME_PIPE"

------------------------------------------------------------------------
-- Run xmonad with all the defaults we set up.
--
main = do
  xmproc <- spawnPipe "xmobar ~/.xmonad/xmobar.hs"
  xmonad $ withUrgencyHook NoUrgencyHook
         $ ewmh defaults { logHook = do
	                               winset <- gets windowset
                                       dynamicLogWithPP $
                                          let rep' _ _ []       = []
                                              rep' a b s@(x:xs) = if a `isPrefixOf` s
                                                                 then b ++ (drop (length a) s)
                                                                 else x:rep' a b xs
                                              rep _ _ []       = []
                                              rep a b s@(x:xs) = if a `isPrefixOf` s
                                                                 then b ++ rep a b (drop (length a) s)
                                                                 else x:rep a b xs
                                              wrap' a b = rep' "." b . rep' "." a
                                          in xmobarPP { ppOutput = let strip = rep "/fc> " "/fc>" . rep "/action> " "/action>" -- TODO: less hacky
                                                                   in  hPutStrLn xmproc . strip
                                                      , ppTitle = xmobarColor xmobarTitleColor "" . (if isJust (W.peek winset) then ("<action=wmctrl -c :ACTIVE:><fc=#6c71c4><fn=2>\xf00d</fn> </fc></action><action=wmctrl -b toggle,hidden -r :ACTIVE:><fc=#268bd2><fn=2>\xf068</fn> </fc></action><action=wmctrl -b toggle,fullscreen -r :ACTIVE:><fc=#859900><fn=2>\xf067</fn> </fc></action> " ++) else id) . shorten 95
                                                      , ppCurrent = xmobarColor xmobarCurrentWorkspaceColor "" . wrap' "[" "]"
                                                      , ppVisible = wrap' "(" ")"
                                                      , ppSep = "  "
                                                      , ppLayout  = \x -> case x of
                                                          "Mosaic"                         -> "│:│"
                                                          "Spacing 5 ResizableTall"        -> "│A│"
                                                          "Mirror Spacing 5 ResizableTall" -> "│M│"
                                                          "Tabbed Simplest"                -> "│T│"
                                                          "Full"                           -> "│ │"
                                                          "Grid"                           -> "│#│"
                                                          "Circle"                         -> "│O│"
                                                          "Spacing 5 MultiCol"             -> "│I│"
                                                          "Mirror Spacing 5 MultiCol"      -> "│-│"
                                                          "Spiral"                         -> "│@│"
                                                          _                                -> x
                                                      , ppHidden = wrap' "°" " "
                                                      , ppHiddenNoWindows = rep "." " " -- . showNamedWorkspaces
                                                      }
                                       updatePointer (0, 0) (0, 0) -- Nearest
                         , manageHook = manageDocks <+> myManageHook
                         , startupHook = myStartupHook <+> setWMName "LG3D" -- compatability with Java apps
                         , handleEventHook = handleEventHook def <+> fullscreenEventHook
                         }
    where
      showNamedWorkspaces wsId = if any (`elem` wsId) ['a'..'z']
                                 then pad wsId
                                 else ""


------------------------------------------------------------------------
-- Combine it all together
-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--
defaults = def
           { terminal           = myTerminal
           , focusFollowsMouse  = myFocusFollowsMouse
           , borderWidth        = myBorderWidth
           , modMask            = myModMask
           , workspaces         = myWorkspaces
           , normalBorderColor  = myNormalBorderColor
           , focusedBorderColor = myFocusedBorderColor

           -- key bindings
           , keys               = myKeys
           , mouseBindings      = myMouseBindings

           -- hooks, layouts
           , layoutHook         = myLayout
           , manageHook         = myManageHook
           , startupHook        = myStartupHook
           }
