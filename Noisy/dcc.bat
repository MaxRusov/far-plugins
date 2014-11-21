@Echo off

if /i "%1" == "Far2" (
  echo Not supported
  goto :EOF
)

cd Plugin
call _dcc %1 %2 %3
cd ..

cd Player
call _dcc %1 %2 %3
cd ..

cd GUI
call _dcc %1 %2 %3
cd ..
