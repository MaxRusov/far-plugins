@Echo off

if not exist ..\Units\MacroLib md ..\Units\MacroLib
if not exist ..\Bin\MacroLib md ..\Bin\MacroLib
if exist MacroLib.cfg del MacroLib.cfg

brcc32 MacroLib.rc || exit

dcc32.exe -B MacroLib.dpr %* || exit

copy Doc\* ..\Bin\MacroLib
