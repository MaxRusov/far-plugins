{------------------------------------------------------------------------------}

{-$Define bUnicodeFar}  { Переключаем при сборке }

{$Define bUnicode}
{$Define bUnicodeVCL}

{$Define bUseVCL}

{$Undef bBigStreams}



{------------------------------------------------------------------------------}
{ Микрооптимизация. Исключаем неиспользуемую функциональность                  }

{-$Define bSysUseWinAPIMM}
{-$Undef bSysUseDelphiMM}
{$Undef bSysUseDefaultIO}
{$Undef bSysUseDefaultErrorOutput}

{$Define bSysNoShowUnhandledExceptions}
{$Define bSysIgnoreFarEast}
{$Define bSysNoSerialize}
{$Define bSysNoStream}
{$Define bNoSynchronize}

{$Undef bUseWinExtProc}
{$Undef bUseStreams}
{$Undef bUseThreads}
{$Undef bUseObjCS}
{$Undef bUseCRC}

{------------------------------------------------------------------------------}
