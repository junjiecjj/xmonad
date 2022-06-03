import XMonad hiding ((|||))
import qualified XMonad.StackSet as W
import qualified Data.Map        as M

-- Useful for rofi
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys, additionalKeysP, additionalMouseBindings)
import System.IO
import System.Exit
-- Last window
import XMonad.Actions.GroupNavigation
-- Last workspace. Seems to conflict with the last window hook though so just
-- disabled it.
-- import XMonad.Actions.CycleWS
-- import XMonad.Hooks.WorkspaceHistory (workspaceHistoryHook)
import XMonad.Layout.Tabbed
import XMonad.Hooks.InsertPosition
import XMonad.Layout.SimpleDecoration (shrinkText)
-- Imitate dynamicLogXinerama layout
import XMonad.Util.WorkspaceCompare
import XMonad.Hooks.ManageHelpers
-- Order screens by physical location
import XMonad.Actions.PhysicalScreens
import Data.Default
-- For getSortByXineramaPhysicalRule
import XMonad.Layout.LayoutCombinators
-- smartBorders and noBorders
import XMonad.Layout.NoBorders
-- spacing between tiles
import XMonad.Layout.Spacing
-- Insert new tabs to the right: https://stackoverflow.com/questions/50666868/how-to-modify-order-of-tabbed-windows-in-xmonad?rq=1
-- import XMonad.Hooks.InsertPosition

--- Layouts
-- Resizable tile layout
import XMonad.Layout.ResizableTile
-- Simple two pane layout.
import XMonad.Layout.TwoPane
import XMonad.Layout.BinarySpacePartition
import XMonad.Layout.Dwindle

myTabConfig = def { activeColor = "#556064"
                  , inactiveColor = "#2F3D44"
                  , urgentColor = "#FDF6E3"
                  , activeBorderColor = "#454948"
                  , inactiveBorderColor = "#454948"
                  , urgentBorderColor = "#268BD2"
                  , activeTextColor = "#80FFF9"
                  , inactiveTextColor = "#1ABC9C"
                  , urgentTextColor = "#1ABC9C"
                  , fontName = "xft:Noto Sans CJK:size=10:antialias=true"
                  }

myLayout = avoidStruts $
  noBorders (tabbed shrinkText myTabConfig)
  ||| tiled
  ||| Mirror tiled
  -- ||| noBorders Full
  ||| twopane
  ||| Mirror twopane
  ||| emptyBSP
  ||| Spiral L XMonad.Layout.Dwindle.CW (3/2) (11/10) -- L means the non-main windows are put to the left.

  where
     -- The last parameter is fraction to multiply the slave window heights
     -- with. Useless here.
     tiled = spacing 3 $ ResizableTall nmaster delta ratio []
     -- In this layout the second pane will only show the focused window.
     twopane = spacing 3 $ TwoPane delta ratio
     -- The default number of windows in the master pane
     nmaster = 1
     -- Default proportion of screen occupied by master pane
     ratio   = 1/2
     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

myPP = def { ppCurrent = xmobarColor "#1ABC9C" "" . wrap "[" "]"
           , ppTitle = xmobarColor "#1ABC9C" "" . shorten 60
           , ppVisible = wrap "(" ")"
           , ppUrgent  = xmobarColor "red" "yellow"
           , ppSort = getSortByXineramaPhysicalRule def
           }

myManageHook = composeAll [ isFullscreen --> doFullFloat

                          ]

myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- close focused window
    , ((modm .|. shiftMask, xK_q     ), kill)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)
    , ((modm .|. shiftMask, xK_h), sendMessage $ JumpToLayout "Mirror Tall")
    , ((modm .|. shiftMask, xK_v), sendMessage $ JumpToLayout "Tall")
    , ((modm .|. shiftMask, xK_f), sendMessage $ JumpToLayout "Full")
    , ((modm .|. shiftMask, xK_t), sendMessage $ JumpToLayout "Tabbed Simplest")

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)

    -- Shrink and expand ratio between the secondary panes, for the ResizableTall layout
    , ((modm .|. shiftMask,               xK_h), sendMessage MirrorShrink)
    , ((modm .|. shiftMask,               xK_l), sendMessage MirrorExpand)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    , ((modm              , xK_b     ), sendMessage ToggleStruts)
    , ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s")
    , ((0, xK_Print), spawn "scrot") -- 0 means no extra modifier key needs to be pressed in this case.
    , ((modm, xK_F3), spawn "pcmanfm")
    , ((modm.|. shiftMask, xK_F3), spawn "gksu pcmanfm")
    ]

    ++
      [((m .|. modm, k), windows $ f i)
      | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
      , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++
      [((m .|. modm, key), f sc)
      | (key, sc) <- zip [xK_a, xK_s, xK_d] [0..]
      -- Order screen by physical order instead of arbitrary numberings.
      , (f, m) <- [(viewScreen def, 0), (sendToScreen def, shiftMask)]]

main = do
    xmproc <- spawnPipe "xmobar"
    xmonad $ ewmh def
        { modMask = mod4Mask
        , keys = myKeys
        , manageHook = manageDocks <+> myManageHook
        , layoutHook = myLayout
        , handleEventHook = handleEventHook def <+> docksEventHook
        , logHook = dynamicLogWithPP myPP {
                                          ppOutput = hPutStrLn xmproc
                                          }
                        >> historyHook
        , terminal = "lxterminal"
        -- This is the color of the borders of the windows themselves.
        , normalBorderColor  = "#2f3d44"
        , focusedBorderColor = "#1ABC9C"
        }
        `additionalKeysP`
        [
          ("M1-<Space>", spawn "rofi -combi-modi window,run,drun -show combi -modi combi")
          , ("C-M1-<Space>", spawn "rofi -show run")
          -- Restart xmonad. This is the same keybinding as from i3
          , ("M-S-c", spawn "xmonad --recompile; xmonad --restart")
          , ("M-S-q", kill)
          , ("M-'", windows W.swapMaster)
          , ("M1-<Tab>", nextMatch History (return True))
          , ("M-<Return>", spawn "lxterminal")
          -- Make it really hard to mispress...
          , ("M-M1-S-e", io (exitWith ExitSuccess))
          , ("M-M1-S-l", spawn "i3lock")
          , ("M-M1-S-s", spawn "i3lock && systemctl suspend")
          , ("M-M1-S-h", spawn "i3lock && systemctl hibernate")
        ] `additionalMouseBindings`
        [ ((mod4Mask, button4), (\w -> windows W.focusUp))
        , ((mod4Mask, button5), (\w -> windows W.focusDown))
        ]

