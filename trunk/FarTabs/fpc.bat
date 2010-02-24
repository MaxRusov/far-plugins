@Echo off

if not exist ..\Units\PanelTabs md ..\Units\PanelTabs
if not exist ..\Bin\PanelTabs md ..\Bin\PanelTabs

windres -i PanelTabsA.rc -o PanelTabsA.RES || exit
windres -i PanelTabsW.rc -o PanelTabsW.RES || exit

fpc.exe -B PanelTabs.dpr %* || exit

copy Doc\* ..\Bin\PanelTabs
if /i "%1"=="-dunicode" (copy DocW\* ..\Bin\PanelTabs) else (copy DocA\* ..\Bin\PanelTabs)
