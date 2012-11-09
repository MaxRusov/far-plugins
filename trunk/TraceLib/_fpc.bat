@Echo off

if not exist ..\Units\TraceLib md ..\Units\TraceLib

fpc.exe -B MSTraceLib.dpr %* || exit
