
/*
  Function definitions

    GetModuleFileNameEx()
      potential solution for adding support to non-borderless fullscreen steam
      by shimanov -  www.autohotkey.com/forum/viewtopic.php?t=9000

    splitARGBColor
      change from hex to argb 255 format for color ranges

    kiclacsonGui
      main gui function

    checkForWindow
      function to see if the ki clacson gui still exists
      and to kill clacson if it doesn't after 5s

    userChangeResolution
      this function is called when the dropdown for the
      KI Resolution setting is changed

    updateUserSettings
      saves the settings to the settings.json file

    fixSteamKI
      steam ki resolution tends to be incorrect and for some reason
      it resizes itself sometimes which would break detection, this
      will ensure that detection can work as intended

*/

GetModuleFileNameEx(p_pid)
{
   h_process := DllCall( "OpenProcess", "uint", 0x10|0x400, "int", false, "uint", p_pid )
   if ( ErrorLevel or h_process = 0 )
   {
     return
   }
   name_size = 255
   VarSetCapacity( name, name_size )
   result := DllCall( "psapi.dll\GetModuleFileNameExA", "uint", h_process, "uint", 0, "str", name, "uint", name_size )
   DllCall( "CloseHandle", h_process )
   return, name
}

splitARGBColor(RGBColor, ByRef Red, ByRef Green, ByRef Blue, ByRef Alpha=0)
{
  Red := ARGB_GET(RGBColor,"R")
  Green := ARGB_GET(RGBColor,"G")
  Blue := ARGB_GET(RGBColor,"B")
  if(Alpha)
  {
    Alpha := ARGB_GET(RGBColor,"A")
  }
}

isWindowFullScreen( winID )
{
	If ( !winID )
  {
    Return false
  }

	WinGet style, Style, ahk_id %WinID%
	WinGetPos ,,,winW,winH, %WinID%
	Return ((style & 0x20800000) or winH < A_ScreenHeight or winW < A_ScreenWidth) ? false : true
}


global VolumeSlider, volumeInput, volumeUpdown,
global KiVersionWin10, KiVersionSteam, boxConfig, stateBox
global comboLevelFeed, colorRangeFeed, resolutionBox, mouseFeed, configDisplay
global currentResolution, checkInterval, fulgoreFeed
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
  resolutionList := "WINDOWED|" resolutionListW . "BORDERLESS FULLSCREEN|" . resolutionListFS

  ;msgbox, % resolutionList
  Gui, kiclacsonGui:New,, K I  CLACSON
  Gui, kiclacsonGui:Font,, Fixedsys
  ;Gui, kiclacsonGui:Add, Text,, Configuration
  ;Gui, kiclacsonGui:Add, Edit,  r2 vboxConfig w230
  ;Gui, kiclacsonGui:Add, Text,, 0`%
  ;Gui, kiclacsonGui:Add, Text,x+65, Volume
  Gui, kiclacsonGui:Add, Text,, Volume
  ;Gui, kiclacsonGui:Add, Text,x+65, 100`%
  ;Gui, kiclacsonGui:Add, Slider, x10 guserChangeVolume vVolumeSlider w230, 100
  Gui, kiclacsonGui:Add, Edit, r1 vvolumeInput w230 Number
  Gui, kiclacsonGui:Add, UpDown, guserChangeVolume vvolumeUpdown Range0-100, 0
  Gui, kiclacsonGui:Add, Text,, K I  Resolution
  Gui, kiclacsonGui:Add, DropDownList, guserChangeResolution vcurrentResolution w230, % resolutionList
  Gui, kiclacsonGui:Add, Text,, K I  Version
  if(config.KiVersion == "Win10")
  {
    Gui, kiclacsonGui:Add, Radio, altsubmit guserChangeKiVersion vKiVersionWin10 checked, Windows 10
  }
  else
  {
    Gui, kiclacsonGui:Add, Radio, altsubmit guserChangeKiVersion vKiVersionWin10, Windows 10
  }
  if(config.KiVersion == "Steam")
  {
    Gui, kiclacsonGui:Add, Radio, altsubmit guserChangeKiVersion vKiVersionSteam checked, Steam
  }
  else
  {
    Gui, kiclacsonGui:Add, Radio, altsubmit guserChangeKiVersion vKiVersionSteam, Steam
  }


  Gui, kiclacsonGui:Add, Text,, Check Interval
  Gui, kiclacsonGui:Add, Edit, r1 vcheckInterval w230 disabled, % config.frameDelay . "f"
  Gui, kiclacsonGui:Add, Text,, Current State
  Gui, kiclacsonGui:Add, Edit,  r2 vstateBox w230 disabled
  if(config.debugMode)
  {
    Gui, kiclacsonGui:Add, Text,, Detected Resolution
    Gui, kiclacsonGui:Add, Edit,  r1 vresolutionBox w230 disabled
    Gui, kiclacsonGui:Add, Text,, Combo Level Feed
    Gui, kiclacsonGui:Add, Edit,  r4 vcomboLevelFeed w230
    Gui, kiclacsonGui:Add, Text,, Color Range Feed
    Gui, kiclacsonGui:Add, Edit,  r6 vcolorRangeFeed w230
    Gui, kiclacsonGui:Add, Text,, Mouse Feed
    Gui, kiclacsonGui:Add, Edit,  r3 vmouseFeed w230
    Gui, kiclacsonGui:Add, Text,, FulgoreFeed
    Gui, kiclacsonGui:Add, Edit,  r6 vfulgoreFeed w230
  }
  gui, kiclacsonGui:Add, Button, h0 w0 default guserChangeVolume, Submit
  gui, kiclacsonGui:Add, Button, w230 gcloseClacson, EXIT  K I  CLACSON
  GuiControl, Hide, Submit
  Gui, kiclacsonGui:Show, W250

  hWnd := WinExist("K I  CLACSON")
  hSysMenu := DllCall("GetSystemMenu","Int",hWnd,"Int",FALSE)
  nCnt := DllCall("GetMenuItemCount","Int",hSysMenu)
  DllCall("RemoveMenu","Int",hSysMenu,"UInt",nCnt-1,"Uint","0x400")
  DllCall("RemoveMenu","Int",hSysMenu,"UInt",nCnt-2,"Uint","0x400")
  DllCall("DrawMenuBar","Int",hWnd)

  return
}

