@Echo off

if not exist ..\Units64\MoreHistory md ..\Units64\MoreHistory
if not exist ..\Bin64\MoreHistory md ..\Bin64\MoreHistory

windres -i MoreHistoryA.rc -o MoreHistoryA.RES || exit
windres -i MoreHistoryW.rc -o MoreHistoryW.RES || exit

ppcrossx64.exe -B MoreHistory.dpr %* || exit

copy Doc\* ..\Bin64\MoreHistory
if /i "%1"=="-dunicode" copy DocW\* ..\Bin64\MoreHistory
