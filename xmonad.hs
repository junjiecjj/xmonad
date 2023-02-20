-- xmonad config used by Malcolm MD
-- https://github.com/randomthought/xmonad-config

import System.IO
import System.Exit
-- import System.Taffybar.Hooks.PagerHints (pagerHints)

import qualified Data.List as L


import XMonad
import XMonad.Actions.Navigation2D
import XMonad.Actions.UpdatePointer
import XMonad.Actions.Minimize
import XMonad.Actions.GridSelect

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Hooks.EwmhDesktops (ewmh)
import XMonad.Hooks.Minimize

import XMonad.Layout.Gaps
import XMonad.Layout.Spiral
import XMonad.Layout.Fullscreen
import XMonad.Layout.BinarySpacePartition as BSP
import XMonad.Layout.NoBorders
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Spacing
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.NoFrillsDecoration
import XMonad.Layout.Renamed
import XMonad.Layout.Simplest
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowNavigation
import XMonad.Layout.ZoomRow
import XMonad.Layout.Minimize
import XMonad.Layout.SimplestFloat
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.Accordion
-- import    XMonad.Layout.Tabbed      (Direction2D (D, L, R, U), Theme (..), addTabs,shrinkText)
import XMonad.Layout.ResizableTile
import XMonad.Layout.NoBorders   ( noBorders, smartBorders)
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.Magnifier (magnifier)
import XMonad.Layout.IndependentScreens

import qualified XMonad.StackSet as StackSet
import XMonad.Layout.IndependentScreens  (VirtualWorkspace)
import qualified XMonad.Util.NamedScratchpad as NamedScratchpad
import qualified XMonad.Actions.CycleWS as CycleWS
import qualified XMonad.Layout.Gaps as Gaps
import qualified XMonad.Layout.PerScreen as PerScreen
import qualified XMonad.Layout.IndependentScreens as IndependentScreens
import qualified Data.Bits as Bits

import XMonad.Util.NamedScratchpad
import XMonad.Util.Cursor
import XMonad.Util.NamedScratchpad (namedScratchpadFilterOutWorkspacePP)

import Graphics.X11.ExtraTypes.XF86
import qualified XMonad.StackSet as W
import qualified Data.Map        as M



import XMonad.Prompt.Input

import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.DynamicLog     -- statusbar
import XMonad.Hooks.EwmhDesktops  (ewmh)  -- fullscreenEventHook fixes chrome fullscreen
import XMonad.Hooks.ManageDocks    -- dock/tray mgmt
import XMonad.Hooks.UrgencyHook    -- window alert bells
import XMonad.Hooks.SetWMName

import XMonad.ManageHook

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



import XMonad.Hooks.FadeInactive
import XMonad.Hooks.UrgencyHook    -- window alert bells
import qualified Data.Map as M
import qualified XMonad.StackSet as W

toggleFloat :: Window -> X ()
toggleFloat w =
  windows
    ( \s ->
        if M.member w (W.floating s)
          then W.sink w s
          else (W.float w (W.RationalRect (1 / 3) (1 / 4) (1 / 2) (1 / 2)) s)
    )

----------------------------mupdf--------------------------------------------
-- Terminimport XMonad.Hooks.EwmhDesktopsal
-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
-- myTerminal = "termite"
myTerminal = "st"

-- The command to lock the screen or show the screensaver.
myScreensaver = "dm-tool switch-to-greeter"

-- The command to take a selective screenshot, where you select
-- what you'd like to capture on the screen.
mySelectScreenshot = "select-screenshot"

-- The command to take a fullscreen screenshot.
myScreenshot = "xfce4-screenshooter"

-- The command to use as a launcher, to launch commands that don't have
-- preset keybindings.
myLauncher = "rofi -show"



------------------------------------------------------------------------
-- Workspaces
-- The default number of workspaces (virtual screens) and their names.
-- -- withScreens <number of screens> <list of workspace names>
-- myWorkspaces = IndependentScreens.withScreens 2  ["1:Browser","2:Code","3:Term","4:File","5:Graph","6:Au/Video"] ++ map show [7..8]

-- myWorkspaces =  ["1:Brows","2:Code","3:Term","4:File","5:Editor","6:Graph","7:Video","8:Music","9:Game"] ++ map show [9]
myWorkspaces =  ["1:Brows","2:CodeIDE","3:Term","4:File","5:Edit","6:Graph","7:Video","8:Music","9:Game","0:remote"]


-- -- Set number of screens
-- numScreens = 2

-- virtualWorkspaces = ["i", "ii", "iii", "iv", "v", "vi", "vii", "viii", "ix", "x"]
-- -- use IndependentScreens to create per-screen workspaces
-- myWorkspaces = withScreens numScreens virtualWorkspaces

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


myScratchPads :: [NamedScratchpad]

