
global p1fulgore, fulgorePipsAudioReadyP1Pip1, fulgorePipsAudioReadyP1Pip4, fulgorePipsAudioReadyP1Pip8
global p2fulgore, fulgorePipsAudioReadyP2Pip1, fulgorePipsAudioReadyP2Pip4, fulgorePipsAudioReadyP2Pip8
global p1Bar1RedHigh, p1Bar1RedLow, p1Bar1GreenHigh, p1Bar1GreenLow, p1Bar1BlueHigh, p1Bar1BlueLow, fulgoreFeedString

p1Bar1RedHigh := 162
p1Bar1RedLow := 99
p1Bar1GreenHigh := 224
p1Bar1GreenLow := 207
p1Bar1BlueHigh := 58
p1Bar1BlueLow := 57

fulgorePipsAudioReadyP1Pip1 := 0
fulgorePipsAudioReadyP1Pip4 := 0
fulgorePipsAudioReadyP1Pip8 := 0

fulgorePipsAudioReadyP2Pip1 := 0
fulgorePipsAudioReadyP2Pip4 := 0
fulgorePipsAudioReadyP2Pip8 := 0


fulgoreAnchorCheck(red,green,blue)
{
  if(red == 156 and (green >= 136 and green <=138) and blue == 82)
  {
    return 1
  }
  else
  {
    return 0
  }
}

greenPipCheck(red,green,blue)
{
  if((red >= 20 and red <= 24) and (green >= 50 and green <= 52) and (blue >= 3 and blue <= 8))
  {
    return 1
  }
  else
  {
    return 0
  }
}

yellowPipCheck(red,green,blue)
{
  if(red >= 61 and red <= 66 and green >= 50 and green <= 52 and blue == 0)
  {
    return 1
  }
  else
  {
    return 0
  }
}

fulgoreColorRange(red,green,blue)
{
  if(red > p1Bar1RedHigh)
  {
    p1Bar1RedHigh := red
  }
  if(red < p1Bar1RedLow)
  {
    p1Bar1RedLow := red
  }
  if(green > p1Bar1GreenHigh)
  {
    p1Bar1GreenHigh := green
  }
  if(green < p1Bar1GreenLow)
  {
    p1Bar1GreenLow := green
  }
  if(blue > p1Bar1BlueHigh)
  {
    p1Bar1BlueHigh := blue
  }
  if(blue < p1Bar1BlueLow)
  {
    p1Bar1BlueLow := blue
  }
}



