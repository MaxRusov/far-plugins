@Echo off

if not exist ..\Units\HelloWorld md ..\Units\HelloWorld
if not exist ..\Bin\HelloWorld md ..\Bin\HelloWorld

dcc32.exe -B HelloWorld.dpr %* || exit

copy Doc\* ..\Bin\HelloWorld
