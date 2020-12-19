
/*
  Main KI CLACSON combo level detection function
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
    if(hitCounterCheck(p1Red,p1Green,p1Blue))
    {
      PixelGetColor,p1level1,pos.P1Level1,pos.LevelY,RGB
      splitRGBColor(p1level1,Red,Green,Blue)
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
      PixelGetColor,p2level1,pos.P2Level1,pos.LevelY,RGB
      splitRGBColor(p2level1,Red,Green,Blue)
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
        if(combo.Active == "P1")
        {
          if(aReady.level2 == 1 and combo.CurrentLevel == 2)
          {
            aReady.level2 := 0
            BASS_ChannelPlay(snd_comboLevel_p1_level2,1)
          }
          if(aReady.level3 == 1 and combo.CurrentLevel == 3)
          {
            aReady.level3 := 0
            BASS_ChannelPlay(snd_comboLevel_p1_level3,1)
          }
          if(aReady.level4 == 1 and combo.CurrentLevel == 4)
          {
            aReady.level4 := 0
            BASS_ChannelPlay(snd_comboLevel_p1_level4,1)
          }
        }
        else if(combo.Active == "P2")
        {
          if(aReady.level2 == 1 and combo.CurrentLevel == 2)
          {
            aReady.level2 := 0
            BASS_ChannelPlay(snd_comboLevel_p2_level2,1)
          }
          if(aReady.level3 == 1 and combo.CurrentLevel == 3)
          {
            aReady.level3 := 0
            BASS_ChannelPlay(snd_comboLevel_p2_level3,1)
          }
          if(aReady.level4 == 1 and combo.CurrentLevel == 4)
          {
            aReady.level4 := 0
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

    }
    else
    {
      GuiControl,kiclacsonGui:, StateBox, Paused...
    }
}
