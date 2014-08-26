@Echo off

cd ..\ReviewGFL
call dcc.bat Far3
call fpc64.bat Far3

cd ..\ReviewVideo
call dcc.bat Far3
call fpc64.bat Far3

cd ..\ReviewWIC
call dcc.bat Far3
call fpc64.bat Far3

cd ..\Review
call ..\_bld4.bat Review
