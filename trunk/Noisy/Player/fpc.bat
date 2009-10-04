@Echo off

if not exist ..\..\Units\Noisy\Player md ..\..\Units\Noisy\Player
if not exist ..\..\Bin\Noisy md ..\..\Bin\Noisy

rem brcc32 NoisyW.rc || exit

fpc.exe -B Noisy.dpr %* || exit

