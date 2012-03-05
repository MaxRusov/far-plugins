@Echo off

if /i "%1" == "Far3" (
  echo Not supported
  goto :EOF
)

if not exist ..\..\Units\Noisy\Player md ..\..\Units\Noisy\Player
if not exist ..\..\Bin\Noisy md ..\..\Bin\Noisy

windres -i NoisyW.rc -o NoisyW.RES || exit

fpc.exe -B Noisy.dpr %* || exit

