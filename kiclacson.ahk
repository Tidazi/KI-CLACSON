/*
  kiclacson.ahk
  an accessibility utility by tidazi (2020)
  version: 0.0011 pre-alpha
*/

; Let it run till death but only once.
#Persistent
#SingleInstance force
#Include Lib\JSON.ahk

/*
  Class definitions

  AudioReady:
    a simple object to make the audio ready state
    for sound playback more legible

  ComboState
    simple object for storing combo state information

*/



Class AudioReady
{
  __new(level2,level3,level4)
  {
    this.level2 := level2, this.level3 := level3, this.level4 := level4
  }
}


Class ComboState
{
  __new(Active,CurrentLevel,PreviousLevel)
  {
    this.Active := Active, this.CurrentLevel := CurrentLevel,
    this.PreviousLevel := PreviousLevel
  }
}


/*
  Function definitions

    splitRGBColor
      change from hex to rgb 255 format for color ranges
      written by animeaime of the ahk message boards

    comboActive
      checks if the given color is white enough
      uses the hit counter lettering

    levelCheck
      checks if the provided color (should be combo level box)
      is the right shade of green / green enough

    kiclacsonGui
      main gui function

    colorRange
      function for narrowing down the color range of the combo
      level boxes to eliminate false positives

    checkForWindow
      function to see if the ki clacson gui still exists
      and to kill clacson if it doesn't after 5s

*/


splitRGBColor(RGBColor, ByRef Red, ByRef Green, ByRef Blue)
{
    Red := RGBColor >> 16 & 0xFF
    Green := RGBColor >> 8 & 0xFF
    Blue := RGBColor & 0xFF
}


comboActive(Red,Green,Blue)
{
  if( Red >= 250 and Green >= 250 and Blue >= 250 )
  {
    return 1
  }
  else
  {
    return 0
  }
}


levelCheck(Red,Green,Blue)
{
/*
if( Red >= 225 and Red <= 240 and Green >= 240
    and Blue <= 195 and Blue >= 125 )

if( Red >= 234 and Red <= 240 and Green >= 250
    and Blue <= 190 and Blue >= 182 )
*/
  if( Red <= 240 and Red >= 225 and Green >= 240
      and Blue <= 190 and Blue >= 154 )
  {
    return 1
  }
  else
  {
    return 0
  }
}

global redHigh, redLow, greenHigh, greenLow, blueHigh, blueLow
colorRange(red,green,blue)
{
  if(!redLow)
  {
    redLow := 255
  }
  if(!greenLow)
  {
    greenLow := 255
  }
  if(!blueLow)
  {
    blueLow := 255
  }
  if(red > redHigh)
  {
    redHigh := red
  }
  if(red < redLow)
  {
    redLow := red
  }
  if(green > greenHigh)
  {
    greenHigh := green
  }
  if(green < greenLow)
  {
    greenLow := green
  }
  if(blue > blueHigh)
  {
    blueHigh := blue
  }
  if(blue < blueLow)
  {
    blueLow := blue
  }
}


