@Echo off

if /i "%1" == "Far3" (
  echo Not supported
  goto :EOF
)

call _bld_plug fpc64 Cursors FarHintsCursors %1 %2 %3
call _bld_plug fpc64 Folders FarHintsFolders %1 %2 %3
call _bld_plug fpc64 Image FarHintsImage %1 %2 %3
call _bld_plug fpc64 MP3 FarHintsMP3 %1 %2 %3
call _bld_plug fpc64 VerInfo FarHintsVerInfo %1 %2 %3
call _bld_plug fpc64 Process FarHintsProcess %1 %2 %3
