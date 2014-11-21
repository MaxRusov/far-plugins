@Echo off

set BinFolder=Noisy
set UnitsFolder=Noisy\Plugin
call ..\..\_fpc.bat NoisyFar 64 %*
