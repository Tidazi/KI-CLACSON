;clacson.ahk
;an accessibility utility by tidazi (2020)
;
;so long as the resulting script is open source and offered for free,
; anyone may use this script for anything they want
;makes use of the hex to rgb + splitrgbcolor function
; by animeaime of the ahk message boards


;there can only be one! ... instance of this utility.
#SingleInstance,Force

;are we in debug mode?
clacsonDebugMode = 0

;get coords from mouse relative to window if in debug mode
if(clacsonDebugMode)
{
  SetTimer, WatchCursor, 50
  DetectHiddenWindows, On ; for special win
  CoordMode, Mouse, Screen
}

;display cursor position in tooltip
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
  ToolTip, Relative: %Xr%/%Yr%
  ;Mouse: %Xm%/%Ym%`n
}


;create config object
clacson_ConfigObj := object()

;create resolution object
clacson_ResObj := object()

;clacson is not active yet
clacson_active = 0

;zero out previous combo level on startup
clacson_PrevComboLevel = 0

;set audio ready for all combo levels
clacson_AR2 = 1
clacson_AR3 = 1
clacson_AR4 = 1

;debug rgb clear
DebugRBGValString =

;open config file
FileRead, ConfigFileContent, clacson_config.txt

;populate config object from file
Loop, parse, ConfigFileContent, `,
{
  clacson_ConfigObj.push(A_LoopField)
}

clacsonActiveResolution = % "" . clacson_ConfigObj[1]

resolutionFilename = resolutions\%clacsonActiveResolution%.txt

;open resolution file
FileRead, ResolutionFileContent, %resolutionFilename%

;test resolution coordinates
clacson_ResCoordsDebug =
; %resolutionFilename%

;populate resolution object from file
Loop, parse, ResolutionFileContent, `,
{
  clacson_ResObj.push(A_LoopField)
  ;clacson_ResCoordsDebug = %clacson_ResCoordsDebug%%A_LoopField%`n
}

clacson_coords_hits_y := clacson_ResObj[1]
clacson_coords_level_y := clacson_ResObj[2]
clacson_coords_p1_hits_x := clacson_ResObj[3]
clacson_coords_p1_lvl2_x := clacson_ResObj[4]
clacson_coords_p1_lvl3_x := clacson_ResObj[5]
clacson_coords_p1_lvl4_x := clacson_ResObj[6]
clacson_coords_p2_hits_x := clacson_ResObj[7]
clacson_coords_p2_lvl2_x := clacson_ResObj[8]
clacson_coords_p2_lvl3_x := clacson_ResObj[9]
clacson_coords_p2_lvl4_x := clacson_ResObj[10]

;code clarity
clacson_Delay := clacson_ConfigObj[2]

;convert frame delay into ms
clacson_DelayMS := (clacson_Delay*16)

;debug window for tidazi (may need this for volume controls)
Gui, clacson_DebugMain:New,, KI CLACSON
Gui, clacson_DebugMain:Add, Text,, Config File
Gui, clacson_DebugMain:Add, Edit, Disabled r3 vTextbox1 w230
Gui, clacson_DebugMain:Add, Text,, Debug Feed
Gui, clacson_DebugMain:Add, Edit, Disabled r3 vTextbox2 w230
Gui, clacson_DebugMain:Add, Text,, Debug Feed2
Gui, clacson_DebugMain:Add, Edit, Disabled r4 vTextbox3 w230
;Gui, clacson_DebugMain:Add, Text,, Resolution Coords File
;Gui, clacson_DebugMain:Add, Edit, Disabled r10 vTextbox4 w230

GuiControl,, Textbox4, %clacson_ResCoordsDebug%

WinGetPos,,,kiwinW,kiwinH,Killer Instinct
ResolutionText = % "" . kiwinW-16 . "x" . kiwinH-41

;config display for debug
textboxConfigDisplay = % "Resolution: " . clacsonActiveResolution . "`n" . "Frame Delay: " . clacson_Delay . "`n"
; . "MS Delay: " . clacson_DelayMS

GuiControl,, Textbox1, % textboxConfigDisplay

;testing ki window resolution autodetect
Gui, clacson_DebugMain:Add, Text,,Detected Resolution: %ResolutionText%
Gui, clacson_DebugMain:Show, W300
WinSet, AlwaysOnTop, On, KI CLACSON
WinMove, KI CLACSON,, 2,750

;change from hex to rgb 255 format for color ranges
SplitRGBColor(RGBColor, ByRef Red, ByRef Green, ByRef Blue)
{
    Red := RGBColor >> 16 & 0xFF
    Green := RGBColor >> 8 & 0xFF
    Blue := RGBColor & 0xFF
}

;checks if the given color is white enough (hit counter lettering)
clacson_ActiveCheck(Red,Green,Blue)
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

;checks if the provided color (should be combo level box) is
;the right shade of green / green enough
clacson_LevelCheck(Red,Green,Blue)
{
  if( Red >= 221 and Red <= 237 and Green >= 240 and Blue <= 187 and Blue >= 125 )
  {
    return 1
  }
  else
  {
    return 0
  }
}

