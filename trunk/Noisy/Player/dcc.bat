@Echo off

if not exist ..\..\Units\Noisy\Player md ..\..\Units\Noisy\Player
if not exist ..\..\Bin\Noisy md ..\..\Bin\Noisy
if exist Noisy.cfg del Noisy.cfg

brcc32 NoisyW.rc || exit

dcc32.exe -B Noisy.dpr %* || exit
