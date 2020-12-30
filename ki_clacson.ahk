/*
  ki_clacson.ahk
  an accessibility utility by tidazi (2020)
  version: 0.0.0.16 pre-alpha
*/

;@Ahk2Exe-SetName KI CLACSON
;@Ahk2Exe-SetLanguage 0x0409
;@Ahk2Exe-SetDescription Audio cue accessibility for Killer Instinct (2013)
;@Ahk2Exe-SetVersion 0.0.0.16-pre-alpha
;@Ahk2Exe-SetOrigFilename ki_clacson.exe
;@Ahk2Exe-SetCompanyName Tidazico (A fake company)
;@Ahk2Exe-SetCopyright GNU Affero General Public License v3.0


; Let it run till death but only once.
#Persistent
#SingleInstance force
;OPTIMIZATIONS START
#NoEnv
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
ListLines Off
Process, Priority, , A
SetBatchLines, -1
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetWinDelay, -1
SetControlDelay, -1
SendMode Input
;OPTIMIZATIONS END



#Include %A_ScriptDir%\Lib\JSON.ahk
#Include %A_ScriptDir%\Lib\Gdip_All.ahk
#Include %A_ScriptDir%\Lib\argb.ahk
#Include %A_ScriptDir%\clacsonLib\bass.ahk

#Include %A_ScriptDir%\clacsonLib\kiclacson_classes.ahk
#Include %A_ScriptDir%\clacsonLib\kiclacson_functions.ahk
#Include %A_ScriptDir%\clacsonLib\kiclacson_debugTools.ahk
#Include %A_ScriptDir%\clacsonLib\kiclacson_comboLevels.ahk
#Include %A_ScriptDir%\clacsonLib\kiclacson_fulgore.ahk


; set icon for tidazi only
if (!A_IsCompiled)
{
  Menu, Tray, Icon, % A_ScriptDir . "\cupcake.ico", -159
}


/*
  KI CLACSON initialization
*/

; load all position values for all resolutions
FileRead, resolutionsString, resolutions.json
global resolutions := JSON.Load(resolutionsString)

; load all position values for fulgore pips
FileRead, fulgorePipsString, fulgore.json
global fulgorePips := JSON.Load(fulgorePipsString)


; load user settings
FileRead, settingsString, settings.json
global config := JSON.Load(settingsString)
config.Delay := (config.frameDelay * 16)

; assign current position set
global pos := resolutions[config.resolution]
global fpips := fulgorePips[config.resolution]
global combo := new ComboState(0,0,0)
global aReady := new AudioReady(1,1,1)


if(config.KiVersion == "Steam")
{
  fixSteamKI()
}

BASS_Load()

; intialize and position the gui
kiclacsonGui()
winget, clacsonGuiID,, K I  CLACSON
BASS_Init(,,,clacsonGuiID,0)

global snd_comboLevel_p1_level2 := BASS_StreamCreateFile(0, A_ScriptDir . "\sounds\p1_level2.mp3",0,0,0)
global snd_comboLevel_p1_level3 := BASS_StreamCreateFile(0, A_ScriptDir . "\sounds\p1_level3.mp3",0,0,0)
global snd_comboLevel_p1_level4 := BASS_StreamCreateFile(0, A_ScriptDir . "\sounds\p1_level4.mp3",0,0,0)

global snd_fulgorePips_p1_noPips:= BASS_StreamCreateFile(0, A_ScriptDir . "\sounds\p1_noPips.mp3",0,0,0)
global snd_fulgorePips_p1_4Pips := BASS_StreamCreateFile(0, A_ScriptDir . "\sounds\p1_4pips.mp3",0,0,0)


global snd_comboLevel_p2_level2 := BASS_StreamCreateFile(0, A_ScriptDir . "\sounds\p2_level2.mp3",0,0,0)
global snd_comboLevel_p2_level3 := BASS_StreamCreateFile(0, A_ScriptDir . "\sounds\p2_level3.mp3",0,0,0)
global snd_comboLevel_p2_level4 := BASS_StreamCreateFile(0, A_ScriptDir . "\sounds\p2_level4.mp3",0,0,0)

global snd_fulgorePips_p2_noPips:= BASS_StreamCreateFile(0, A_ScriptDir . "\sounds\p2_noPips.mp3",0,0,0)
global snd_fulgorePips_p2_4Pips := BASS_StreamCreateFile(0, A_ScriptDir . "\sounds\p2_4pips.mp3",0,0,0)

; set sound volume to the previous configuration
DllCall(A_ScriptDir "\bass.dll\BASS_SetConfig", UInt, 5, UInt, Round(config.clacsonVolume * 100,0))

; update gui to reflect volume level
GuiControl, kiclacsonGui:, volumeInput, % config.clacsonVolume

WinSet, AlwaysOnTop, On, K I  CLACSON
WinGetPos,,,,WinHeight,K I  CLACSON
WinMove, K I  CLACSON,, 1,(A_ScreenHeight)-(WinHeight)-40

global kiwindow


; resize ki if it's the wrong resolution
;SetTimer, fixSteamKI, 2000 ; check every 2 seconds

; % config.Delay

; capture bitmap every frame

; begin combo level detection routine
;SetTimer,comboLevelMain, % config.Delay

;SetTimer,fulgorePipsMain, % config.Delay
global clacsonMainGdip, kicap
CoordMode, Mouse, Screen
GuiControl,kiclacsonGui:, StateBox, Paused...
goto kiClacsonLoopStart

kiClacsonLoopStart:
  ;StartTime := A_TickCount
  WinGetTitle, ActiveWindowTitle, A
  if(ActiveWindowTitle == "Killer Instinct")
  {
    clacsonMainGdip := Gdip_Startup()
    WinGet, kiwindow, id
    ; todo: add support for non-borderless fullscreen here
    ;WinGet, KIPID, PID, Killer Instinct
    ;kipath := GetModuleFileNameEx(KIPID)
    kicap := Gdip_BitmapFromHWND(kiwindow)
    goto kiClacsonComboLevelStart
  }
  Else
  {
    GuiControl,kiclacsonGui:, StateBox, Paused...
    goto kiClacsonLoopEnd
  }

return

kiClacsonComboLevelStart:
  comboLevelMain()
  ;p1level2temp := Gdip_GetPixel(kicap, pos.P1Level2, pos.LevelY)
  ;splitARGBColor(p1level2temp,Red,Green,Blue)
  ;DebugRBGValString := "Level2 Box: " . Red . "," . Green . "," . Blue
  ;GuiControl,kiclacsonGui:, comboLevelFeed, %DebugRBGValString%
  goto kiClacsonFulgorePipsStart
return

kiClacsonFulgorePipsStart:
  fulgorePipsMain()
  goto kiClacsonLoopEnd
return

kiClacsonLoopEnd:
  if(config.debugMode)
  {
    WatchCursor()
  }
  Gdip_DisposeImage(kicap)
  Gdip_Shutdown(clacsonMainGdip)
  sleep, % config.Delay
  ;ElapsedTime := A_TickCount - StartTime
  ;if(!ElapsedTime)
  ;{
  ;  ElapsedTime = 0
  ;}
  ;GuiControl,kiclacsonGui:, fulgoreFeed, % "Time required: " . ElapsedTime . "ms"
  goto kiClacsonLoopStart
return



if(config.debugMode)
{
  ;SetTimer, WatchCursor, 50
  ;DetectHiddenWindows, On ; for special win
}

if(config.debugMode)
{
  #Include %A_ScriptDir%\clacsonLib\kiclacson_binds.ahk
}
