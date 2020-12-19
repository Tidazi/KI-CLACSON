
/*
  Define bindings

  cursorGetLocation
    debug function to copy mouse coordinates to the clipboard
    when the user left clicks while holding control and shift.
    intended to make it easier to get coordinates for the
    resolution files


*/


global cursorColor, Xr, Yr, Xm, Ym, cRed,cGreen,cBlue
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
  PixelGetColor,cursorColor,Xr,Yr,RGB
  splitRGBColor(cursorColor,cRed,cGreen,cBlue)
  GuiControl,kiclacsonGui:, mouseFeed, Relative: %Xr%`,%Yr%`nScreen: %Xm%`,%Ym%`nRBG: %cRed%, %cGreen%, %cBlue%
  ;Mouse: %Xm%/%Ym%`n
}



cursorGetLocation()
{
  if(config.debugMode)
  {
    clipboard = Relative: %Xr%`,%Yr%`nScreen: %Xm%`,%Ym%`nRBG: %cRed%, %cGreen%, %cBlue%
    ;GuiControl,kiclacsonGui:, mouseFeed, Relative: %Xr%`,%Yr%`nScreen: %Xm%`,%Ym%`nRBG: %cRed%, %cGreen%, %cBlue%
    return
  }
}
