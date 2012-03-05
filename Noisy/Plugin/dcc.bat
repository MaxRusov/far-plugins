@Echo off

if /i "%1" == "Far3" (
  echo Not supported
  goto :EOF
)

if not exist ..\..\Units\Noisy\Plugin md ..\..\Units\Noisy\Plugin
if not exist ..\..\Bin\Noisy md ..\..\Bin\Noisy
if exist NoisyFar.cfg del NoisyFar.cfg

brcc32 NoisyFar.rc || exit
brcc32 NoisyFarW.rc || exit

dcc32.exe -B NoisyFar.dpr %* || exit

copy Doc\* ..\..\Bin\Noisy
if /i "%1"=="-dunicode" (copy DocW\* ..\..\Bin\Noisy)