global boxConfig, stateBox, debugFeed, colorRangeFeed, resolutionBox, configDisplay, currentResolution, checkInterval
kiclacsonGui()
{
  resolutionArrayW := []
  resolutionArrayFS := []
  allResolutions =
  resolutionListW =
  resolutionListFS =
  for k in resolutions
  {
    if(InStr(k,"w"))
    {
      resolutionArrayW.Push(k)
    }
    if(InStr(k,"fs"))
    {
      resolutionArrayFS.Push(k)
    }
    allResolutions .= k
  }
  for k, v in resolutionArrayW
  {
    if(v == config.Resolution)
    {
      resolutionListW.=v . "A|"
    }
    else
    {
      resolutionListW.=v . "|"
    }
  }
  for k, v in resolutionArrayFS
  {
    if(v == config.Resolution)
    {
      resolutionListFS.=v . "A|"
    }
    else
    {
      resolutionListFS.=v . "|"
    }
  }

  Sort,resolutionListW, D| N
  Sort,resolutionListFS, D| N
  resolutionListW := StrReplace(resolutionListW,"A|","||")
  resolutionListFS := StrReplace(resolutionListFS,"A|","||")
  resolutionList := "WINDOWED RESOLUTIONS|" resolutionListW . "FULLSCREEN RESOLUTIONS|" . resolutionListFS

  ;msgbox, % resolutionList
  Gui, kiclacsonGui:New,, KI CLACSON
  Gui, kiclacsonGui:Font,, Fixedsys
  ;Gui, kiclacsonGui:Add, Text,, Configuration
  ;Gui, kiclacsonGui:Add, Edit,  r2 vboxConfig w230
  Gui, kiclacsonGui:Add, Text,, KI Resolution
  Gui, kiclacsonGui:Add, DropDownList, guserChangeResolution vcurrentResolution w230, % resolutionList
  Gui, kiclacsonGui:Add, Text,, Check Interval
  Gui, kiclacsonGui:Add, Edit, r1 vcheckInterval w230 disabled, % config.frameDelay . "f"
  Gui, kiclacsonGui:Add, Text,, Current State
  Gui, kiclacsonGui:Add, Edit,  r2 vstateBox w230 disabled
  if(config.debugMode)
  {
    Gui, kiclacsonGui:Add, Text,, Detected Resolution
    Gui, kiclacsonGui:Add, Edit,  r1 vresolutionBox w230 disabled
    Gui, kiclacsonGui:Add, Text,, Debug Feed
    Gui, kiclacsonGui:Add, Edit,  r4 vdebugFeed w230
    Gui, kiclacsonGui:Add, Text,, Color Range Feed
    Gui, kiclacsonGui:Add, Edit,  r6 vcolorRangeFeed w230
  }

  Gui, kiclacsonGui:Show, W250

  return winexist()

}

userChangeResolution()
{
  GuiControlGet, currentResolution

  if(currentResolution == "WINDOWED RESOLUTIONS" or currentResolution == "FULLSCREEN RESOLUTIONS")
  {
    GuiControl, ChooseString, currentResolution, % config.resolution
  }
  else
  {
    ;msgbox, % currentResolution
    config.resolution := currentResolution
    updateUserSettings()
  }
}

updateUserSettings()
{
  local settingsString, settingsFile
  settingsString := JSON.dump(config)
  settingsFile := FileOpen("settings.json","w")
  settingsFile.write(settingsString)
  settingsFile.close()
  ;msgbox, % settingsString
}

fixSteamKI()
{
  if(!InStr(config.resolution,"fs"))
  {
    WinGetPos,,,kiwinW,kiwinH,Killer Instinct
    kiwinAdjW := kiwinW-16
    kiwinAdjH := kiwinH-41
    ResolutionText = % "" . kiwinAdjW . "x" . kiwinAdjH
    GuiControl, kiclacsonGui:, resolutionBox, % ResolutionText
    confRes := StrSplit(config.resolution, "x")
    confWidth := confRes[1]
    confHeight := confRes[2]

    if(confHeight != kiwinAdjH)
    {
      WinMove,Killer Instinct,,,,(confWidth+16),(confHeight+41)
      ;msgbox, % confWidth  . "x" . confHeight . "`n" . ResolutionText
    }
    else
    {
      ;msgbox, % kiwinAdjW . "x" . kiwinAdjH
    }
  }
  else
  {
    ResolutionText = "(Fullscreen)"
  }
  ;msgbox, % confWidth  . "x" . confHeight
}


checkForWindow()
{
  IfWinNotExist, KI CLACSON
  {
    ExitApp
    Return
  }
}


/*
  KI CLACSON initialization
*/

; load all position values for all resolutions
FileRead, resolutionsString, resolutions.json
global resolutions := JSON.Load(resolutionsString)


; load user settings
FileRead, settingsString, settings.json
global config := JSON.Load(settingsString)
config.Delay := (config.frameDelay * 16)

; assign current position set
global pos := resolutions[config.resolution]
global combo := new ComboState(0,0,0)
global aReady := new AudioReady(1,1,1)


; intialize and position the gui
kiclacsonGui()
WinSet, AlwaysOnTop, On, KI CLACSON
WinGetPos,,,,WinHeight,KI CLACSON
WinMove, KI CLACSON,, 1,(A_ScreenHeight)-(WinHeight)-40

; kill the script if the gui is closed
SetTimer, checkForWindow, 5000 ; check every 5 seconds
SetTimer, fixSteamKI, 2000

