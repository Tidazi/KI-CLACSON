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
