@Echo off

cd FarHints
call _bld %1 %2 %3
cd ..

cd FarHintsCursors
call _bld %1 %2 %3
cd ..

cd FarHintsFolders
call _bld %1 %2 %3
cd ..

cd FarHintsImage
call _bld %1 %2 %3
cd ..

cd FarHintsMP3
call _bld %1 %2 %3
cd ..

cd FarHintsVerInfo
call _bld %1 %2 %3
cd ..

cd FarHintsProcess
call _bld %1 %2 %3
cd ..

rem cd FarHintsReg
rem call _bld %1 %2 %3
rem cd ..

set PrjName=FarHints
