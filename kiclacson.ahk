/*
  kiclacson.ahk
  an accessibility utility by tidazi (2020)
  version: 0003 pre-alpha
*/

; Let it run till death but only once.
#Persistent
#SingleInstance force

/*
  Class definitions

  config:
    a simple object to make imported config settings
    more legible

  position:
    a simple object to make imported resolution-specific
    coordinates more legible

  audioReady:
    a simple object to make the audio ready state
    for sound playback more legible

*/


Class configuration
{
  __new(Resolution,FrameDelay,DebugMode)
  {
    this.Resolution := Resolution, this.FrameDelay := FrameDelay,
    this.DebugMode := DebugMode, this.Delay := (FrameDelay * 16)
  }
}


Class position
{
  __new(HitsY,LevelY,P1HitsX,P1Level2,P1Level3,P1Level4,P2HitsY,P2Level2,P2Level3,P2Level4)
  {
    this.HitsY := HitsY, this.LevelY := LevelY, this.P1HitsX := P1HitsX,
    this.P1Level2 := P1Level2, this.P1Level3 := P1Level3,
    this.P1Level4 := P1Level4, this.P2HitsY := P2HitsY,
    this.P2Level2 := P2Level2, this.P2Level3 := P2Level3,
    this.P2Level4 := P2Level4
  }
}


Class audioReady
{
  __new(level2,level3,level4)
  {
    this.level2 := level2, this.level3 := level3, this.level4 := level4
  }
}


Class comboState
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

    checkForWindow

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
  if( Red >= 221 and Red <= 237 and Green >= 240
      and Blue <= 187 and Blue >= 125 )
  {
    return 1
  }
  else
  {
    return 0
  }
}


