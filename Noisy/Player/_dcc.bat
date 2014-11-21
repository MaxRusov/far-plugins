@Echo off

rem if not exist ..\..\Units\Noisy\Player md ..\..\Units\Noisy\Player

set BinFolder=Noisy
set UnitsFolder=Noisy\Player

call ..\..\_dcc.bat Noisy %*
