
/*
  Main KI CLACSON combo level detection function
*/

global clFalsePositivelv2, clFalsePositivelv3, clFalsePositivelv4
comboLevelMain()
{
  if WinActive("Killer Instinct")
  {
    ;comboLevelGdip := Gdip_Startup()
    ;kicap := Gdip_BitmapFromHWND(kiwindow)
    ; determine ui side with hit counter lettering
    ; branch into appropriate level detection coordinates
    ;StartTime := A_TickCount

    ; player 1 side check white lettering of hit counter
    p1hits := Gdip_GetPixel(kicap, pos.P1HitsX, pos.HitsY)
    splitARGBColor(p1hits,p1Red,p1Green,p1Blue)

    ; player 2 side check white lettering of hit counter
    p2hits := Gdip_GetPixel(kicap, pos.P2HitsX, pos.HitsY)
    splitARGBColor(p2hits,p2Red,p2Green,p2Blue)

    ; check if active combo is on p1 side
    if(hitCounterCheck(p1Red,p1Green,p1Blue))
    {
      p1level1 := Gdip_GetPixel(kicap, pos.P1Level1, pos.LevelY)
      splitARGBColor(p1level1,Red,Green,Blue)

      if(levelCheck(Red,Green,Blue))
      {
        combo.Active := "P1"
        if(config.debugMode)
        {
          p1hitsrgbdebug = HITS RGB: %p1Red%,%p1Green%,%p1Blue%`n
        }
      }
      else
      {
        combo.Active := 0
        GuiControl,kiclacsonGui:, StateBox, Waiting...
      }
    }
    ; check if active combo is on p2 side
    else if(hitCounterCheck(p2Red,p2Green,p2Blue))
    {
      p2level1 := Gdip_GetPixel(kicap, pos.P2Level1, pos.LevelY)
      splitARGBColor(p2level1,Red,Green,Blue)
      if(levelCheck(Red,Green,Blue))
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
        p1level2 := Gdip_GetPixel(kicap, pos.P1Level2, pos.LevelY)
        splitARGBColor(p1level2,Red,Green,Blue)

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
          if(clFalsePositivelv2==1)
          {
            aReady.level2 := 1
            clFalsePositivelv2:=0
          }
          else
          {
            clFalsePositivelv2:=1
          }
        }

        ; check level 3
        p1level3 := Gdip_GetPixel(kicap, pos.P1Level3, pos.LevelY)
        splitARGBColor(p1level3,Red,Green,Blue)

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
          if(clFalsePositivelv3==1)
          {
            aReady.level3 := 1
            clFalsePositivelv3:=0
          }
          else
          {
            clFalsePositivelv3:=1
          }
        }

        ; check level 4
        p1level4 := Gdip_GetPixel(kicap, pos.P1Level4, pos.LevelY)
        splitARGBColor(p1level4,Red,Green,Blue)

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
          if(clFalsePositivelv4==1)
          {
            aReady.level4 := 1
            clFalsePositivelv4:=0
          }
          else
          {
            clFalsePositivelv4:=1
          }
        }
        DebugRBGValString = %p1hitsrgbdebug%%p1level2rgbdebug%%p1level3rgbdebug%%p1level4rgbdebug%


      }
      if(combo.Active == "P2")
      {
        ; check level 2
        ;PixelGetColor,p2level2,pos.P2Level2,pos.LevelY,RGB
        p2level2 := Gdip_GetPixel(kicap, pos.P2Level2, pos.LevelY)
        splitARGBColor(p2level2,Red,Green,Blue)

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
          if(clFalsePositivelv2==1)
          {
            aReady.level2 := 1
            clFalsePositivelv2:=0
          }
          else
          {
            clFalsePositivelv2:=1
          }
        }

        ; check level 3
        p2level3 := Gdip_GetPixel(kicap, pos.P2Level3, pos.LevelY)
        splitARGBColor(p2level3,Red,Green,Blue)

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
          if(clFalsePositivelv3==1)
          {
            aReady.level3 := 1
            clFalsePositivelv3:=0
          }
          else
          {
            clFalsePositivelv3:=1
          }
        }


        ; check level 4
        p2level4 := Gdip_GetPixel(kicap, pos.P2Level4, pos.LevelY)
        splitARGBColor(p2level4,Red,Green,Blue)

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
          if(clFalsePositivelv4==1)
          {
            aReady.level4 := 1
            clFalsePositivelv4:=0
          }
          else
          {
            clFalsePositivelv4:=1
          }
        }

        DebugRBGValString = %p2hitsrgbdebug%%p2level2rgbdebug%%p2level3rgbdebug%%p2level4rgbdebug%
      }

      ; it won't let me do dynamic object property naming so HECK IT
      if(combo.CurrentLevel > 1 and combo.CurrentLevel > combo.PreviousLevel)
      {
        if(combo.Active == "P1")
        {
          if(aReady.level2 == 1 and combo.CurrentLevel == 2)
          {
            aReady.level2 := 0
            clFalsePositivelv2:=0
            BASS_ChannelPlay(snd_comboLevel_p1_level2,1)
          }
          if(aReady.level3 == 1 and combo.CurrentLevel == 3)
          {
            aReady.level3 := 0
            clFalsePositivelv3:=0
            BASS_ChannelPlay(snd_comboLevel_p1_level3,1)
          }
          if(aReady.level4 == 1 and combo.CurrentLevel == 4)
          {
            aReady.level4 := 0
            clFalsePositivelv4:=0
            BASS_ChannelPlay(snd_comboLevel_p1_level4,1)
          }
        }
        else if(combo.Active == "P2")
        {
          if(aReady.level2 == 1 and combo.CurrentLevel == 2)
          {
            aReady.level2 := 0
            clFalsePositivelv2:=0
            BASS_ChannelPlay(snd_comboLevel_p2_level2,1)
          }
          if(aReady.level3 == 1 and combo.CurrentLevel == 3)
          {
            aReady.level3 := 0
            clFalsePositivelv3:=0
            BASS_ChannelPlay(snd_comboLevel_p2_level3,1)
          }
          if(aReady.level4 == 1 and combo.CurrentLevel == 4)
          {
            aReady.level4 := 0
            clFalsePositivelv4:=0
            BASS_ChannelPlay(snd_comboLevel_p2_level4,1)
          }
        }

      }
      combo.PreviousLevel := combo.CurrentLevel
      stateMessage = % "Active Side: " . combo.Active . "`nCombo Level: " . combo.CurrentLevel
      GuiControl,kiclacsonGui:, StateBox, %stateMessage%
      GuiControl,kiclacsonGui:, comboLevelFeed, %DebugRBGValString%
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
      GuiControl,kiclacsonGui:, comboLevelFeed, %DebugRBGValString%
    }
    return
  ;Gdip_DisposeImage(kicap)
  ;Gdip_Shutdown(comboLevelGdip)
  }
  else
  {
    GuiControl,kiclacsonGui:, StateBox, Paused...
    return
  }
    ;ElapsedTime := A_TickCount - StartTime
    ;GuiControl,kiclacsonGui:, fulgoreFeed, % ElapsedTime . "ms has elapsed."
}
