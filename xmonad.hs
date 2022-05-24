

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


import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.DynamicLog     -- statusbar
import XMonad.Hooks.EwmhDesktops   -- fullscreenEventHook fixes chrome fullscreen
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
-- myWorkspaces    = ["Browser", "code", "Term", "File" , "Chat", "Video", "ﱘMusic", "Graphic", "Game"]
-- myWorkspaces    = ["Browser", "code", "Term", "File" , "Chat", "Video", "Music", "Graphic", "Game"]
-- myWorkspaces    = ["1","2","3","4","5","6","7","8","9"]


------------------------------------------------------------------------
-- Workspaces
-- The default number of workspaces (virtual screens) and their names.
--
-- myWorkspaces = {- clickable . (map xmobarEscape) $ -} ["<fn=2>\xf120</fn>","<fn=2>\xf0ac</fn>","<fn=2>\xf0ad</fn>","<fn=2>\xf0eb</fn>","<fn=2>\xf085</fn>"] ++ map show [6..12]
named_ws = [
           "<fn=2>\xf0ac</fn>"   -- web
           , "<fn=2>\xf121</fn>" -- code
           , "<fn=2>\xf120</fn>" -- term
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

-- 不知道干嘛的
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
    --  窗口布局相关快捷键
    -- ================================================================================================================
     -- Rotate through the available layout algorithms,遍历各种窗口布局
    [ ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default,将当前标签页窗口布局模式变为default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    , ((modm .|. shiftMask, xK_v ), windowPromptBring myXPConfig)
    , ((modm .|. shiftMask, xK_n ), addWorkspacePrompt myXPConfig)

    -- Push window back into tiling,将浮动窗口重新变为平铺
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- -- Increment the number of windows in the master area  插入主窗格的堆栈，窗口竖向排列. 控制左侧主窗格中显示的窗口数。
    -- , ((modm              , xK_comma ), sendMessage (IncMasterN 1))
    -- -- Deincrement the number of windows in the master area  插入主窗格的堆栈，窗口竖向排列. 控制左侧主窗格中显示的窗口数。
    -- , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Increment the number of windows in the master area 插入主窗格的堆栈，窗口竖向排列. 控制左侧主窗格中显示的窗口数。
    , ((modm .|. controlMask    , xK_j ), sendMessage (IncMasterN 1))
    -- Deincrement the number of windows in the master area 插入主窗格的堆栈，窗口竖向排列. 控制左侧主窗格中显示的窗口数。
    , ((modm .|. controlMask    , xK_k), sendMessage (IncMasterN (-1)))


    -- ================================================================================================================
    -- =======================  同一个标签页的窗口间切换,  ====================
    -- ================================================================================================================
    -- Move focus to the next window  Win + j: 在同一虚拟桌面中的窗口之间切换,包括浮动与平铺
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window Win + k: 在同一虚拟桌面中的窗口之间切换,包括浮动与平铺
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the next window  Win + j: 在同一虚拟桌面中的窗口之间切换,包括浮动与平铺
    , ((modm,               xK_w     ), windows W.focusDown)

    -- Move focus to the previous window Win + k: 在同一虚拟桌面中的窗口之间切换,包括浮动与平铺
    , ((modm,               xK_q     ), windows W.focusUp  )

    -- Move focus to the next window  Win + , 在同一虚拟桌面中的窗口之间切换,包括浮动与平铺
    , ((modm,               xK_period     ), windows W.focusDown)

    -- Move focus to the previous window Win + . 在同一虚拟桌面中的窗口之间切换,包括浮动与平铺
    , ((modm,               xK_comma     ), windows W.focusUp  )

    -- Move focus to the master window, 聚焦到主窗口
    , ((modm .|. controlMask, xK_Return), windows W.focusMaster  )

    -- Swap the focused window and the master window，将当前窗口与主窗口互换，单向
    , ((modm .|. shiftMask,  xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window, 将聚焦的窗口与相邻的窗口交换。
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window, 将聚焦的窗口与相邻的窗口交换。
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- ================================================================================================================
    --  窗口大小调整
    -- ================================================================================================================
    -- -- Shrink the master area  调整主窗格和辅助窗格之间的边框大小。
    -- , ((modm,               xK_h     ), sendMessage Shrink)
    -- -- Expand the master area  调整主窗格和辅助窗格之间的边框大小。
    -- , ((modm,               xK_l     ), sendMessage Expand)

    -- Shrink the master area  调整主窗格和辅助窗格之间的边框大小。
    , ((modm,                     xK_minus     ), sendMessage Shrink)

    -- Expand the master area  调整主窗格和辅助窗格之间的边框大小。
    , ((modm,                     xK_equal     ), sendMessage Expand)
    -- , ((modm .|. shiftMask,       xK_equal     ), sendMessage Taller)
    -- , ((modm .|. shiftMask,       xK_equal     ), sendMessage Wider)

    -- =============================================================================================================
    -- ======  桌面间切换以及窗口在桌面间移动,和i3很类似，但是有点不同在于：
    --  i3中左右移动窗口到前后的桌面仅限于存在窗口的桌面，但是xmonad左右移动窗口到左右桌面，桌面可以是不存在窗口的桌面，只按序号来
    -- =============================================================================================================
    --  聚焦于下一个窗口(标签页，worspace)
    -- , ((modm,                 xK_Page_Down), nextWS)
    , ((modm,                   xK_quoteright), nextWS)
    --  聚焦于上一个窗口(标签页，worspace)
    -- , ((modm,                 xK_Page_Up),   prevWS)
    , ((modm,                   xK_semicolon),   prevWS)
    --  聚焦于下一个窗口(标签页，worspace)
    , ((modm .|. shiftMask,     xK_period), nextWS)
    --  聚焦于上一个窗口(标签页，worspace)
    , ((modm .|. shiftMask,      xK_comma),   prevWS)



    -- 将当前窗口移动到下一个桌面,但仍然聚焦在当前桌面，桌面按照序号排列，无论有无窗口
    , ((modm .|. shiftMask,     xK_quoteright ),   shiftToNext)
    -- 将当前窗口移动到上一个桌面,桌面按照序号排列，无论有无窗口
    , ((modm .|. shiftMask,     xK_semicolon),     shiftToPrev)

    -- 将当前窗口移动到下一个桌面，聚焦到下一个桌面
    , ((modm .|. controlMask, xK_quoteright),   shiftToNext >> nextWS)
    -- 将当前窗口移动到下一个桌面，聚焦到下一个桌面
    , ((modm .|. controlMask, xK_semicolon),     shiftToPrev >> prevWS)

    -- 切换到上/下一个显示器
    , ((modm,                   xK_bracketright),       nextScreen)
    , ((modm,                   xK_bracketleft),        prevScreen)
    , ((modm .|. controlMask,   xK_period),       nextScreen)
    , ((modm .|. controlMask,   xK_comma),        prevScreen)


    -- 将当前窗口移动到下一个显示器，但仍然聚焦与当前显示器
    , ((modm .|. shiftMask, xK_bracketright),      shiftNextScreen >> nextScreen)
    -- 将当前窗口移动到上一个显示器，但仍然聚焦与当前显示器
    , ((modm .|. shiftMask, xK_bracketleft),        shiftPrevScreen >> prevScreen)

    -- 将当前窗口移动到下一个显示器，聚焦于下一个显示器
    , ((modm .|. controlMask, xK_bracketright),       shiftNextScreen >> nextScreen)
    -- 将当前窗口移动到上一个显示器，聚焦于上一个显示器
    , ((modm .|. controlMask, xK_bracketleft),        shiftPrevScreen >> prevScreen)

    -- Mod4 + b 快速切换到上一个聚焦的标签页(桌面)
    , ((modm                       ,    xK_b),         toggleWS)


  -- Mirror toggle
    -- , ((modm,                 xK_x)   , sendMessage $ Toggle MIRROR)


    -- ==========================================================================================
    --  APP 快捷键
    -- ==========================================================================================
    -- launch a terminal
      , ((modm,      xK_Return), spawn $ XMonad.terminal conf)
    -- [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- 启动 dmenu，用于启动各种命令
    , ((modm,               xK_d     ), spawn "dmenu_run")

    -- 启动 rofi，用于启动各种命令
    , ((modm,               xK_r     ), spawn "rofi -show combi")

    -- launch gmrun，用于启动各种命令
    , ((modm .|. shiftMask, xK_g     ), spawn "gmrun")

    -- close focused window  Win + Shift + Q: 杀死当前窗口
    , ((modm .|. shiftMask, xK_q     ), kill)

    -- screenshot screen  截图
    , ((0       , xK_Print), spawn "scrot -cd 3 $(xdg-user-dir PICTURES)/'Scrot_%Y-%m-%d_%H:%M:%S_$wx$h.png' -e 'xclip -selection clipboard -target image/png -i $f; viewnior $f'")
    , ((modm    , xK_Print), spawn "scrot -cd 3 $(xdg-user-dir PICTURES)/'Scrot_%Y-%m-%d_%H:%M:%S_$wx$h.png' -e 'viewnior $f'")

    -- screenshot window or area  截图
    , ((modm .|. shiftMask, xK_Print),    spawn "deepin-screenshot")
    , ((shiftMask,          xK_Print),    spawn "flameshot gui -p  $(xdg-user-dir PICTURES) -d 2000")
    , ((controlMask,        xK_Print),    spawn "flameshot full -c -p  $(xdg-user-dir PICTURES)  -d 2000")

    -- -- ÐÞ¸ÄÒôÁ¿
    -- , ((modm, xK_F8 ), lowerVolume 3 >> return ())
    -- , ((modm, xK_F9 ), raiseVolume 3 >> return ())
    -- , ((modm, xK_F10), toggleMute    >> return ())

    -- ²éÑ¯×Öµä
    , ((modm              , xK_s),      getSelection  >>= sdcv)
    , ((modm .|. shiftMask, xK_s),      getPromptInput ?+ sdcv)
    -- , ((modm .|. shiftMask, xK_s),      getDmenuInput >>= sdcv)
    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    , ((modm              , xK_u     ), sendMessage ToggleStruts)
    -- ==========================================================================================
    -- =================  音量控制
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

    -- 锁屏
    , ((modm .|. controlMask, xK_x     ), spawn "xscreensaver-command -lock")
    , ((modm .|. controlMask, xK_l     ), spawn "slock")
    , ((modm .|. controlMask, xK_b     ), spawn "betterlockscreen -l")

    -- change wallpapaer
    ,((modm .|. shiftMask,  xK_b     ),   spawn  "feh --recursive --randomize --bg-fill $(xdg-user-dir PICTURES)'/Wallpapers/'" )

    -- Quit xmonad  Win + Control + e:  离开 xmonad
    , ((modm .|. controlMask, xK_e     ), io (exitWith ExitSuccess))

    -- Restart xmonad  Win + Control + q: 重启 xmonad，用于改为配置之后使其生效
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
    -- Win + 1 – 9: 在 1 – 9 虚拟桌面中进行切换
    -- Win + Shift + 1 – 9: 将当前的窗口移动到指定的虚拟桌面
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{i, o, p}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{i, o, p}, Move client to screen 1, 2, or 3
    -- mod+i/o/p切换光标聚焦到显示器1、2、3，mod+Shift+i/o/p切换当前窗口到显示器1、2、3
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
                  -- 启动 trayer 以显示 systary
                  spawn "trayer --edge top --align right --widthtype percent --width 10 --SetDockType true --SetPartialStrut true --transparent true --alpha 0 --tint 0x000000 --expand true --heighttype pixel --height 25"
                  spawn "ps cax | grep fcitx ; if ! [ $? -eq 0 ]; then fcitx ; fi"
                  spawn "ps cax | grep fcitx5 ; if ! [ $? -eq 0 ]; then fcitx5 ; fi"
                  -- spawn "redshift-gtk  &"
                  spawn "ps cax | grep  redshift-gtk ; if ! [ $? -eq 0 ];          then redshift-gtk ; fi"
                  spawn "ps cax | grep  nm-applet; if ! [ $? -eq 0 ];              then  nm-applet ; fi"
                  spawn "ps cax | grep  blueman-applet; if ! [ $? -eq 0 ];         then  blueman-applet ; fi"
                  spawn "ps cax | grep  picom; if ! [ $? -eq 0 ];                  then  picom --experimental-backends -b; fi"
                  spawn "ps cax | grep  xscreensaver; if ! [ $? -eq 0 ];           then  xscreensaver  -no-splash ; fi"
                  spawn "ps cax | grep  flameshot; if ! [ $? -eq 0 ];              then   flameshot ; fi"
                  spawn "ps cax | grep  dunst; if ! [ $? -eq 0 ];                  then  dunst ; fi"
                  spawn "ps cax | grep  copyq; if ! [ $? -eq 0 ];                  then  copyq ; fi"
                  spawn "ps cax | grep  pasystray; if ! [ $? -eq 0 ];              then  pasystray  ; fi"
                  spawn "ps cax | grep  kmix; if ! [ $? -eq 0 ];                   then  kmix   ; fi"
                  spawn "ps cax | grep  pa-applet; if ! [ $? -eq 0 ];              then /foo/bar/bin/pa-applet ; fi"
                  spawn "ps cax | grep  mictray; if ! [ $? -eq 0 ];                then   mictray  ; fi"
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
                  setDefaultCursor xC_left_ptr    -- 设置鼠标样式
                  spawn "feh --recursive  --bg-fill $(xdg-user-dir PICTURES)'/Wallpapers/background.jpg'"
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


