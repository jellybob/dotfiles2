import XMonad
import XMonad.Layout.Tabbed
import XMonad.Layout.NoBorders
import XMonad.Config.Gnome
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.EZConfig
import XMonad.Actions.CycleWS
import qualified DBus as D
import qualified DBus.Client as D
import qualified Codec.Binary.UTF8.String as UTF8
import Data.Ratio ((%))

main :: IO ()
main = do
	dbus <- D.connectSession
	getWellKnownName dbus
	xmonad $ gnomeConfig { modMask = mod4Mask 
	                     , logHook = dynamicLogWithPP (prettyPrinter dbus) 
                       , layoutHook = layouts }
		`additionalKeysP`
		[ ("M-u", prevScreen)
		, ("M-i", nextScreen)
		, ("M-S-u", shiftPrevScreen >> prevScreen)
		, ("M-S-i", shiftNextScreen >> nextScreen)
		, ("M-r", gnomeRun) ]

prettyPrinter :: D.Client -> PP
prettyPrinter dbus = defaultPP
    { ppOutput   = dbusOutput dbus
    , ppTitle    = pangoColor "white" . pangoSanitize
    , ppCurrent  = wrap "<b>" "</b>" . pangoSanitize
    , ppVisible  = pangoColor "steelblue" . pangoSanitize
    , ppHidden   = pangoColor "gray40" . pangoSanitize
    , ppUrgent   = pangoColor "red"
    , ppLayout   = const ""
    , ppSep      = "  |  "
    }

layouts = avoidStruts (smartBorders (tiled ||| Mirror tiled ||| Full ||| simpleTabbed))
          where
            tiled = Tall nmaster delta ratio
            nmaster = 1     -- Number of master windows
            ratio = 2%3     -- The amount of the screen the master pane takes
            delta = 5%100   -- The proportion to increment size by

-- A huge amount of stuff for the panel applet
getWellKnownName :: D.Client -> IO ()
getWellKnownName dbus = do
  D.requestName dbus (D.busName_ "org.xmonad.Log")
                [D.nameAllowReplacement, D.nameReplaceExisting, D.nameDoNotQueue]
  return ()

dbusOutput :: D.Client -> String -> IO ()
dbusOutput dbus str = do
    let signal = (D.signal (D.objectPath_ "/org/xmonad/Log") (D.interfaceName_ "org.xmonad.Log") (D.memberName_ "Update")) {
            D.signalBody = [D.toVariant ((UTF8.decodeString str))]
        }
    D.emit dbus signal

pangoColor :: String -> String -> String
pangoColor fg = wrap left right
  where
    left  = "<span foreground=\"" ++ fg ++ "\">"
    right = "</span>"

pangoSanitize :: String -> String
pangoSanitize = foldr sanitize ""
  where
    sanitize '>'  xs = "&gt;" ++ xs
    sanitize '<'  xs = "&lt;" ++ xs
    sanitize '\"' xs = "&quot;" ++ xs
    sanitize '&'  xs = "&amp;" ++ xs
    sanitize x    xs = x:xs
