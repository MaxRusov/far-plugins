@Echo off

if not exist ..\Units\PanelTabs md ..\Units\PanelTabs
if not exist ..\Bin\PanelTabs md ..\Bin\PanelTabs
if exist PanelTabs.cfg del PanelTabs.cfg

brcc32 PanelTabsA.rc || exit
brcc32 PanelTabsW.rc || exit

dcc32.exe -B PanelTabs.dpr %* || exit

copy Doc\* ..\Bin\PanelTabs
if /i "%1"=="-dunicode" (copy DocW\* ..\Bin\PanelTabs) else (copy DocA\* ..\Bin\PanelTabs)