myScratchPads = [ NS "terminal" spawnTerm findTerm manageTerm
                , NS "mocp" spawnMocp findMocp manageMocp
                , NS "calculator" spawnCalc findCalc manageCalc
                ]
  where
    spawnTerm  = myTerminal ++ " -t scratchpad"
    findTerm   = title =? "scratchpad"
    manageTerm = customFloating $ W.RationalRect l t w h
               where
                 h = 0.9
                 w = 0.9
                 t = 0.95 -h
                 l = 0.95 -w
    spawnMocp  = myTerminal ++ " -t mocp -e mocp"
    findMocp   = title =? "mocp"
    manageMocp = customFloating $ W.RationalRect l t w h
               where
                 h = 0.9
                 w = 0.9
                 t = 0.95 -h
                 l = 0.95 -w
    spawnCalc  = "qalculate-gtk"
    findCalc   = className =? "Qalculate-gtk"
    manageCalc = customFloating $ W.RationalRect l t w h
               where
                 h = 0.5
                 w = 0.4
                 t = 0.75 -h
                 l = 0.70 -w


myManageHook = composeAll
    [
      className =? "Google-chrome"                --> doShift "2:web"
    , resource  =? "desktop_window"               --> doIgnore
    , className =? "Galculator"                   --> doCenterFloat
    , className =? "Steam"                        --> doCenterFloat
    , className =? "Gimp"                         --> doCenterFloat
    , resource  =? "gpicview"                     --> doCenterFloat
    , className =? "MPlayer"                      --> doCenterFloat
    , className =? "Pavucontrol"                  --> doCenterFloat
    , className =? "Mate-power-preferences"       --> doCenterFloat
    , className =? "Xfce4-power-manager-settings" --> doCenterFloat
    , className =? "VirtualBox"                   --> doShift "4:vm"
    , className =? "Xchat"                        --> doShift "5:media"
    , className =? "stalonetray"                  --> doIgnore
    , isFullscreen                                --> (doF W.focusDown <+> doFullFloat)
    -- , isFullscreen                             --> doFullFloat
    ]<+> namedScratchpadManageHook myScratchPads



------------------------------------------------------------------------
-- Layouts
-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.

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


outerGaps    = 2
myGaps       = gaps [(U, outerGaps), (R, outerGaps), (L, outerGaps), (D, outerGaps)]
addSpace     = renamed [CutWordsLeft 2] . spacing gap
tabBSP          =  avoidStruts
               $ minimize
               $ renamed [Replace "Tabbed"]
               $ addTopBar
               $ myGaps
               $ tabbed shrinkText myTabTheme

myBSP =       renamed [CutWordsLeft 1]
                  $ addTopBar
                  $ windowNavigation
                  $ renamed [Replace "BSP"]
                  $ addTabs shrinkText myTabTheme
                  $ subLayout [] Simplest
                  $ myGaps
                  $ addSpace (BSP.emptyBSP)

tabs          = renamed [Replace "Tabbed"]
                $ tabbed shrinkText tabConfig

tabTheme = def {
    -- fontName  = "xft:CaskaydiaCove Nerd Font Mono:style=SemiLight:pixelsize=12",
    -- fontName  = "xft:CaskaydiaCove Nerd Font Mono SemiLight-14",
    -- fontName  = "xft:CaskaydiaCove Nerd Font Mono-14",
    -- fontName  = "xft:WenQuanYi Micro Hei-15",
    fontName = "xft:WenQuanYi Micro Hei:style=Regular:size=12",
    activeColor         = "#4D4D4D",
    inactiveColor       = "#282A36",
    activeBorderColor   = myFocusedBorderColor,
    inactiveBorderColor = "#282A36"
 }


mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw True (Border i i i i) True (Border i i i i) True

-- Below is a variation of the above except no borders are applied
-- if fewer than two windows. So a single window has no gaps.
mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

-- Layouts
tallA          = renamed [Replace "TallA"]
                $ minimize
                $ addTabs shrinkText myTabTheme
                $ subLayout [] (Simplest)
                $ mySpacing 2
                $ ResizableTall 1 (3/100) (1/2) []

tallB     = renamed [Replace "TallB"]
                $ minimize
                -- $ addTopBar
               $ smartBorders
               $ windowNavigation
               $ addTabs shrinkText myTabTheme
               $ subLayout [] (smartBorders Simplest)
               $ limitWindows 12
               $ mySpacing 2
               $ ResizableTall 1 (3/100) (1/2) []

grid     = renamed [Replace "grid"]
                $ minimize
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 12
           $ mySpacing 2
           $ mkToggle (single MIRROR)
           $ Grid (16/10)

spirals  = renamed [Replace "Spirals"]
                $ minimize
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ mySpacing' 1
           $ spiral (6/7)

floatsA    = renamed [Replace "Float"]
                $ addTopBar
                $ simplestFloat

--floatsB   = renamed [Replace "floats"]
--               $ smartBorders
--               $ limitWindows 20 simplestFloat

magnify  = renamed [Replace "magnify"]
                $ minimize
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ magnifier
           $ limitWindows 12
           $ mySpacing 2
           $ ResizableTall 1 (3/100) (1/2) []

