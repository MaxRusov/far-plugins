@Echo off

if not exist ..\Units64\PanelTabs md ..\Units64\PanelTabs
if not exist ..\Bin64\PanelTabs md ..\Bin64\PanelTabs

rem windres -i PanelTabsA.rc -o PanelTabsA.res || exit
rem windres -i PanelTabsW.rc -o PanelTabsW.res || exit

ppcrossx64.exe -B PanelTabs.dpr %* || exit

copy Doc\* ..\Bin64\PanelTabs
if /i "%1"=="-dunicode" (copy DocW\* ..\Bin64\PanelTabs) else (copy DocA\* ..\Bin64\PanelTabs)
