@Echo off

cd ..\ReviewGFL
echo.
call dcc.bat Far3 %*
echo.
call fpc64.bat Far3 %*

cd ..\ReviewVideo
echo.
call dcc.bat Far3 %*
echo.
call fpc64.bat Far3 %*

cd ..\ReviewWIC
echo.
call dcc.bat Far3 %*
echo.
call fpc64.bat Far3 %*

cd ..\Review
call ..\_bld4.bat Review %*
