

import System.IO                   -- hPutStrLn scope
import XMonad
-- import XMonad.Core


import Data.Monoid
import Data.Char
import System.Exit

import XMonad.ManageHook

import XMonad.Prompt
-- import XMonad.Prompt.Shell
-- import XMonad.Prompt.Man
import XMonad.Prompt.Input
import System.Posix.Process (createSession, executeFile, forkProcess)

-- import XMonad.Layout
-- import XMonad.Layout.ResizableTile
-- import XMonad.Layout.Named         -- custom layout names
import XMonad.Layout.NoBorders     -- smart borders on solo clients
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Fullscreen
import XMonad.Layout.Spiral
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances

import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.DynamicLog     -- statusbar
import XMonad.Hooks.EwmhDesktops  (ewmh)  -- fullscreenEventHook fixes chrome fullscreen
import XMonad.Hooks.ManageDocks    -- dock/tray mgmt
import XMonad.Hooks.UrgencyHook    -- window alert bells
import XMonad.Hooks.SetWMName

import Graphics.X11.Xlib

import XMonad.Util.Run
-- import XMonad.Util.EZConfig        -- append key/mouse bindings
import XMonad.Util.Run(spawnPipe)    -- spawnPipe and hPutStrLn
import XMonad.Util.Cursor
import XMonad.Util.XSelection
import XMonad.Util.XUtils
import XMonad.Util.EZConfig(additionalKeys)
import Graphics.X11.ExtraTypes.XF86


import XMonad.Config.Desktop



import XMonad.Actions.DynamicWorkspaces
import XMonad.Actions.CycleWindows -- classic alt-tab
import XMonad.Actions.CycleWS      -- cycle thru WS', toggle last WS
import XMonad.Actions.DwmPromote   -- swap master like dwm
-- import XMonad.Actions.Volume


import qualified Data.Map as M
import qualified XMonad.StackSet as W   -- manageHook rules

import XMonad.Prompt
import XMonad.Prompt.Input
import XMonad.Prompt.Man
import XMonad.Prompt.RunOrRaise
import XMonad.Prompt.Shell
import XMonad.Prompt.Window
import XMonad.Prompt.Workspace



-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
-- Prefered terminal
myTerminal = "st"




-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Width of the window border in pixels.
--
myBorderWidth   = 2

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
-- Rebind Mod to Windows key
myModMask       = mod4Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
-- myWorkspaces    = ["???Browser", "???code", "???Term", "???File" , "???Chat", "???Video", "???Music", "???Graphic", "???Game"]
-- myWorkspaces    = ["Browser", "code", "Term", "File" , "Chat", "Video", "Music", "Graphic", "Game"]
-- myWorkspaces    = ["1","2","3","4","5","6","7","8","9"]


-- myWorkspaces = ["1: term","2: web","3: code","4:file","5: media","6:chat"] ++ map show [7..9]
------------------------------------------------------------------------
-- Workspaces
-- The default number of workspaces (virtual screens) and their names.
--
-- myWorkspaces = {- clickable . (map xmobarEscape) $ -} ["<fn=2>\xf120</fn>","<fn=2>\xf0ac</fn>","<fn=2>\xf0ad</fn>","<fn=2>\xf0eb</fn>","<fn=2>\xf085</fn>"] ++ map show [6..12]
named_ws = [
           "<fn=2>\xf0ac</fn>Browser"   -- web
           , "<fn=2>\xf121</fn>Code" -- code
           , "<fn=2>\xf120</fn>Term" -- term
           , "<fn=2>\xf130</fn>File" -- file
           , "<fn=2>\xf0ad</fn>Sys" -- sys
           , "<fn=2>\xf124</fn>Chat" -- chat
           , "<fn=2>\xf085</fn>Media" -- media
           , "<fn=2>\xf1fc</fn>Art" -- art
           ]
myWorkspaces = clickable workspaces
  where
    workspaces = named_ws ++ unnamed_ws
    unnamed_ws = let l = length named_ws
                     s = max 0 $ 12 - l
                 in take s [[c] | c <- ['??'..]]
    clickable ws = [ "<action=wmctrl -s " ++ w ++ ">"
                     ++ wrap "." "." name ++
                     "</action>"
                   | (n, name) <- zip [1..length named_ws] ws
                   , let w = show $ n - 1
                   ]


