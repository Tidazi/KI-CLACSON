
/*
  Define bindings

  cursorGetLocation
    debug function to copy mouse coordinates to the clipboard
    when the user left clicks while holding control and shift.
    intended to make it easier to get coordinates for the
    resolution files


*/


global cursorColor, Xr, Yr, Xm, Ym, cRed,cGreen,cBlue, mouseFeedString
WatchCursor()
{
  MouseGetPos, Xm, Ym, id, control
  WinGetTitle, title, ahk_id %id%
  WinGetClass, class, ahk_id %id%
  WinGetPos, Xw, Yw,,, %title%
  Xr := Xm - Xw
  Yr := Ym - Yw
  Xs := Xm - Xws
  Ys := Ym - Yws
  ;PixelGetColor,cursorColor,Xr,Yr,RGB
  cursorColor := Gdip_GetPixel(kicap, Xm, Ym)
  splitARGBColor(cursorColor,cRed,cGreen,cBlue)
  if(Xw)
  {
    cursorString := "Relative: " . Xr . "," . Yr . "`n"
  }
  Else
  {
    cursorString := "Relative:`n"
  }
  cursorString2 := "Screen:   " . Xm . "," . Ym . "`n" . "RBG:      " . cRed . "," . cGreen . "," . cBlue
  mouseFeedString := cursorString . cursorString2
  GuiControl,kiclacsonGui:, mouseFeed, % mouseFeedString
}



cursorGetLocation()
{
  if(config.debugMode)
  {
    clipboard = %mouseFeedString%
    ;GuiControl,kiclacsonGui:, mouseFeed, Relative: %Xr%`,%Yr%`nScreen: %Xm%`,%Ym%`nRBG: %cRed%, %cGreen%, %cBlue%
    return
  }
}
