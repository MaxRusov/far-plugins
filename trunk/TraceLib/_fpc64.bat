@Echo off

if not exist ..\Units64\TraceLib md ..\Units64\TraceLib

ppcrossx64.exe -B MSTraceLib.dpr %* || exit