-- Location of your xmobar.hs / xmobarrc
myXmobarrc = "~/.xmonad/xmobar/xmobar-dual.hs"


myPromptKeymap = M.union defaultXPKeymap $ M.fromList
                 [
                   ((controlMask, xK_g), quit)
                 , ((controlMask, xK_m), setSuccess True >> setDone True)
                 , ((controlMask, xK_j), setSuccess True >> setDone True)
                 , ((controlMask, xK_h), deleteString Prev)
                 , ((controlMask, xK_f), moveCursor Next)
                 , ((controlMask, xK_b), moveCursor Prev)
                 , ((controlMask, xK_p), moveHistory W.focusDown')
                 , ((controlMask, xK_n), moveHistory W.focusUp')
                 , ((mod1Mask, xK_p), moveHistory W.focusDown')
                 , ((mod1Mask, xK_n), moveHistory W.focusUp')
                 , ((mod1Mask, xK_b), moveWord Prev)
                 , ((mod1Mask, xK_f), moveWord Next)
                 ]

-- ??????????????????
myXPConfig = defaultXPConfig
    { font = "xft:CaskaydiaCove Nerd Font Mono:pixelsize=16"
    , bgColor           = "#0c1021"
    , fgColor           = "#f8f8f8"
    , fgHLight          = "#f8f8f8"
    , bgHLight          = "steelblue3"
    , borderColor       = "DarkOrange"
    , promptBorderWidth = 1
    , position          = Top
    , historyFilter     = deleteConsecutive
    , promptKeymap = myPromptKeymap
    }



------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- ================================================================================================================
    -- =======================  ???????????????????????????=========================
    -- ================================================================================================================
     -- Rotate through the available layout algorithms,????????????????????????
    [ ((modm .|. shiftMask,   xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default,??????????????????????????????????????????default
    , ((modm .|. controlMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    , ((modm .|. shiftMask, xK_v ), windowPromptBring myXPConfig)
    , ((modm .|. shiftMask, xK_n ), addWorkspacePrompt myXPConfig)

    -- Push window back into tiling,?????????????????????????????????
    , ((modm,               xK_space     ), withFocused $ windows . W.sink)

    -- -- Resize viewed windows to the correct size
    -- , ((modm,               xK_n     ), refresh)

    -- -- Increment the number of windows in the master area  ?????????????????????????????????????????????. ?????????????????????????????????????????????
    -- , ((modm              , xK_comma ), sendMessage (IncMasterN 1))
    -- -- Deincrement the number of windows in the master area  ?????????????????????????????????????????????. ?????????????????????????????????????????????
    -- , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Increment the number of windows in the master area ?????????????????????????????????????????????. ?????????????????????????????????????????????
    , ((modm .|. controlMask    , xK_j ), sendMessage (IncMasterN 1))
    -- Deincrement the number of windows in the master area ?????????????????????????????????????????????. ?????????????????????????????????????????????
    , ((modm .|. controlMask    , xK_k), sendMessage (IncMasterN (-1)))

    --  Toggle current focus window to fullscreen
    , ((modm, xK_f), sendMessage $ Toggle FULL)
    -- ================================================================================================================
    -- =======================  ????????????????????????????????????,  ====================
    -- ================================================================================================================
    -- Move focus to the next window  Win + j: ?????????????????????????????????????????????,?????????????????????
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window Win + k: ?????????????????????????????????????????????,?????????????????????
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the next window  Win + j: ?????????????????????????????????????????????,?????????????????????
    , ((modm,               xK_w     ), windows W.focusDown)

    -- Move focus to the previous window Win + k: ?????????????????????????????????????????????,?????????????????????
    , ((modm,               xK_q     ), windows W.focusUp  )

    -- Move focus to the next window  Win + , ?????????????????????????????????????????????,?????????????????????
    , ((modm,               xK_period     ), windows W.focusDown)

    -- Move focus to the previous window Win + . ?????????????????????????????????????????????,?????????????????????
    , ((modm,               xK_comma     ), windows W.focusUp  )

    -- Move focus to the master window, ??????????????????
    , ((modm .|. controlMask, xK_Return), windows W.focusMaster  )

    -- Swap the focused window and the master window?????????????????????????????????????????????
    , ((modm .|. shiftMask,  xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window, ?????????????????????????????????????????????
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window, ?????????????????????????????????????????????
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- ================================================================================================================
    --  ??????????????????
    -- ================================================================================================================
    -- -- Shrink the master area  ??????????????????????????????????????????????????????
    -- , ((modm,               xK_h     ), sendMessage Shrink)
    -- -- Expand the master area  ??????????????????????????????????????????????????????
    -- , ((modm,               xK_l     ), sendMessage Expand)

    -- Shrink the master area  ??????????????????????????????????????????????????????
    , ((modm,                     xK_minus     ), sendMessage Shrink)

    -- Expand the master area  ??????????????????????????????????????????????????????
    , ((modm,                     xK_equal     ), sendMessage Expand)
    -- , ((modm .|. shiftMask,       xK_equal     ), sendMessage Taller)
    -- , ((modm .|. shiftMask,       xK_equal     ), sendMessage Wider)

    -- =============================================================================================================
    -- ======  ?????????????????????????????????????????????,???i3???????????????????????????????????????
    --  i3??????????????????????????????????????????????????????????????????????????????xmonad?????????????????????????????????????????????????????????????????????????????????????????????
    -- =============================================================================================================
    --  ????????????????????????(????????????worspace)
    -- , ((modm,                 xK_Page_Down), nextWS)
    , ((modm,                   xK_quoteright), nextWS)
    --  ????????????????????????(????????????worspace)
    -- , ((modm,                 xK_Page_Up),   prevWS)
    , ((modm,                   xK_semicolon),   prevWS)
    --  ????????????????????????(????????????worspace)
    , ((modm .|. shiftMask,     xK_period), nextWS)
    --  ????????????????????????(????????????worspace)
    , ((modm .|. shiftMask,      xK_comma),   prevWS)



    -- ???????????????????????????????????????,??????????????????????????????????????????????????????????????????????????????
    , ((modm .|. shiftMask,     xK_quoteright ),   shiftToNext)
    -- ???????????????????????????????????????,?????????????????????????????????????????????
    , ((modm .|. shiftMask,     xK_semicolon),     shiftToPrev)

    -- ??????????????????????????????????????????????????????????????????
    , ((modm .|. controlMask, xK_quoteright),   shiftToNext >> nextWS)
    -- ??????????????????????????????????????????????????????????????????
    , ((modm .|. controlMask, xK_semicolon),     shiftToPrev >> prevWS)


    -- =============================================================================================================
    -- ======  ???????????????????????????????????????????????????
    -- =============================================================================================================
    -- ????????????/??????????????????
    , ((modm,                   xK_bracketright),       nextScreen)
    , ((modm,                   xK_bracketleft),        prevScreen)
    , ((modm .|. controlMask,   xK_period),       nextScreen)
    , ((modm .|. controlMask,   xK_comma),        prevScreen)

    -- ??????????????????????????????????????????????????????????????????????????????
    , ((modm .|. shiftMask, xK_bracketright),      shiftNextScreen >> nextScreen)
    -- ??????????????????????????????????????????????????????????????????????????????
    , ((modm .|. shiftMask, xK_bracketleft),        shiftPrevScreen >> prevScreen)

    -- ????????????????????????????????????????????????????????????????????????
    , ((modm .|. controlMask, xK_bracketright),       shiftNextScreen >> nextScreen)
    -- ????????????????????????????????????????????????????????????????????????
    , ((modm .|. controlMask, xK_bracketleft),        shiftPrevScreen >> prevScreen)

    -- Mod4 + b ??????????????????????????????????????????(??????)
    , ((modm                       ,    xK_b),         toggleWS)


  -- Mirror toggle
    -- , ((modm,                 xK_x)   , sendMessage $ Toggle MIRROR)


    -- ==========================================================================================
    --  APP ?????????
    -- ==========================================================================================
    -- launch a terminal
      , ((modm,      xK_Return), spawn $ XMonad.terminal conf)
    -- [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- ?????? dmenu???????????????????????????
    , ((modm,               xK_d     ), spawn "dmenu_run")

    -- ?????? rofi???????????????????????????
    , ((modm,               xK_r     ), spawn "rofi -show combi")

    -- launch gmrun???????????????????????????
    , ((modm .|. shiftMask, xK_g     ), spawn "gmrun")

    -- close focused window  Win + Shift + Q: ??????????????????
    , ((modm .|. shiftMask, xK_q     ), kill)


    -- launch  google-chrome-stale
    , ((modm ,             xK_g     ), spawn "google-chrome-stable")


    -- launch  typora
    , ((modm ,             xK_t     ), spawn "typora")

    -- launch  nautilus
    , ((modm ,             xK_n     ), spawn "nautilus")
    -- launch  thunar
    , ((modm  .|. shiftMask,     xK_t     ), spawn "thunar")

    -- screenshot screen  ??????
    , ((0       , xK_Print), spawn "scrot -cd 3 $(xdg-user-dir PICTURES)/'Scrot_%Y-%m-%d_%H:%M:%S_$wx$h.png' -e 'xclip -selection clipboard -target image/png -i $f; viewnior $f'")
    , ((modm    , xK_Print), spawn "scrot -cd 3 $(xdg-user-dir PICTURES)/'Scrot_%Y-%m-%d_%H:%M:%S_$wx$h.png' -e 'viewnior $f'")

    -- screenshot window or area  ??????
    , ((modm .|. shiftMask, xK_Print),    spawn "deepin-screenshot")
    , ((shiftMask,          xK_Print),    spawn "flameshot gui -p  $(xdg-user-dir PICTURES) -d 2000")
    , ((controlMask,        xK_Print),    spawn "flameshot full -c -p  $(xdg-user-dir PICTURES)  -d 2000")

    -- -- ????????????????
    -- , ((modm, xK_F8 ), lowerVolume 3 >> return ())
    -- , ((modm, xK_F9 ), raiseVolume 3 >> return ())
    -- , ((modm, xK_F10), toggleMute    >> return ())

    -- ????????????????
    , ((modm              , xK_s),      getSelection  >>= sdcv)
    , ((modm .|. shiftMask, xK_s),      getPromptInput ?+ sdcv)
    -- , ((modm .|. shiftMask, xK_s),      getDmenuInput >>= sdcv)
    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    , ((modm              , xK_u     ), sendMessage ToggleStruts)
    -- ==========================================================================================
    -- =================  ????????????
    -- ==========================================================================================
    , ((0, xF86XK_AudioMute), spawn "amixer -D pulse set Master 1+ toggle")

    -- Decrease volume.
    , ((0, xF86XK_AudioLowerVolume),  spawn "amixer -q set Master 5%-")

    -- Increase volume.
    , ((0, xF86XK_AudioRaiseVolume),  spawn "amixer -q set Master 5%+")

    -- Mute volume.
    , ((modm .|. controlMask, xK_BackSpace),  spawn "amixer -D pulse set Master 1+ toggle")

    -- Decrease volume.
    , ((modm .|. controlMask, xK_minus),   spawn "amixer -q set Master 5%-")

    -- Increase volume.
    , ((modm .|. controlMask, xK_equal),  spawn "amixer -q set Master 5%+")

    -- ??????
    , ((modm .|. controlMask, xK_x     ), spawn "xscreensaver-command -lock")
    , ((modm .|. controlMask, xK_l     ), spawn "slock")
    , ((modm .|. controlMask, xK_b     ), spawn "betterlockscreen -l")

    -- change wallpapaer
    ,((modm .|. shiftMask,  xK_b     ),   spawn  "feh --recursive --randomize --bg-fill $(xdg-user-dir PICTURES)'/Wallpapers/'" )

    -- Quit xmonad  Win + Control + e:  ?????? xmonad
    , ((modm .|. controlMask, xK_e     ), io (exitWith ExitSuccess))

    -- Restart xmonad  Win + Control + q: ?????? xmonad???????????????????????????????????????
    , ((modm .|. controlMask, xK_r     ), spawn "xmonad --recompile; xmonad --restart")
    ]
    ++

    -- -- mod-[F1..F9], Switch to workspace N
    -- -- mod-shift-[F1..F9], Move client to workspace N
    -- [((m .|. modMask, k), windows $ f i)
    --     | (i, k) <- zip (XMonad.workspaces conf) [xK_F1 .. xK_F9]
    --     , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    -- Win + 1 ??? 9: ??? 1 ??? 9 ???????????????????????????
    -- Win + Shift + 1 ??? 9: ????????????????????????????????????????????????
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{i, o, p}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{i, o, p}, Move client to screen 1, 2, or 3
    -- mod+i/o/p??????????????????????????????1???2???3???mod+Shift+i/o/p??????????????????????????????1???2???3
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_i, xK_o, xK_p] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
-- myLayout = smartBorders $ onWorkspace "X" (Full ||| tiled ||| Mirror tiled) (tiled ||| Mirror tiled ||| Full)
--   where
--      -- default tiling algorithm partitions the screen into two panes
--      tiled   = Tall nmaster delta ratio
--      -- The default number of windows in the master pane
--      nmaster = 1
--      -- Default proportion of screen occupied by master pane
--      ratio   = 1/2
--      -- Percent of screen to increment by when resizing panes
--      delta   = 3/100


myLayout = avoidStruts (
    Tall 1 (3/100) (1/2) |||
    ThreeColMid 1 (3/100) (1/2) |||
    Mirror (Tall 1 (3/100) (1/2)) |||
    tabbed shrinkText tabConfig |||
    Full |||
    spiral (6/7)) -- |||
    -- noBorders (fullscreenFull Full)

-- Colors for text and backgrounds of each tab when in "Tabbed" layout.
tabConfig = defaultTheme {
    -- fontName  = "xft:CaskaydiaCove Nerd Font Mono:style=SemiLight:pixelsize=12",
    -- fontName  = "xft:CaskaydiaCove Nerd Font Mono SemiLight-14",
    -- fontName  = "xft:CaskaydiaCove Nerd Font Mono-14",
    -- fontName  = "xft:WenQuanYi Micro Hei-15",
    fontName = "xft:WenQuanYi Micro Hei:style=Regular:size=12",
    activeBorderColor = "#7C7C7C",
    activeTextColor = "#00ff00",
    activeColor = "#7C7C7C",
    inactiveBorderColor = "#000000",
    inactiveTextColor = "#EEEEEE",
    inactiveColor = "#000000"
}

------------------------------------------------------------------------
-- Window rules:

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
myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    -- , isFullscreen                  --> doFullFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore
    , className =? "Firefox"        --> doShift "W"
    , className =? "Pidgin"         --> doShift "I"
    , className =? "VirtualBox"     --> doShift "X"
    , isFullscreen --> (doF W.focusDown <+> doFullFloat)
    , className =? "Google-chrome"  --> doShift "W"
    , className =? "Steam"          --> doFloat
    , className =? "stalonetray"                  --> doIgnore
    ]


------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
-- myEventHook = mempty

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
--myLogHook = return ()
myLogHook = dynamicLog



------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
--myStartupHook = return ()
myStartupHook = do
                  -- ?????? trayer ????????? systary
                  -- spawn "trayer --edge top --align right --widthtype percent --width 10 --SetDockType true --SetPartialStrut true --transparent true --alpha 0 --tint 0x000000 --expand true --heighttype pixel --height 25"
                  -- spawn "ps cax | grep fcitx ; if ! [ $? -eq 0 ]; then fcitx ; fi"
                  -- spawn "ps cax | grep fcitx5 ; if ! [ $? -eq 0 ]; then fcitx5 ; fi"
                  -- -- spawn "redshift-gtk  &"
                  -- spawn "ps cax | grep  redshift-gtk ; if ! [ $? -eq 0 ];          then redshift-gtk ; fi"
                  -- spawn "ps cax | grep  nm-applet; if ! [ $? -eq 0 ];              then  nm-applet ; fi"
                  -- spawn "ps cax | grep  blueman-applet; if ! [ $? -eq 0 ];         then  blueman-applet ; fi"
                  -- spawn "ps cax | grep  picom; if ! [ $? -eq 0 ];                  then  picom --experimental-backends -b; fi"
                  -- spawn "ps cax | grep  xscreensaver; if ! [ $? -eq 0 ];           then  xscreensaver  -no-splash ; fi"
                  -- spawn "ps cax | grep  flameshot; if ! [ $? -eq 0 ];              then   flameshot ; fi"
                  -- spawn "ps cax | grep  dunst; if ! [ $? -eq 0 ];                  then  dunst ; fi"
                  -- spawn "ps cax | grep  copyq; if ! [ $? -eq 0 ];                  then  copyq ; fi"
                  -- spawn "ps cax | grep  pasystray; if ! [ $? -eq 0 ];              then  pasystray  ; fi"
                  -- spawn "ps cax | grep  kmix; if ! [ $? -eq 0 ];                   then  kmix   ; fi"
                  -- spawn "ps cax | grep  pa-applet; if ! [ $? -eq 0 ];              then /foo/bar/bin/pa-applet ; fi"
                  -- spawn "ps cax | grep  mictray; if ! [ $? -eq 0 ];                then   mictray  ; fi"
                  -- spawn "nm-applet &"
                  -- spawn "blueman-applet &"
                  -- spawn "picom --experimental-backends -b "
                  -- spawn "xscreensaver  -no-splash &"
                  -- spawn "nohup  flameshot >/dev/null 2>&1 &"
                  -- spawn "dunst &"
                  -- spawn "copyq &"
                  -- spawn "nohup pasystray  >/dev/null 2>&1 &"
                  -- spawn "nohup kmix   >/dev/null 2>&1 &"
                  -- spawn "nohup /foo/bar/bin/pa-applet   >/dev/null 2>&1 &"
                  -- spawn "nohup mictray   >/dev/null 2>&1 &"
                  spawn     "bash ~/.xmonad/autostart_cjj.sh"
                  setDefaultCursor xC_left_ptr    -- ??????????????????
                  -- spawn "feh --recursive  --bg-fill $(xdg-user-dir PICTURES)'/Wallpapers/background.jpg'"
                  -- spawn "volti"


-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor  = "#dddddd"
myFocusedBorderColor = "#00ff00"




-- Color of current window title in xmobar.
xmobarTitleColor = "#FFB6B0"

-- Color of current workspace in xmobar.
xmobarCurrentWorkspaceColor = "#CEFFAC"

-- Colors
myBgBgColor = "black"
myFgColor = "gray80"
myBgColor = "gray20"

myHighlightedFgColor = "white"
myHighlightedBgColor = "gray40"


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


-- Fonts
myFont = "xft:monospace:size=8"
mySmallFont = "xft:monospace:size=5"




-- Bars
myDzenBarGeneralOptions = "-h 15 -fn '" ++ myFont ++ "' -fg '" ++ myFgColor ++
                          "' -bg '" ++ myBgColor ++ "'"

myStatusBar = "dzen2 -w 956 -ta l " ++ myDzenBarGeneralOptions

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
-- main = xmonad =<< xmobar defaults


main = do
    -- myStatusBarPipe <- spawnPipe myStatusBar
    xmproc <- spawnPipe ("xmobar " ++ myXmobarrc)
    xmonad  $ defaults {
         logHook = dynamicLogWithPP $ xmobarPP {
             ppOutput = hPutStrLn xmproc,
             ppTitle = xmobarColor xmobarTitleColor "" . shorten 100,
             ppCurrent = xmobarColor xmobarCurrentWorkspaceColor "",
             ppSep = "  "
       }
  }


-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--
defaults = defaultConfig {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        -- layoutHook         = myLayout,
        layoutHook         = smartBorders $ myLayout,
        -- manageHook         = myManageHook,
        manageHook = manageDocks <+> myManageHook,
        handleEventHook    = docksEventHook,
        -- handleEventHook    = fullscreenEventHook,
        -- logHook            = myLogHook,
        startupHook        = myStartupHook
    }

--getDmenuInput = fmap (filter isPrint) $ runProcessWithInput "dmenu" ["-p", "Dict: "] ""
getPromptInput = inputPrompt defaultXPConfig "Dict: "

sdcv word = do
    output <- runProcessWithInput "sdcv" ["-n", word] ""
    mySafeSpawn "notify-send" [word, trString output]

trString = foldl (\s c -> s ++ (trChar c)) ""

trChar c
    | c == '<' = "&lt;"
    | c == '>' = "&gt;"
    | c == '&' = "&amp;"
    | otherwise = [c]

mySafeSpawn :: MonadIO m => FilePath -> [String] -> m ()
mySafeSpawn prog args = io $ void_ $ forkProcess $ do
    uninstallSignalHandlers
    _ <- createSession
    executeFile prog True args Nothing
        where void_ = (>> return ()) -- TODO: replace with Control.Monad.void / void not in ghc6 apparently


