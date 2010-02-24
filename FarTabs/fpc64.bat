@Echo off

if not exist ..\Units64\PanelTabs md ..\Units64\PanelTabs
if not exist ..\Bin64\PanelTabs md ..\Bin64\PanelTabs

windres -i PanelTabsA.rc -o PanelTabsA.RES || exit
windres -i PanelTabsW.rc -o PanelTabsW.RES || exit

ppcrossx64.exe -B PanelTabs.dpr %* || exit

copy Doc\* ..\Bin64\PanelTabs
if /i "%1"=="-dunicode" (copy DocW\* ..\Bin64\PanelTabs) else (copy DocA\* ..\Bin64\PanelTabs)
