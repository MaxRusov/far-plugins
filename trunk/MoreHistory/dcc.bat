@Echo off

if not exist ..\Units\MoreHistory md ..\Units\MoreHistory
if not exist ..\Bin\MoreHistory md ..\Bin\MoreHistory

if exist MoreHistory.cfg del MoreHistory.cfg

brcc32 MoreHistoryA.rc || exit
brcc32 MoreHistoryW.rc || exit

dcc32.exe -B MoreHistory.dpr %* || exit

copy Doc\* ..\Bin\MoreHistory
if /i "%1"=="-dunicode" copy DocW\* ..\Bin\MoreHistory
