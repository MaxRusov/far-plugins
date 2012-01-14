{------------------------------------------------------------------------------}

{$Define bUnicodeFar}  
{$Define bUnicode}

{$ifdef Far3}

 {$Define bUseProcessConsoleInput}
 {$Define bUseInject}

{$else}

 {$Define bUseInject}

{$endif Far3}

{------------------------------------------------------------------------------}
