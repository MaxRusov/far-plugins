@Echo off

rem if not exist ..\..\Units\Noisy\Plugin md ..\..\Units\Noisy\Plugin

set BinFolder=Noisy
set UnitsFolder=Noisy\Plugin
call ..\..\_dcc.bat NoisyFar %*