; display current configuration
GuiControl,kiclacsonGui:, boxConfig, % "Resolution:  " . config.resolution . "`n" . "Check Every: " . config.frameDelay . "f" . " (" . config.Delay . "ms)"


;IniRead, resolutionIni, resolutions.ini, 1600x900
;msgbox, % resolutionIni

/*
  Main KI CLACSON loop
*/

comboLevelMain()
{
  if WinActive("Killer Instinct")
  {
    ; determine ui side with hit counter lettering
    ; branch into appropriate level detection coordinates

    ; player 1 side check white lettering of hit counter
    PixelGetColor,p1hits,pos.P1HitsX,pos.HitsY,RGB
    splitRGBColor(p1hits,p1Red,p1Green,p1Blue)

    ; player 2 side check white lettering of hit counter
    PixelGetColor,p2hits,pos.P2HitsX,pos.HitsY,RGB
    splitRGBColor(p2hits,p2Red,p2Green,p2Blue)

    ; check if active combo is on p1 side
    if(comboActive(p1Red,p1Green,p1Blue))
    {
      combo.Active := "P1"
      if(config.debugMode)
      {
        p1hitsrgbdebug = HITS RGB: %p1Red%,%p1Green%,%p1Blue%`n
      }
    }
    ; check if active combo is on p2 side
    else if(comboActive(p2Red,p2Green,p2Blue))
    {
      combo.Active := "P2"
      if(config.debugMode)
      {
        p2hitsrgbdebug = HITS RGB: %p2Red%,%p2Green%,%p2Blue%`n
      }
    }
    else
    {
      combo.Active := 0
      GuiControl,kiclacsonGui:, StateBox, Waiting...
    }

    ; check if active combo is on p1 side
    if(combo.Active)
    {
      combo.CurrentLevel := 1

      ; do checks for player 1 side
      if(combo.Active == "P1")
      {
        ; check level 2
        PixelGetColor,p1level2,pos.P1Level2,pos.LevelY,RGB
        splitRGBColor(p1level2,Red,Green,Blue)

        if(config.debugMode)
        {
          p1level2rgbdebug = LVL2 RGB: %Red%,%Green%,%Blue%`n
        }

        if(levelCheck(Red,Green,Blue))
        {
          combo.CurrentLevel := 2
          colorRange(Red,Green,Blue)
        }
        else
        {
          aReady.level2 := 1
        }

        ; check level 3
        PixelGetColor,p1level3,pos.P1Level3,pos.LevelY,RGB
        splitRGBColor(p1level3,Red,Green,Blue)

        if(config.debugMode)
        {
          p1level3rgbdebug = LVL3 RGB: %Red%,%Green%,%Blue%`n
        }

        if(levelCheck(Red,Green,Blue))
        {
          combo.CurrentLevel := 3
          colorRange(Red,Green,Blue)
        }
        else
        {
          aReady.level3 := 1
        }

        ; check level 4
        PixelGetColor,p1level4,pos.P1Level4,pos.LevelY,RGB
        splitRGBColor(p1level4,Red,Green,Blue)

        if(config.debugMode)
        {
          p1level4rgbdebug = LVL4 RGB: %Red%,%Green%,%Blue%
        }

        if(levelCheck(Red,Green,Blue))
        {
          combo.CurrentLevel := 4
          colorRange(Red,Green,Blue)
        }
        else
        {
          aReady.level4 := 1
        }
        DebugRBGValString = %p1hitsrgbdebug%%p1level2rgbdebug%%p1level3rgbdebug%%p1level4rgbdebug%
      }
      if(combo.Active == "P2")
      {
        ; check level 2
        PixelGetColor,p2level2,pos.P2Level2,pos.LevelY,RGB
        splitRGBColor(p2level2,Red,Green,Blue)

        if(config.debugMode)
        {
          p2level2rgbdebug = LVL2 RGB: %Red%,%Green%,%Blue%`n
        }

        if(levelCheck(Red,Green,Blue))
        {
          combo.CurrentLevel := 2
          colorRange(Red,Green,Blue)
        }
        else
        {
          aReady.level2 := 1
        }

        ; check level 3
        PixelGetColor,p2level3,pos.P2Level3,pos.LevelY,RGB
        splitRGBColor(p2level3,Red,Green,Blue)

        if(config.debugMode)
        {
          p2level3rgbdebug = LVL3 RGB: %Red%,%Green%,%Blue%`n
        }

        if(levelCheck(Red,Green,Blue))
        {
          combo.CurrentLevel := 3
          colorRange(Red,Green,Blue)
        }
        else
        {
          aReady.level3 := 1
        }


        ; check level 4
        PixelGetColor,p2level4,pos.P2Level4,pos.LevelY,RGB
        splitRGBColor(p2level4,Red,Green,Blue)

        if(config.debugMode)
        {
          p2level4rgbdebug = LVL4 RGB: %Red%,%Green%,%Blue%
        }

        if(levelCheck(Red,Green,Blue))
        {
          combo.CurrentLevel := 4
          colorRange(Red,Green,Blue)
        }
        else
        {
          aReady.level4 := 1
        }

        DebugRBGValString = %p2hitsrgbdebug%%p2level2rgbdebug%%p2level3rgbdebug%%p2level4rgbdebug%
      }

      ; it won't let me do dynamic object property naming so HECK IT
      if(combo.CurrentLevel > 1 and combo.CurrentLevel > combo.PreviousLevel)
      {
        if(aReady.level2 == 1 and combo.CurrentLevel == 2)
        {
          aReady.level2 := 0
          SoundPlay, % A_WorkingDir . "\sounds\level2.wav"
        }
        if(aReady.level3 == 1 and combo.CurrentLevel == 3)
        {
          aReady.level3 := 0
          SoundPlay, % A_WorkingDir . "\sounds\level3.wav"
        }
        if(aReady.level4 == 1 and combo.CurrentLevel == 4)
        {
          aReady.level4 := 0
          SoundPlay, % A_WorkingDir . "\sounds\level4.wav"
        }
      }
      combo.PreviousLevel := combo.CurrentLevel
      stateMessage = % "Active Side: " . combo.Active . "`nCombo Level: " . combo.CurrentLevel
      GuiControl,kiclacsonGui:, StateBox, %stateMessage%
      GuiControl,kiclacsonGui:, DebugFeed, %DebugRBGValString%
      GuiControl,kiclacsonGui:, colorRangeFeed, % "Red High:   " . redHigh . "`nRed Low:    " . redLow . "`nGreen High: " . greenHigh . "`nGreen Low:  " . greenLow . "`nBlue High:  " . blueHigh . "`nBlue Low:   " . blueLow
    }
    else
    {
      combo.PreviousLevel := 0
      aReady.level2 := 1
      aReady.level3 := 1
      aReady.level4 := 1
      DebugRBGValString =
      GuiControl,kiclacsonGui:, StateBox, Waiting...
      GuiControl,kiclacsonGui:, DebugFeed, %DebugRBGValString%
    }

    }
    else
    {
      GuiControl,kiclacsonGui:, StateBox, Paused...
    }
}


