@Echo off

call _bld_plug fpc Cursors FarHintsCursors %1 %2 %3
call _bld_plug fpc Folders FarHintsFolders %1 %2 %3
call _bld_plug fpc Image FarHintsImage %1 %2 %3
call _bld_plug fpc MP3 FarHintsMP3 %1 %2 %3
call _bld_plug fpc VerInfo FarHintsVerInfo %1 %2 %3
call _bld_plug fpc Process FarHintsProcess %1 %2 %3

cd FarHints
call _fpc %1 %2 %3
cd ..
