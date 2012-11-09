@Echo off

if /i "%1" == "Far3" (
  echo Not supported
  goto :EOF
)

set BinFolder=Noisy

cd Player
call _dcc %1 %2 %3
cd ..

cd Plugin
call _dcc %1 %2 %3
cd ..

cd GUI
call _dcc %1 %2 %3
cd ..

set BinFolder=
