@Echo off

if not exist ..\Units\HelloWorld md ..\Units\HelloWorld
if not exist ..\Bin\HelloWorld md ..\Bin\HelloWorld

fpc.exe -B HelloWorld.dpr %* || exit

copy Doc\* ..\Bin\HelloWorld