monocle  = renamed [Replace "FullScreen"]
                $ minimize
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 20 Full

threeCol = renamed [Replace "threeCol"]
                $ minimize
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 7
           $ ThreeCol 1 (3/100) (1/2)
threeRow = renamed [Replace "threeRow"]
                $ minimize
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 7
           -- Mirror takes a layout and rotates it by 90 degrees.
           -- So we are applying Mirror to the ThreeCol layout.
           $ Mirror
           $ ThreeCol 1 (3/100) (1/2)

accordionTall = renamed [Replace "Tall Accordion"]
                $ minimize
                -- $ addTopBar
                $ mySpacing 5
                $ addTabs shrinkText myTabTheme
                $ Accordion

accordionWide = renamed [Replace "Wide Accordion"]
                $ minimize
                -- $ addTopBar
                $ mySpacing 5
                $ addTabs shrinkText myTabTheme
                $ Mirror Accordion


----------------------------------------------------------------------------------


layouts      = avoidStruts (
                -- Tall 1 (3/100) (1/2) |||
                -- tallA   |||
                tabs    |||
                tabBSP  |||
                tallB   |||
                myBSP   |||
                monocle  |||
                magnify
                -- threeCol |||
                -- threeRow |||
                -- grid     |||
                -- spirals  |||
                -- Full    |||
                -- accordionWide |||
                -- floatsB
                -- ThreeColMid 1 (3/100) (1/2)
                -- spiral (6/7)  |||
                -- Mirror (Tall 1 (3/100) (1/2) |||
                -- tabbed shrinkText tabConfig |||
                -- accordionTall |||
               )



myLayout    = smartBorders
              $ mkToggle (NOBORDERS ?? FULL ?? EOT)
              $ layouts




myNav2DConf = def
    { defaultTiledNavigation    = centerNavigation
    , floatNavigation           = centerNavigation
    , screenNavigation          = lineNavigation
    , layoutNavigation          = [("Full",          centerNavigation)
    -- line/center same results   ,("Tabs", lineNavigation)
    --                            ,("Tabs", centerNavigation)
                                  ]
    , unmappedWindowRect        = [("Full", singleWindowRect)
    -- works but breaks tab deco  ,("Tabs", singleWindowRect)
    -- doesn't work but deco ok   ,("Tabs", fullScreenRect)
                                  ]
    }


------------------------------------------------------------------------
-- Colors and borders

-- Color of current window title in xmobar.
xmobarTitleColor = "#C678DD"

-- Color of current workspace in xmobar.
xmobarCurrentWorkspaceColor = "#51AFEF"

-- Width of the window border in pixels.
myBorderWidth = 1

myNormalBorderColor     = "#000000"
myFocusedBorderColor    = active

base03  = "#002b36"
base02  = "#073642"
base01  = "#586e75"
base00  = "#657b83"
base0   = "#839496"
base1   = "#93a1a1"
base2   = "#eee8d5"
base3   = "#fdf6e3"
yellow  = "#b58900"
orange  = "#cb4b16"
red     = "#dc322f"
magenta = "#d33682"
violet  = "#6c71c4"
blue    = "#268bd2"
cyan    = "#2aa198"
green   = "#859900"

-- sizes
gap         = 4
topbar      = 7
border      = 1
prompt      = 20
status      = 20

active      = blue
activeWarn  = red
inactive    = base02
focusColor  = blue
unfocusColor = base02

-- myFont      = "-*-Zekton-medium-*-*-*-*-160-*-*-*-*-*-*"
-- myBigFont   = "-*-Zekton-medium-*-*-*-*-240-*-*-*-*-*-*"
-- myFont      = "xft:Zekton:size=9:bold:antialias=true"
-- myFont = "xft:CaskaydiaCove Nerd Font Mono:pixelsize=16"
myFont = "xft:WenQuanYi Micro Hei:style=Regular:size=12"
myBigFont   = "xft:Zekton:size=9:bold:antialias=true"
myWideFont  = "xft:Eurostar Black Extended:"
            ++ "style=Regular:pixelsize=180:hinting=true"

-- this is a "fake title" used as a highlight bar in lieu of full borders
-- (I find this a cleaner and less visually intrusive solution)
topBarTheme = def
    {
      fontName              = myFont
    , inactiveBorderColor   = base03
    , inactiveColor         = base03
    , inactiveTextColor     = base03
    , activeBorderColor     = active
    , activeColor           = active
    , activeTextColor       = active
    , urgentBorderColor     = red
    , urgentTextColor       = yellow
    , decoHeight            = topbar
    }

addTopBar =  noFrillsDeco shrinkText topBarTheme

myTabTheme = def
    { fontName              = myFont
    , activeColor           = active
    , inactiveColor         = base02
    , activeBorderColor     = active
    , inactiveBorderColor   = base02
    , activeTextColor       = base03
    , inactiveTextColor     = base00
    }





------------------------------------------------------------------------

-- Key bindings
--
-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask = mod4Mask
altMask = mod1Mask

myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
  ----------------------------------------------------------------------
  -- Toggle current focus window to fullscreen,
   [

    -- ================================================================================================================
    -- =======================  窗口布局相关快捷键=========================
    -- ================================================================================================================
  -- Cycle through the available layout algorithms.遍历各种窗口布局
   ((modMask.|. shiftMask,   xK_space), sendMessage NextLayout)

  --  Reset the layouts on the current workspace to default.将当前标签页窗口布局模式变为default
  , ((modMask .|. controlMask, xK_space), setLayout $ XMonad.layoutHook conf)

  -- Resize viewed windows to the correct size.
  -- , ((modMask, xK_n),  refresh)

  -- Increment the number of windows in the master area.
  -- 插入主窗格的堆栈，窗口竖向排列. 控制左侧主窗格中显示的窗口数
  , ((modMask .|. shiftMask, xK_h), sendMessage (IncMasterN 1))

  -- Decrement the number of windows in the master area.
  -- 插入主窗格的堆栈，窗口竖向排列. 控制左侧主窗格中显示的窗口数
  , ((modMask .|. shiftMask, xK_l),  sendMessage (IncMasterN (-1)))


  -- Push window back into tiling.将浮动窗口重新变为平铺
  -- , ((modMask, xK_t), withFocused $ windows . W.sink)
  , ((modMask .|. altMask, xK_space), withFocused $ windows . W.sink)
  -- , ((modMask, xK_y), withFocused $ windows .toggleFloat)

  , ((modMask , xK_space), withFocused toggleFloat)

  -- 最大化与还原
  , ((modMask, xK_f), sendMessage $ Toggle FULL)
  --  最小化与还原
  , ((modMask,               xK_m     ), withFocused minimizeWindow)
  , ((modMask .|. shiftMask, xK_m     ), withLastMinimized maximizeWindowAndFocus)

  -- close focused window  Win + Shift + Q: 杀死当前窗口
  , ((modMask .|. shiftMask, xK_q),  kill)

  -- ================================================================================================================
  -- =======================  同一个标签页的窗口间切换,  ====================
  -- ================================================================================================================

  -- Move focus to the next window. 在同一虚拟桌面中的窗口之间切换,包括浮动与平铺
  , ((modMask, xK_k), windows W.focusDown)

  -- Move focus to the previous window. 在同一虚拟桌面中的窗口之间切换,包括浮动与平铺
  , ((modMask, xK_j),  windows W.focusUp  )


  -- Move focus to the next window. 在同一虚拟桌面中的窗口之间切换,包括浮动与平铺
  , ((modMask, xK_w), windows W.focusDown)

  -- Move focus to the previous window. 在同一虚拟桌面中的窗口之间切换,包括浮动与平铺
  , ((modMask, xK_q),  windows W.focusUp  )


  -- Move focus to the next window. 在同一虚拟桌面中的窗口之间切换,包括浮动与平铺
  , ((modMask, xK_period), windows W.focusDown)

  -- Move focus to the previous window. 在同一虚拟桌面中的窗口之间切换,包括浮动与平铺
  , ((modMask, xK_comma),  windows W.focusUp  )

  -- Move focus to the master window.聚焦到主窗口
  -- , ((modMask, xK_m), windows W.focusMaster  )
  , ((modMask .|. controlMask, xK_Return), windows W.focusMaster  )

  -- Swap the focused window and the master window.将当前窗口与主窗口互换，单向
  , ((modMask.|. shiftMask, xK_Return), windows W.swapMaster)

  -- Swap the focused window with the next window.将聚焦的窗口与相邻的窗口交换。
  , ((modMask .|. shiftMask, xK_j), windows W.swapDown  )

  -- Swap the focused window with the previous window.将聚焦的窗口与相邻的窗口交换
  , ((modMask .|. shiftMask, xK_k),  windows W.swapUp    )


  -- ================================================================================================================
  --  窗口大小调整
  -- ================================================================================================================
  -- Shrink the master area.
  -- TallB 模式下上下缩放
  , ((modMask .|. controlMask , xK_9), sendMessage Shrink)
  -- Expand the master area.
  , ((modMask .|. controlMask , xK_0),  sendMessage Expand)
  -- Shrink and expand ratio between the secondary panes, for the ResizableTall layout
  , ((modMask .|. altMask ,          xK_9),       sendMessage MirrorShrink)
  , ((modMask .|. altMask ,          xK_0),       sendMessage MirrorExpand)

  , ((modMask .|. altMask,         xK_Left ),        sendMessage Shrink)
  , ((modMask .|. altMask,         xK_Right ),       sendMessage Expand)
  , ((modMask .|. altMask,         xK_Up ),          sendMessage MirrorShrink)
  , ((modMask .|. altMask,         xK_Down ),        sendMessage MirrorExpand)


  -- modMask .|. shiftMask + 上下左右 是将当前窗口向 上下左右交换/移动

  -- 最大化桌面，不是全屏当前窗口
  , ((modMask       , xK_p     ),                 sendMessage ToggleStruts)
    -- , ("M-S-a", sendMessage Taller)
    -- , ("M-S-z", sendMessage Wider)

  -- myBSP 模式下上下缩放
  , ((modMask, xK_minus),                           sendMessage $ ExpandTowards L)
  , ((modMask, xK_equal),                           sendMessage $ ExpandTowards R)
  , ((modMask .|. shiftMask ,          xK_minus ),  sendMessage $ ExpandTowards U)
  , ((modMask .|. shiftMask,           xK_equal ),  sendMessage $ ExpandTowards D)

  , ((modMask .|. controlMask,         xK_Left ),   sendMessage $ ExpandTowards L)
  , ((modMask .|. controlMask,         xK_Right ),  sendMessage $ ExpandTowards R)
  , ((modMask .|. controlMask,         xK_Up ),     sendMessage $ ExpandTowards U)
  , ((modMask .|. controlMask,         xK_Down ),   sendMessage $ ExpandTowards D)

    -- =============================================================================================================
    -- ======  桌面间切换以及窗口在桌面间移动,和i3很类似，但是有点不同在于：
    --  i3中左右移动窗口到前后的桌面仅限于存在窗口的桌面，但是xmonad左右移动窗口到左右桌面，桌面可以是不存在窗口的桌面，只按序号来
    -- =============================================================================================================
    --  聚焦于下一个桌面(标签页，worspace)
    -- , ((modm,                 xK_Page_Down), nextWS)
    , ((modMask,                 xK_quoteright), nextWS)
    --  聚焦于上一个桌面(标签页，worspace)
    -- , ((modMask,                 xK_Page_Up),   prevWS)
    , ((modMask,                 xK_semicolon),   prevWS)

    --  聚焦于下一个桌面(标签页，worspace)
    , ((modMask,                 xK_s), nextWS)
    --  聚焦于上一个桌面(标签页，worspace)
    , ((modMask,                 xK_a),   prevWS)


    --  聚焦于下一个桌面(标签页，worspace)
    , ((modMask .|. shiftMask,     xK_period), nextWS)
    --  聚焦于上一个桌面(标签页，worspace)
    , ((modMask .|. shiftMask,      xK_comma),   prevWS)

    -- Mod4 + b 快速切换到上一个聚焦的标签页(桌面)
    , ((modMask,    xK_b),         toggleWS)
    , ((modMask,    xK_grave),         toggleWS)



    -- 将当前窗口移动到下一个桌面,但仍然聚焦在当前桌面，桌面按照序号排列，无论有无窗口
    , ((modMask .|. shiftMask,     xK_quoteright ),   shiftToNext)
    -- 将当前窗口移动到上一个桌面,桌面按照序号排列，无论有无窗口
    , ((modMask .|. shiftMask,     xK_semicolon),     shiftToPrev)

    -- 将当前窗口移动到下一个桌面，聚焦到下一个桌面
    , ((modMask .|. controlMask, xK_quoteright),   shiftToNext >> nextWS)
    -- 将当前窗口移动到下一个桌面，聚焦到下一个桌面
    , ((modMask .|. controlMask, xK_semicolon),     shiftToPrev >> prevWS)

    -- =============================================================================================================
    -- ======  显示器间切换以及窗口在显示器间移动
    -- 两个显示器公用所有的桌面，也就是桌面1在显示器1显示就不会在显示器2显示
    -- =============================================================================================================
    -- 切换到上/下一个显示器
    , ((modMask,                   xK_bracketright),       nextScreen)
    , ((modMask,                   xK_Escape),             nextScreen)
    , ((modMask,                   xK_bracketleft),        prevScreen)
    -- , ((modMask .|. controlMask,   xK_period),       nextScreen)
    -- , ((modMask .|. controlMask,   xK_comma),        prevScreen)
    , ((modMask .|. controlMask,   xK_k),       nextScreen)
    , ((modMask .|. controlMask,   xK_j),        prevScreen)
    -- , ((modMask,                   xK_s),            nextScreen)
    -- , ((modMask,                   xK_a),            prevScreen)


    -- 将当前窗口移动到下一个显示器，但仍然聚焦与当前显示器
    , ((modMask .|. shiftMask, xK_bracketright),      shiftNextScreen)
    -- 将当前窗口移动到上一个显示器，但仍然聚焦与当前显示器
    , ((modMask .|. shiftMask, xK_bracketleft),        shiftPrevScreen)

    -- 将当前窗口移动到下一个显示器，聚焦于下一个显示器
    , ((modMask .|. controlMask, xK_bracketright),       shiftNextScreen >> nextScreen)
    -- 将当前窗口移动到上一个显示器，聚焦于上一个显示器
    , ((modMask .|. controlMask, xK_bracketleft),        shiftPrevScreen >> prevScreen)


  -- Mirror toggle
    , ((modMask,                 xK_x)   , sendMessage $ Toggle MIRROR)

  -- ==========================================================================================
  --  APP 快捷键
  -- ==========================================================================================
  -- Custom key bindings
  --

  -- Start a terminal.  Terminal to start is specified by myTerminal variable.
  , ((modMask , xK_Return),
     spawn $ XMonad.terminal conf)

  -- Lock the screen using command specified by myScreensaver.
  --  锁屏
  , ((modMask .|. controlMask, xK_b  ),  spawn "betterlockscreen -l")
  , ((modMask .|. controlMask, xK_x  ),  spawn "xscreensaver-command -lock")
  , ((modMask .|. controlMask, xK_s  ),  spawn "slock")

  -- Spawn the launcher using command specified by myLauncher.
  -- Use this to launch programs without a key binding.
  -- , ((modMask, xK_p), spawn myLauncher)


  -- 启动 dmenu，用于启动各种命令
  , ((modMask,         xK_d     ), spawn "dmenu_run")
  , ((modMask,         xK_x     ), spawn "xterm")

  -- 启动 rofi，用于启动各种命令
  , ((modMask,           xK_r),  spawn "rofi -show combi" )

  , ((modMask .|. controlMask,       xK_t),  spawn "bash ~/.xmonad/script/touchpad.sh" )


  -- change wallpapaer
  ,((modMask .|. shiftMask,  xK_b     ),   spawn  "feh --recursive --randomize --bg-fill $(xdg-user-dir PICTURES)'/Wallpapers/'" )


  -- launch  google-chrome-stale
  , ((modMask ,             xK_g     ), spawn "google-chrome-stable")


  -- launch  typora
  , ((modMask ,             xK_t     ), spawn "typora")

  -- launch  nautilus
  , ((modMask ,             xK_n     ), spawn "nautilus")
  -- launch  thunar
  , ((modMask  .|. shiftMask,     xK_t     ), spawn "thunar")


  -- Take a selective screenshot using the command specified by mySelectScreenshot.
  -- , ((modMask .|. shiftMask, xK_p), spawn mySelectScreenshot)

  -- Take a full screenshot using the command specified by myScreenshot.
  -- , ((modMask .|. controlMask .|. shiftMask, xK_p), spawn myScreenshot)

   -- screenshot screen  截图
  , ((0       , xK_Print), spawn "scrot -cd 3 $(xdg-user-dir PICTURES)/'Scrot_%Y-%m-%d_%H:%M:%S_$wx$h.png' -e 'xclip -selection clipboard -target image/png -i $f; viewnior $f';exec notify-send 'Scrot截图 截取全屏 无GUI 保存指定路径 延迟3s 复制到剪切板 打开查看'")
  , ((modMask    , xK_Print), spawn "scrot $(xdg-user-dir PICTURES)/'Scrot_%Y-%m-%d_%H:%M:%S_$wx$h.png' -e 'xclip -selection clipboard -target image/png -i $f; viewnior $f';exec notify-send 'Scrot截图 截取全屏 无GUI 保存指定路径 不延迟 复制到剪切板 打开查看'")

  -- screenshot window or area  截图
  , ((modMask .|. shiftMask, xK_Print),    spawn "deepin-screenshot ;exec notify-send '深度截图'")
  , ((shiftMask,     xK_Print),    spawn "flameshot gui -p  $(xdg-user-dir PICTURES) -d 2000; exec notify-send '火焰截图 无延时 自己选择截图区域 保存在~/图片'")
  , ((controlMask,   xK_Print),    spawn "flameshot full -c -p  $(xdg-user-dir PICTURES)  -d 2000; exec notify-send '火焰截图 捕获全屏（无GUI）并保存到剪贴板和路径~/图片 延迟2秒'")



  -- ==========================================================================================
  -- =================  音量控制
  -- ==========================================================================================
  -- Mute volume.
  , ((0, xF86XK_AudioMute), spawn "amixer -D pulse set Master 1+ toggle")

  -- Decrease volume.
  , ((0, xF86XK_AudioLowerVolume),  spawn "amixer -q set Master 5%-")

  -- Increase volume.
  , ((0, xF86XK_AudioRaiseVolume), spawn "amixer -q set Master 5%+")

  -- Mute volume.
  , ((0, xF86XK_AudioMute), spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle")

  -- Decrease volume.
  , ((0, xF86XK_AudioLowerVolume),  spawn "pactl set-sink-volume @DEFAULT_SINK@ -8%")

  -- Increase volume.
  , ((0, xF86XK_AudioRaiseVolume), spawn "pactl set-sink-volume @DEFAULT_SINK@ +8%")



  -- Decrease light.
  , ((0, xF86XK_MonBrightnessUp),   spawn "xbacklight -inc 5")

  -- Increase light.
  , ((0, xF86XK_MonBrightnessDown),  spawn "xbacklight -dec 5")

  -- --  音乐播放器 controls
  -- , ((0, XF86AudioPlay), spawn "playerctl play-pause")

  -- , ((0, XF86AudioNext),  spawn "playerctl next")

  -- , ((0, XF86AudioPrev), spawn "playerctl previous")

  --  音乐播放器 controls
  -- , ((0, XF86AudioPlay),  spawn  "mpc toggle")
  -- , ((0, XF86AudioNext),  spawn  "mpc next")
  -- , ((0, XF86AudioPrev),  spawn  "mpc prev")



  -- Mute volume.
  , ((modMask .|. altMask, xK_BackSpace),  spawn "amixer -D pulse set Master 1+ toggle")

  -- Decrease volume.
  , ((modMask .|. altMask, xK_minus),   spawn "amixer -q set Master 5%-")

  -- Increase volume.
  , ((modMask .|. altMask, xK_equal),  spawn "amixer -q set Master 5%+")


  -- Mute volume.
  , ((modMask .|. controlMask, xK_BackSpace),  spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle")

  -- Decrease volume.
  , ((modMask .|. controlMask, xK_minus),   spawn "pactl set-sink-volume @DEFAULT_SINK@ -8%")

  -- Increase volume.
  , ((modMask .|. controlMask, xK_equal),  spawn "pactl set-sink-volume @DEFAULT_SINK@ +8%")



  -- Toggle the status bar gap.
  -- TODO: update this binding with avoidStruts, ((modMask, xK_b),

  -- Quit xmonad. 离开 xmonad
  , ((modMask .|. controlMask, xK_e),
     io (exitWith ExitSuccess))

  -- Restart xmonad.重启 xmonad，用于改为配置之后使其生效
  , ((modMask .|. controlMask, xK_r),  restart "xmonad" True)
  ]
  ++
  [
  -- workspaces are distinct per physical screen
  -- a "windowSet" is a set of windows per virtual screen
  -- onCurrentScreen takes a function that operates on a virtual workspace and window set and returns a function that
  --     operates on a physical workspace and window set
  -- $ avoids parantheses - gives precendence to function on the right
  -- . chains functions
  --     see: https://stackoverflow.com/questions/940382/what-is-the-difference-between-dot-and-dollar-sign
  -- StackSet.view switches to screen
  -- StackSet.shift moves content to another screen
  --
  -- This is a list comprehension that takes each windowSet (set of windows per virtual screen), and maps a view and shift key binding
  -- that operates on the appropriate physical screen
   ((modifierKey Bits..|. myModMask, numberKey), XMonad.windows $ IndependentScreens.onCurrentScreen screenOperation windowSet)
        | (windowSet, numberKey) <- zip (IndependentScreens.workspaces' defaults) [XMonad.xK_1 .. XMonad.xK_9]
        , (screenOperation, modifierKey) <- [(StackSet.view, 0), (StackSet.shift, XMonad.shiftMask)]
  ] ++
  -- mod-[1..9], Switch to workspace N
  -- mod-shift-[1..9], Move client to workspace N
  [((m .|. modMask, k), windows $ f i)
      | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
      , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
  ++

  -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
  -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
  [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
      | (key, sc) <- zip [xK_F6, xK_F7, xK_F8] [0..]
      , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


  ++
  -- Bindings for manage sub tabs in layouts please checkout the link below for reference
  -- https://hackage.haskell.org/package/xmonad-contrib-0.13/docs/XMonad-Layout-SubLayouts.html
  [
    -- Tab current focused window with the window to the left
    ((modMask .|. altMask, xK_h), sendMessage $ pullGroup L)
    -- Tab current focused window with the window to the right
  , ((modMask .|. altMask, xK_l), sendMessage $ pullGroup R)
    -- Tab current focused window with the window above
  , ((modMask .|. altMask, xK_k), sendMessage $ pullGroup U)
    -- Tab current focused window with the window below
  , ((modMask .|. altMask, xK_j), sendMessage $ pullGroup D)

  -- Tab all windows in the current workspace with current window as the focus
  , ((modMask .|. altMask, xK_m), withFocused (sendMessage . MergeAll))
  -- Group the current tabbed windows
  , ((modMask .|. altMask, xK_u), withFocused (sendMessage . UnMerge))

  -- Toggle through tabes from the right
  , ((modMask, xK_Tab), onGroup W.focusDown')
  -- , ((modMask, xK_grave), onGroup W.focusDown')
  ]

  ++
  -- Some bindings for BinarySpacePartition
  -- https://github.com/benweitzman/BinarySpacePartition
  [
  --  myBSP 模式下上下缩放
    ((modMask .|. controlMask .|. shiftMask, xK_Right ), sendMessage $ ShrinkFrom R)
  , ((modMask .|. controlMask .|. shiftMask, xK_Left  ), sendMessage $ ShrinkFrom L)
  , ((modMask .|. controlMask .|. shiftMask, xK_Down  ), sendMessage $ ShrinkFrom D)
  , ((modMask .|. controlMask .|. shiftMask, xK_Up    ), sendMessage $ ShrinkFrom U)
  , ((modMask .|. shiftMask,                  xK_r     ), sendMessage BSP.Rotate)
  , ((modMask .|. shiftMask,               xK_s     ), sendMessage BSP.Swap)
  -- , ((modMask,                               xK_n     ), sendMessage BSP.FocusParent)
  -- , ((modMask .|. controlMask,               xK_n     ), sendMessage BSP.SelectNode)
  -- , ((modMask .|. shiftMask,                 xK_n     ), sendMessage BSP.MoveNode)
  ]

------------------------------------------------------------------------
-- Mouse bindings
--
-- Focus rules
-- True if your focus should follow your mouse cursor.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True


myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $
  [
    --  mod+鼠标左键  将当前窗口变为浮动窗口且移动
    -- mod-button1, Set the window to floating mode and move by dragging
    ((modMask, button1),
     (\w -> focus w >> mouseMoveWindow w))

    -- mod-button2, Raise the window to the top of the stack
    , ((modMask, button2),
       (\w -> focus w >> windows W.swapMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    -- mod+鼠标右键  缩放窗口
    , ((modMask, button3),
       (\w -> focus w >> mouseResizeWindow w))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ,  ((mod4Mask, button4), (\w -> windows W.focusUp))
    ,  ((mod4Mask, button5), (\w -> windows W.focusDown))
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
  setWMName "LG3D"
  spawn     "bash ~/.xmonad/autostart_cjj.sh"
  setDefaultCursor xC_left_ptr

------------------------------------------------------------------------
windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset
------------------------------------------------------------------------
-- Run xmonad with all the defaults we set up.
--
main = do
  xmprocl <- spawnPipe "xmobar --screen=0"
  xmprocr <- spawnPipe "xmobar --screen=1"
  n <- countScreens
  xmprocs <- mapM (\i -> spawnPipe $ "xmobar" ++ " -x " ++ show i) [0..n-1]


  -- xmproc <- spawnPipe "xmobar ~/.xmonad/xmobar/xmobarrc.hs"
  -- xmproc <- spawnPipe "xmobar ~/.xmonad/xmobar/xmobar-dual.hs"

  xmproc0 <- spawnPipe "xmobar -x 0 ~/.xmonad/xmobar/xmobarrc.hs"
  xmproc1 <- spawnPipe "xmobar -x 1 ~/.xmonad/xmobar/xmobarrc1.hs"

  -- xmproc <- spawnPipe "taffybar"
  xmonad $ docks
         $ withNavigation2DConfig myNav2DConf
         $ additionalNav2DKeys (xK_Up, xK_Left, xK_Down, xK_Right)
                               [
                                  (mod4Mask,               windowGo  )
                                , (mod4Mask .|. shiftMask, windowSwap)
                               ]
                               False
         $ ewmh
         -- $ pagerHints -- uncomment to use taffybar
         $ defaults {
          -- logHook = dynamicLogWithPP $ namedScratchpadFilterOutWorkspacePP $ xmobarPP
          logHook = dynamicLogWithPP  xmobarPP
            -- XMOBAR SETTINGS
            { ppOutput = \x -> hPutStrLn xmproc0 x >> hPutStrLn xmproc1 x
            , ppCurrent = xmobarColor "#00ff00" "" . wrap "[" "]" -- Current workspace
            -- , ppVisible = xmobarColor "#98be65" "" -- Visible but not current workspace
            , ppVisible = xmobarColor "#00FF7F" "" -- Visible but not current workspace
            -- , ppHidden = xmobarColor "#82AAFF" "" . wrap "*" "" -- Hidden workspace
            , ppHidden = xmobarColor "#00BFFF" "" . wrap "*" "" -- Hidden workspace
            , ppHiddenNoWindows = xmobarColor "#c792ea" "" -- Hidden workspace
            , ppTitle = xmobarColor "b3afc2" "" . shorten 60 -- Title of active window
            , ppSep = "<fc=#666666> | </fc>" -- Separators
            , ppUrgent = xmobarColor "#C45500" "" . wrap "!" "!" -- Urgent workspace
            , ppExtras = [windowCount]
            , ppOrder = \(ws:l:t:ex) -> [ws,l] ++ ex ++ [t]
            }>> updatePointer (0.75, 0.75) (0.75, 0.75)


         -- logHook = dynamicLogWithPP xmobarPP {
         --          ppCurrent = xmobarColor xmobarCurrentWorkspaceColor "" . wrap "[" "]"
         --        , ppTitle = xmobarColor xmobarTitleColor "" . shorten 50
         --        , ppSep = "   "
         --        -- , ppOutput = hPutStrLn xmproc
         --        , ppOutput = \x -> hPutStrLn xmproc0 x >> hPutStrLn xmproc1 x
         -- } >> updatePointer (0.75, 0.75) (0.75, 0.75)
      }

------------------------------------------------------------------------

------------------------------------------------------------------------
-- Combine it all together
-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--
myHandleEventHook = minimizeEventHook
defaults = def {
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
    layoutHook         = myLayout,
    -- handleEventHook    = E.fullscreenEventHook,
    handleEventHook    = fullscreenEventHook <+> myHandleEventHook,
    manageHook         = manageDocks <+> myManageHook,
    startupHook        = myStartupHook

}