userChangeKiVersion()
{
  GuiControlGet, KiVersionWin10
  GuiControlGet, KiVersionSteam
  if(KiVersionWin10)
  {
    config.KiVersion := "Win10"
  }
  else
  {
    config.KiVersion := "Steam"
    fixSteamKI()
  }
  ;msgbox, % config.KiVersion
  updateUserSettings()
  userChangeResolution()
}

userChangeResolution()
{
  GuiControlGet, currentResolution

  if(currentResolution == "WINDOWED" or currentResolution == "BORDERLESS FULLSCREEN")
  {
    GuiControl, ChooseString, currentResolution, % config.resolution
  }
  else
  {
    config.resolution := currentResolution
    pos := resolutions[config.resolution]
    fpips := fulgorePips[config.resolution]
    if(config.KiVersion == "Steam")
    {
      fixSteamKI()
    }
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


global newVolume
userChangeVolume()
{
  GuiControlGet, volumeUpdown
  GuiControlGet, volumeInput
  GuiControl,kiclacsonGui:, volumeInput, % volumeUpdown
  config.clacsonVolume := volumeUpdown
  DllCall(A_ScriptDir "\bass.dll\BASS_SetConfig", UInt, 5, UInt, Round(config.clacsonVolume * 100,0))
  SetTimer userVolumeFeedback, Delete
  SetTimer userVolumeFeedback, 350
  updateUserSettings()
}

userVolumeFeedback()
{
  BASS_ChannelPlay(snd_comboLevel_p1_level2,1)
  BASS_ChannelPlay(snd_comboLevel_p2_level2,1)
  SetTimer userVolumeFeedback, Delete
}


fixSteamKI()
{
  if(WinExist("Killer Instinct"))
  {
    ;msgbox, % config.resolution
    if(InStr(config.resolution,"w"))
    {
      WinGetPos,,,kiwinW,kiwinH,Killer Instinct
      kiwinAdjW := kiwinW-16
      kiwinAdjH := kiwinH-41
      ResolutionText = % "" . kiwinAdjW . "x" . kiwinAdjH
      GuiControl, kiclacsonGui:, resolutionBox, % ResolutionText
      confRes :=StrReplace(config.resolution,"w","")
      confRes := StrSplit(confRes, "x")
      confWidth := confRes[1]
      confHeight := confRes[2]
      ;msgbox, % confRes[1] . "x" . confRes[2]

      if(confHeight != kiwinAdjH)
      {
        diff := round(confHeight - kiwinAdjH)
        ;msgbox, % round(diff / 2)
        pos.HitsY := round(pos.HitsY - (diff / 2))
        pos.LevelY := round(pos.LevelY - (diff / 2))
        newResString := confWidth . "x" . round(confHeight - diff) . "w"
        ;config.resolution := newResString

        ;WinMove,Killer Instinct,,,,(confWidth+16),(confHeight+41)
        ;msgbox, % confWidth  . "x" . confHeight . "`n" . ResolutionText
      }
      if(confWidth != kiwinAdjW)
      {
        ;WinMove,Killer Instinct,,,,(confWidth+16),(confHeight+41)
        ;msgbox, % kiwinAdjW . "x" . kiwinAdjH
      }
    }
    else
    {
      ResolutionText = "(Fullscreen)"
    }
    ;msgbox, % confWidth  . "x" . confHeight
  }

}


closeClacson()
{
  BASS_Free()
  exitapp
}
