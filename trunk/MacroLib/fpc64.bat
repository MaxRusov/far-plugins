@Echo off

if not exist ..\Units64\MacroLib md ..\Units64\MacroLib
if not exist ..\Bin64\MacroLib md ..\Bin64\MacroLib

windres -i MacroLib.rc  -o MacroLib.RES || exit

ppcrossx64.exe -B MacroLib.dpr %* || exit

copy Doc\* ..\Bin64\MacroLib

