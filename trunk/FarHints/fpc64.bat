@Echo off

call _bld_plug fpc Cursors FarHintsCursors 64 %1 %2 %3
call _bld_plug fpc Folders FarHintsFolders 64 %1 %2 %3
call _bld_plug fpc Image FarHintsImage 64 %1 %2 %3
call _bld_plug fpc MP3 FarHintsMP3 64 %1 %2 %3
call _bld_plug fpc VerInfo FarHintsVerInfo 64 %1 %2 %3
call _bld_plug fpc Process FarHintsProcess 64 %1 %2 %3

cd FarHints
call _fpc64 %1 %2 %3
cd ..
