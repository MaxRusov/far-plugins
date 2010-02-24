@Echo off

if not exist ..\Units\MoreHistory md ..\Units\MoreHistory
if not exist ..\Bin\MoreHistory md ..\Bin\MoreHistory

windres -i MoreHistoryA.rc -o MoreHistoryA.RES || exit
windres -i MoreHistoryW.rc -o MoreHistoryW.RES || exit

fpc.exe -B MoreHistory.dpr %* || exit

copy Doc\* ..\Bin\MoreHistory
if /i "%1"=="-dunicode" copy DocW\* ..\Bin\MoreHistory
