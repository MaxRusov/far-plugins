{------------------------------------------------------------------------------}

{$Define bUnicodeFar}  
{$Define bUnicode}

{$ifdef Far3}

 {$Define bUseProcessConsoleInput}
 {$Define bUseInject}

 {$Define bUseKeyMask}

{$else}

 {$Define bUseInject}

{$endif Far3}

{------------------------------------------------------------------------------}
