@Echo off

if /i "%1" == "Far3" (
  echo Not supported
  goto :EOF
)

if not exist ..\..\Units\Noisy\GUI md ..\..\Units\Noisy\GUI
if not exist ..\..\Bin\Noisy md ..\..\Bin\Noisy

windres -i WinNoisyW.rc -o WinNoisyW.RES || exit

fpc.exe -B WinNoisy.dpr %* || exit
