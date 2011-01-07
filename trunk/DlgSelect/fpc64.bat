@Echo off

if not exist ..\Units64\DlgSelect md ..\Units64\DlgSelect
if not exist ..\Bin64\DlgSelect md ..\Bin64\DlgSelect

windres -i DlgSelect.rc  -o DlgSelect.RES || exit

ppcrossx64.exe -B DlgSelect.dpr %* || exit

copy Doc\* ..\Bin64\DlgSelect