SetTimer,comboLevelMain,% config.Delay



/*
  Define bindings

  cursorGetLocation
    debug function to copy mouse coordinates to the clipboard
    when the user left clicks while holding control and shift.
    intended to make it easier to get coordinates for the
    resolution files


*/





^+LButton::cursorGetLocation()
^+Space::cursorGetLocation()
cursorGetLocation()
{
  if(config.debugMode)
  {
    MouseGetPos, Xm, Ym, id, control
    WinGetTitle, title, ahk_id %id%
    WinGetClass, class, ahk_id %id%
    WinGetPos, Xw, Yw,,, %title%
    Xr := Xm - Xw
    Yr := Ym - Yw
    Xs := Xm - Xws
    Ys := Ym - Yws
    CoordMode, Tooltip, Screen
    PixelGetColor,cursorColor,Xm,Ym,RGB
    splitRGBColor(cursorColor,cRed,cGreen,cBlue)

    clipboard = Relative: %Xr%`,%Yr%`nScreen: %Xm%`,%Ym%`nRBG: %cRed%, %cGreen%, %cBlue%
    ToolTip, Relative: %Xr%`,%Yr%`nScreen: %Xm%`,%Ym%`nRBG: %cRed%`, %cGreen%`, %cBlue%,150,500

    return
  }
}
