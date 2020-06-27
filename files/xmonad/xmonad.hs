import           XMonad
import           XMonad.Layout.Gaps
import qualified Data.Map                      as Map
import qualified XMonad.StackSet               as W
import           System.Process

main :: IO ()
main = do
  _ <- createProcess $ shell "hsetroot -solid '#c7ebf0'"
  xmonad $ def
    { keys               = hotkeys
    , focusFollowsMouse  = False
    , normalBorderColor  = "#c7ebf0"
    , focusedBorderColor = "#e4717a"
    , layoutHook         = gaps [(U, 10), (D, 10), (L, 10), (R, 10)]
                                (Tall 1 (3 / 100) (1 / 2))
    , borderWidth        = 5
    }
 where
  hotkeys conf =
    Map.fromList
      $  [ ((modm .|. controlMask, xK_0), withFocused $ windows . W.sink)
         , ((modm, xK_Return)           , spawn "kitty")
         , ((modm, xK_space)            , spawn "rofi -show drun")
         , ( (modm, xK_r)
           , spawn "killall trayer; xmonad --recompile; xmonad --restart"
           )
         , ((modm, xK_q)                 , kill)
         , ((modm .|. controlMask, left) , windows W.swapUp)
         , ((modm .|. controlMask, right), windows W.swapDown)
         , ((modm, left)                 , windows W.focusUp)
         , ((modm, right)                , windows W.focusDown)
         , ((modm, xK_f)                 , sendMessage NextLayout)
         , ((modm, xK_minus)             , sendMessage Shrink)
         , ((modm, xK_equal)             , sendMessage Expand)
         ]
      ++ [ ((m .|. modm, k), windows $ f i)
         | i      <- [1, 2, 4]
         , k      <- [xK_1 .. xK_9]
         , (f, m) <- [(W.greedyView, 0), (W.shift, controlMask)]
         ]
   where
    modm  = mod4Mask
    left  = xK_e
    right = xK_i
