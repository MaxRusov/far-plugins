@Echo off

if not exist ..\Units\PictureView md ..\Units\PictureView
if not exist ..\Bin\PictureView md ..\Bin\PictureView
if exist GDIPlus.cfg del GDIPlus.cfg

brcc32 GDIPlus.rc || exit

dcc32.exe -B GDIPlus.dpr %* || exit
