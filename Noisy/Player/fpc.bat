@Echo off

if not exist ..\..\Units\Noisy\Player md ..\..\Units\Noisy\Player
if not exist ..\..\Bin\Noisy md ..\..\Bin\Noisy

windres -i NoisyW.rc -o NoisyW.RES || exit

fpc.exe -B Noisy.dpr %* || exit

