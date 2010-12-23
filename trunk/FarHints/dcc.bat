@Echo off

call _bld_plug dcc Cursors FarHintsCursors %1 %2 %3
call _bld_plug dcc Folders FarHintsFolders %1 %2 %3
call _bld_plug dcc Image FarHintsImage %1 %2 %3
call _bld_plug dcc MP3 FarHintsMP3 %1 %2 %3
call _bld_plug dcc VerInfo FarHintsVerInfo %1 %2 %3
call _bld_plug dcc Process FarHintsProcess %1 %2 %3
rem call _bld_plug dcc Reg FarHintsReg %1 %2 %3

