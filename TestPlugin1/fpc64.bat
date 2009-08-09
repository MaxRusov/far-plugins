@Echo off

if not exist ..\Units64\HelloWorld md ..\Units64\HelloWorld
if not exist ..\Bin64\HelloWorld md ..\Bin64\HelloWorld

ppcrossx64.exe -B HelloWorld.dpr %* || exit

copy Doc\* ..\Bin64\HelloWorld
