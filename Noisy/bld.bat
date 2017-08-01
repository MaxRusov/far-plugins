@Echo off

cd Player
call _bld %1 %2 %3
cd ..

cd Plugin
call _bld %1 %2 %3
cd ..

cd GUI
call _bld %1 %2 %3
cd ..

set BinFolder=
set PrjName=Noisy
