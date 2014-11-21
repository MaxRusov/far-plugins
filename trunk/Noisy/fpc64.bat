@Echo off

if /i "%1" == "Far2" (
  echo Not supported
  goto :EOF
)

cd Plugin
call _fpc64 %1 %2 %3
cd ..

rem cd Player
rem call _fpc64 %1 %2 %3
rem cd ..
 
rem cd GUI
rem call _fpc64 %1 %2 %3
rem cd ..

xcopy /Y ..\Bin3\Noisy\Noisy.exe ..\Bin3x64\Noisy
xcopy /Y ..\Bin3\Noisy\WinNoisy.exe ..\Bin3x64\Noisy
