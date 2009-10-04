@Echo off

if not exist ..\..\Units\Noisy\GUI md ..\..\Units\Noisy\GUI
if not exist ..\..\Bin\Noisy md ..\..\Bin\Noisy

rem brcc32 WinNoisyW.rc || exit

fpc.exe -B WinNoisy.dpr %* || exit
