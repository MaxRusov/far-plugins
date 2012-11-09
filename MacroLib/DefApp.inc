{------------------------------------------------------------------------------}

{$Define bUnicodeFar}  
{$Define bUnicode}

{$ifdef Far3}

 {$Define bUseProcessConsoleInput}
 {$Define bUseInject}

 {$Define bUseKeyMask}

 {$Define bMacroInclude}
 {$Define bLUA}

{$else}

 {$Define bUseInject}

{$endif Far3}

{------------------------------------------------------------------------------}
