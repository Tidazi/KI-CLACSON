/*
  kiclacson.ahk
  an accessibility utility by tidazi (2020)
  version: 0.0013 pre-alpha
*/

; Let it run till death but only once.
#Persistent
#SingleInstance force

#Include %A_ScriptDir%\Lib\JSON.ahk
#Include %A_ScriptDir%\clacsonLib\bass.ahk

#Include %A_ScriptDir%\clacsonLib\kiclacson_classes.ahk
#Include %A_ScriptDir%\clacsonLib\kiclacson_functions.ahk
#Include %A_ScriptDir%\clacsonLib\kiclacson_debugTools.ahk
#Include %A_ScriptDir%\clacsonLib\kiclacson_comboLevels.ahk



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


; load user settings
FileRead, settingsString, settings.json
global config := JSON.Load(settingsString)
config.Delay := (config.frameDelay * 16)

; assign current position set
global pos := resolutions[config.resolution]
global combo := new ComboState(0,0,0)
global aReady := new AudioReady(1,1,1)




BASS_Load()

; intialize and position the gui
kiclacsonGui()
winget, clacsonGuiID,, K I  CLACSON
BASS_Init(,,,clacsonGuiID,0)

global snd_comboLevel_p1_level2 := BASS_StreamCreateFile(0, A_ScriptDir . "\sounds\p1_level2.mp3",0,0,0)
global snd_comboLevel_p1_level3 := BASS_StreamCreateFile(0, A_ScriptDir . "\sounds\p1_level3.mp3",0,0,0)
global snd_comboLevel_p1_level4 := BASS_StreamCreateFile(0, A_ScriptDir . "\sounds\p1_level4.mp3",0,0,0)

global snd_comboLevel_p2_level2 := BASS_StreamCreateFile(0, A_ScriptDir . "\sounds\p2_level2.mp3",0,0,0)
global snd_comboLevel_p2_level3 := BASS_StreamCreateFile(0, A_ScriptDir . "\sounds\p2_level3.mp3",0,0,0)
global snd_comboLevel_p2_level4 := BASS_StreamCreateFile(0, A_ScriptDir . "\sounds\p2_level4.mp3",0,0,0)

; set sound volume to the previous configuration
DllCall(A_ScriptDir "\bass.dll\BASS_SetConfig", UInt, 5, UInt, Round(config.clacsonVolume * 100,0))

; update gui to reflect volume level
GuiControl, kiclacsonGui:, volumeInput, % config.clacsonVolume

WinSet, AlwaysOnTop, On, K I  CLACSON
WinGetPos,,,,WinHeight,K I  CLACSON
WinMove, K I  CLACSON,, 1,(A_ScreenHeight)-(WinHeight)-40

; resize ki if it's the wrong resolution
SetTimer, fixSteamKI, 2000 ; check every 2 seconds

; begin combo level detection routine
SetTimer,comboLevelMain,% config.Delay ; user defined check interval




if(config.debugMode)
{
  SetTimer, WatchCursor, 50
  DetectHiddenWindows, On ; for special win
  CoordMode, Mouse, Screen
}

if(config.debugMode)
{
  #Include %A_ScriptDir%\clacsonLib\kiclacson_binds.ahk
}