;begin main loop
Loop
{
  ;limit polling so it doesn't eat too much cpu, but only if delay is specified
  if(clacson_DelayMS > 0)
  {
    Sleep,%clacson_DelayMS%
  }

  ;only do checks if ki is the active window
  if WinActive("Killer Instinct")
  {
    ;determine ui side with hit counter lettering
    ;branch into appropriate level detection coordinates

    ;player 1 side check white lettering of hit counter
    PixelGetColor,p1hits,%clacson_coords_p1_hits_x%,%clacson_coords_hits_y%,RGB
    SplitRGBColor(p1hits,p1Red,p1Green,p1Blue)


    ;DebugRBGValString = % "" . DebugRBGValString . "`nRGB: " . Red . "," . Green . "," . Blue

    ;player 2 side check white lettering of hit counter
    PixelGetColor,p2hits,%clacson_coords_p2_hits_x%,%clacson_coords_hits_y%,RGB
    SplitRGBColor(p2hits,p2Red,p2Green,p2Blue)


    ;check if active combo is on p1 side
    if(clacson_ActiveCheck(p1Red,p1Green,p1Blue))
    {
      clacson_active = P1
      if(clacsonDebugMode)
      {
        p1hitsrgbdebug = RGB: %p1Red%,%p1Green%,%p1Blue%`n
      }
    }
    ;check if active combo is on p2 side
    else if(clacson_ActiveCheck(p2Red,p2Green,p2Blue))
    {
      clacson_active = P2
      if(clacsonDebugMode)
      {
        p1hitsrgbdebug = RGB: %p2Red%,%p2Green%,%p2Blue%`n
      }
    }
    else
    {
      clacson_active = 0
      GuiControl,, Textbox2, CLACSON: waiting...
    }

    ;check if active combo is on p1 side
    if(clacson_active)
    {
      clacson_CL = 1

      ;do checks for player 1 side
      if(clacson_active == "P1")
      {
        ;check level 2
        PixelGetColor,p1level2,%clacson_coords_p1_lvl2_x%,%clacson_coords_level_y%,RGB
        SplitRGBColor(p1level2,Red,Green,Blue)
        if(clacsonDebugMode)
        {
          p1level2rgbdebug = RGB: %Red%,%Green%,%Blue%`n
        }
        if(clacson_LevelCheck(Red,Green,Blue))
        {
          clacson_CL = 2
        }

        ;check level 3
        PixelGetColor,p1level3,%clacson_coords_p1_lvl3_x%,%clacson_coords_level_y%,RGB
        SplitRGBColor(p1level3,Red,Green,Blue)
        if(clacsonDebugMode)
        {
          p1level3rgbdebug = RGB: %Red%,%Green%,%Blue%`n
        }
        if(clacson_LevelCheck(Red,Green,Blue))
        {
          clacson_CL = 3
        }

        ;check level 4
        PixelGetColor,p1level4,%clacson_coords_p1_lvl4_x%,%clacson_coords_level_y%,RGB
        SplitRGBColor(p1level4,Red,Green,Blue)
        if(clacsonDebugMode)
        {
          p1level4rgbdebug = RGB: %Red%,%Green%,%Blue%
        }
        if(clacson_LevelCheck(Red,Green,Blue))
        {
          clacson_CL = 4
        }
        DebugRBGValString = %p1hitsrgbdebug%%p1level2rgbdebug%%p1level3rgbdebug%%p1level4rgbdebug%
      }
      if(clacson_active == "P2")
      {
        ;check level 2
        PixelGetColor,p2level2,%clacson_coords_p2_lvl2_x%,%clacson_coords_level_y%,RGB
        SplitRGBColor(p2level2,Red,Green,Blue)
        if(clacsonDebugMode)
        {
          p2level2rgbdebug = RGB: %Red%,%Green%,%Blue%`n
        }

        if(clacson_LevelCheck(Red,Green,Blue))
        {
          clacson_CL = 2
        }

        ;check level 3
        PixelGetColor,p2level3,%clacson_coords_p2_lvl3_x%,%clacson_coords_level_y%,RGB
        SplitRGBColor(p2level3,Red,Green,Blue)
        if(clacson_LevelCheck(Red,Green,Blue))
        {
          clacson_CL = 3
        }
        if(clacsonDebugMode)
        {
          p2level3rgbdebug = RGB: %Red%,%Green%,%Blue%`n
        }

        ;check level 4
        PixelGetColor,p2level4,%clacson_coords_p2_lvl4_x%,%clacson_coords_level_y%,RGB
        SplitRGBColor(p2level4,Red,Green,Blue)
        if(clacson_LevelCheck(Red,Green,Blue))
        {
          clacson_CL = 4
        }
        if(clacsonDebugMode)
        {
          p2level4rgbdebug = RGB: %Red%,%Green%,%Blue%
        }
        DebugRBGValString = %p2hitsrgbdebug%%p2level2rgbdebug%%p2level3rgbdebug%%p2level4rgbdebug%
      }


      if(clacson_CL > 1 and clacson_CL != clacson_PrevComboLevel)
      {
        if(clacson_AR%clacson_CL% == 1)
        {
          clacson_AR%clacson_CL% = 0
          SoundPlay, %A_WorkingDir%\sounds\level%clacson_CL%.wav
        }
      }
      clacson_PrevComboLevel = %clacson_CL%
      clacson_DebugMessage = CLACSON: %clacson_active% `nlevel: %clacson_CL%
      GuiControl,, Textbox2, %clacson_DebugMessage%
      GuiControl,, Textbox3, %DebugRBGValString%
    }
    else
    {
      clacson_PrevComboLevel = 0
      clacson_AR2 = 1
      clacson_AR3 = 1
      clacson_AR4 = 1
      DebugRBGValString =
      GuiControl,, Textbox2, CLACSON: waiting...
      GuiControl,, Textbox3, %DebugRBGValString%
    }

  }
  else
  {
    GuiControl,, Textbox2, CLACSON: paused...
  }
  ;MouseGetPos,x,y
  ;PixelGetColor,rgb,x,y,RGB

  ;PixelGetColor,rgb,x,y,RGB
  ;StringTrimLeft,rgb,rgb,2
  ;GuiControl,, clacson_Debug1, %rgb%
}