kiclacsonGui()
{
  global boxConfig, stateBox, debugFeed, configDisplay
  Gui, kiclacsonGui:New,, KI CLACSON
  Gui, kiclacsonGui:Font,, Fixedsys
  Gui, kiclacsonGui:Add, Text,, Configuration
  Gui, kiclacsonGui:Add, Edit, Disabled r2 vboxConfig w230
  Gui, kiclacsonGui:Add, Text,, Current State
  Gui, kiclacsonGui:Add, Edit, Disabled r2 vstateBox w230
  if(config.DebugMode)
  {
    Gui, kiclacsonGui:Add, Text,, Debug Feed
    Gui, kiclacsonGui:Add, Edit, Disabled r4 vdebugFeed w230
  }
  GuiControl,, boxConfig, % configDisplay
  Gui, kiclacsonGui:Show, W250

  return winexist()

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

; create temporary objects
tconf := object()
tpos := object()

; open config file
FileRead, ConfigFileContent, config.txt

; populate config object from file
Loop, parse, ConfigFileContent, `,
{
  tconf.push(A_LoopField)
}

; open resolution file
FileRead, ResolutionFileContent, % "resolutions\" . tconf[1] . ".txt"

; populate resolution object from file
Loop, parse, ResolutionFileContent, `,
{
  tpos.push(A_LoopField)
}


global config := new configuration(tconf[1],tconf[2],tconf[3])
global pos := new position(tpos[1],tpos[2],tpos[3],tpos[4],tpos[5],tpos[6],tpos[7],tpos[8],tpos[9],tpos[10])
global combo := new comboState(0,0,0)
global aReady := new audioReady(1,1,1)


; intialize and position the gui
kiclacsonGui()
WinSet, AlwaysOnTop, On, KI CLACSON
WinGetPos,,,,WinHeight,KI CLACSON
WinMove, KI CLACSON,, 1,(A_ScreenHeight)-(WinHeight)-40

; kill the script if the gui is closed
SetTimer, checkForWindow, 5000 ; check every 5 seconds

GuiControl,, boxConfig, % "Resolution:  " . config.Resolution . "`n" . "Check Every: " . config.FrameDelay . "f" . " (" . config.Delay . "ms)"


/*
  Main KI CLACSON loop
*/

Loop
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
      combo["Active"] := "P1"
      if(config.DebugMode)
      {
        p1hitsrgbdebug = RGB: %p1Red%,%p1Green%,%p1Blue%`n
      }
    }
    ; check if active combo is on p2 side
    else if(comboActive(p2Red,p2Green,p2Blue))
    {
      combo["Active"] := "P2"
      if(config.DebugMode)
      {
        p1hitsrgbdebug = RGB: %p2Red%,%p2Green%,%p2Blue%`n
      }
    }
    else
    {
      combo["Active"] := 0
      GuiControl,, StateBox, Waiting...
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
        SplitRGBColor(p1level2,Red,Green,Blue)
        if(config.DebugMode)
        {
          p1level2rgbdebug = RGB: %Red%,%Green%,%Blue%`n
        }
        if(levelCheck(Red,Green,Blue))
        {
          combo.CurrentLevel := 2
        }

        ; check level 3
        PixelGetColor,p1level3,pos.P1Level3,pos.LevelY,RGB
        SplitRGBColor(p1level3,Red,Green,Blue)
        if(config.DebugMode)
        {
          p1level3rgbdebug = RGB: %Red%,%Green%,%Blue%`n
        }
        if(levelCheck(Red,Green,Blue))
        {
          combo.CurrentLevel := 3
        }

        ; check level 4
        PixelGetColor,p1level4,pos.P1Level4,pos.LevelY,RGB
        SplitRGBColor(p1level4,Red,Green,Blue)
        if(config.DebugMode)
        {
          p1level4rgbdebug = RGB: %Red%,%Green%,%Blue%
        }
        if(levelCheck(Red,Green,Blue))
        {
          combo.CurrentLevel := 4
        }
        DebugRBGValString = %p1hitsrgbdebug%%p1level2rgbdebug%%p1level3rgbdebug%%p1level4rgbdebug%
      }
      if(combo.Active == "P2")
      {
        ; check level 2
        PixelGetColor,p2level2,pos.P2Level2,pos.LevelY,RGB
        SplitRGBColor(p2level2,Red,Green,Blue)
        if(config.DebugMode)
        {
          p2level2rgbdebug = RGB: %Red%,%Green%,%Blue%`n
        }

        if(levelCheck(Red,Green,Blue))
        {
          combo.CurrentLevel := 2
        }

        ; check level 3
        PixelGetColor,p2level3,pos.P2Level3,pos.LevelY,RGB
        SplitRGBColor(p2level3,Red,Green,Blue)
        if(levelCheck(Red,Green,Blue))
        {
          combo.CurrentLevel := 3
        }
        if(config.DebugMode)
        {
          p2level3rgbdebug = RGB: %Red%,%Green%,%Blue%`n
        }

        ; check level 4
        PixelGetColor,p2level4,pos.P2Level4,pos.LevelY,RGB
        SplitRGBColor(p2level4,Red,Green,Blue)
        if(levelCheck(Red,Green,Blue))
        {
          combo.CurrentLevel := 4
        }
        if(config.DebugMode)
        {
          p2level4rgbdebug = RGB: %Red%,%Green%,%Blue%
        }
        DebugRBGValString = %p2hitsrgbdebug%%p2level2rgbdebug%%p2level3rgbdebug%%p2level4rgbdebug%
      }


      if(combo.CurrentLevel > 1 and combo.CurrentLevel != combo.PreviousLevel)
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
      combo["PreviousLevel"] = combo.CurrentLevel
      stateMessage = % "Active Side: " . combo.Active . "`nCombo Level: " . combo.CurrentLevel
      GuiControl,, StateBox, %stateMessage%
      GuiControl,, DebugFeed, %DebugRBGValString%
    }
    else
    {
      combo.PreviousLevel := 0
      aReady.level2 := 1
      aReady.level3 := 1
      aReady.level4 := 1
      DebugRBGValString =
      GuiControl,, StateBox, Waiting...
      GuiControl,, DebugFeed, %DebugRBGValString%
    }

    }
    else
    {
      GuiControl,, StateBox, Paused...
    }
  }


/*
  Define bindings

  cursorGetLocation
    debug function to copy mouse coordinates to the clipboard
    when the user left clicks while holding control and shift.
    intended to make it easier to get coordinates for the
    resolution files


*/

^+LButton::cursorGetLocation()


cursorGetLocation()
{
  if(config.DebugMode)
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
    clipboard = Relative: %Xr%`,%Yr%`nScreen: %Xm%`,%Ym%
    return
  }
}
