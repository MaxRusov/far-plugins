@Echo off

if not exist ..\Units\PanelTabs md ..\Units\PanelTabs
if not exist ..\Bin\PanelTabs md ..\Bin\PanelTabs

rem windres -i PanelTabsA.rc -o PanelTabsA.res || exit
rem windres -i PanelTabsW.rc -o PanelTabsW.res || exit

fpc.exe -B PanelTabs.dpr %* || exit

copy Doc\* ..\Bin\PanelTabs
if /i "%1"=="-dunicode" (copy DocW\* ..\Bin\PanelTabs) else (copy DocA\* ..\Bin\PanelTabs)