fulgorePipsMain()
{
  ;StartTime := A_TickCount

  if WinActive("Killer Instinct")
  {
    ;fulgorePipsGdip := Gdip_Startup()
    ;kicap := Gdip_BitmapFromHWND(kiwindow)
    ; player 1 side check if fulgore pip bar exists

    p1pipAnchor := Gdip_GetPixel(kicap, fpips.P1anchorX, fpips.anchorY)
    splitARGBColor(p1pipAnchor,p1Red,p1Green,p1Blue)

    if(fulgoreAnchorCheck(p1Red,p1Green,p1Blue))
    {
      p1fulgore := 1
    }
    else
    {
      p1fulgore := 0
    }

    ; player 2 side check if fulgore pip bar exists
    p2pipAnchor := Gdip_GetPixel(kicap, fpips.P2anchorX, fpips.anchorY)
    splitARGBColor(p2pipAnchor,p2Red,p2Green,p2Blue)
    if(fulgoreAnchorCheck(p2Red,p2Green,p2Blue))
    {
      p2fulgore := 1
    }
    else
    {
      p2fulgore := 0
    }

    if(p1fulgore or p2fulgore)
    {
      fulgoreFeedString := ""
      if(p1fulgore)
      {
        fulgoreFeedString .= "P1`n"
        p1pip1 := Gdip_GetPixel(kicap, fpips.P1pips1X, fpips.pipsY)
        splitARGBColor(p1pip1,p1pip1Red,p1pip1Green,p1pip1Blue)

        p1pip4 := Gdip_GetPixel(kicap, fpips.P1pips4X, fpips.pipsY)
        splitARGBColor(p1pip4,p1pip4Red,p1pip4Green,p1pip4Blue)

        p1pip8 := Gdip_GetPixel(kicap, fpips.P1pips8X, fpips.pipsY)
        splitARGBColor(p1pip8,p1pip8Red,p1pip8Green,p1pip8Blue)

        fulgoreFeedString .= "PIP1: " . p1pip1Red . "," . p1pip1Green . "," . p1pip1Blue . "`n"
        fulgoreFeedString .= "PIP4: " . p1pip4Red . "," . p1pip4Green . "," . p1pip4Blue . "`n"
        fulgoreFeedString .= "PIP8: " . p1pip8Red . "," . p1pip8Green . "," . p1pip8Blue . "`n"

        if(greenPipCheck(p1pip1Red,p1pip1Green,p1pip1Blue))
        {
          fulgorePipsAudioReadyP1Pip1:=1
        }
        else
        {
          if(fulgorePipsAudioReadyP1Pip1 and fulgoreAnchorCheck(p1Red,p1Green,p1Blue))
          {
              BASS_ChannelPlay(snd_fulgorePips_p1_noPips,1)
              fulgorePipsAudioReadyP1Pip1:=0
          }
        }


        if(greenPipCheck(p1pip4Red,p1pip4Green,p1pip4Blue))
        {
          if(fulgorePipsAudioReadyP1Pip4 and fulgoreAnchorCheck(p1Red,p1Green,p1Blue))
          {
            BASS_ChannelPlay(snd_fulgorePips_p1_4Pips,1)
            fulgorePipsAudioReadyP1Pip4:=0
          }
        }
        else
        {
          fulgorePipsAudioReadyP1Pip4:=1
        }



        if(yellowPipCheck(p1pip8Red,p1pip8Green,p1pip8Blue))
        {
          if(fulgorePipsAudioReadyP1Pip8)
          {
            BASS_ChannelPlay(snd_fulgorePips_p1_4Pips,1)
            fulgorePipsAudioReadyP1Pip8:=0
          }
        }
        else
        {
          fulgorePipsAudioReadyP1Pip8:=1
        }

      }




      if(p2fulgore)
      {
        fulgoreFeedString .= "P2`n"
        p2pip1 := Gdip_GetPixel(kicap, fpips.P2pips1X, fpips.pipsY)
        splitARGBColor(p2pip1,p2pip1Red,p2pip1Green,p2pip1Blue)

        p2pip4 := Gdip_GetPixel(kicap, fpips.P2pips4X, fpips.pipsY)
        splitARGBColor(p2pip4,p2pip4Red,p2pip4Green,p2pip4Blue)

        p2pip8 := Gdip_GetPixel(kicap, fpips.P2pips8X, fpips.pipsY)
        splitARGBColor(p2pip8,p2pip8Red,p2pip8Green,p2pip8Blue)

        fulgoreFeedString .= "PIP1: " . p2pip1Red . "," . p2pip1Green . "," . p2pip1Blue . "`n"
        fulgoreFeedString .= "PIP4: " . p2pip4Red . "," . p2pip4Green . "," . p2pip4Blue . "`n"
        fulgoreFeedString .= "PIP8: " . p2pip8Red . "," . p2pip8Green . "," . p2pip8Blue . "`n"

        if(greenPipCheck(p2pip1Red,p2pip1Green,p2pip1Blue))
        {
          fulgorePipsAudioReadyP2Pip1:=1
        }
        else
        {

          if(fulgorePipsAudioReadyP2Pip1)
          {
              BASS_ChannelPlay(snd_fulgorePips_p2_noPips,1)
              fulgorePipsAudioReadyP2Pip1:=0
            ;}
          }
        }


        if(greenPipCheck(p2pip4Red,p2pip4Green,p2pip4Blue))
        {
          if(fulgorePipsAudioReadyP2Pip4)
          {
            BASS_ChannelPlay(snd_fulgorePips_p2_4Pips,1)
            fulgorePipsAudioReadyP2Pip4:=0
          }
        }
        else
        {
          fulgorePipsAudioReadyP2Pip4:=1
        }

        if(yellowPipCheck(p2pip8Red,p2pip8Green,p2pip8Blue))
        {
          if(fulgorePipsAudioReadyP2Pip8)
          {
            BASS_ChannelPlay(snd_fulgorePips_p2_4Pips,1)
            fulgorePipsAudioReadyP2Pip8:=0
          }
        }
        else
        {
          fulgorePipsAudioReadyP2Pip8:=1
        }

      }
    }
    else
    {
      return
    }

    GuiControl,kiclacsonGui:, fulgoreFeed, % fulgoreFeedString
    ;Gdip_DisposeImage(kicap)
    ;Gdip_Shutdown(fulgorePipsGdip)
    return
  }
  else
  {
    return
  }
  ;ElapsedTime := A_TickCount - StartTime
  ;GuiControl,kiclacsonGui:, fulgoreFeed, % ElapsedTime . " milliseconds have elapsed."
}
