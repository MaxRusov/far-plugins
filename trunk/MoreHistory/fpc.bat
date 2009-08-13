@Echo off

if not exist ..\Units\MoreHistory md ..\Units\MoreHistory
if not exist ..\Bin\MoreHistory md ..\Bin\MoreHistory

fpc.exe -B MoreHistory.dpr %* || exit

copy Doc\* ..\Bin\MoreHistory
if /i "%1"=="-dunicode" copy DocW\* ..\Bin\MoreHistory
