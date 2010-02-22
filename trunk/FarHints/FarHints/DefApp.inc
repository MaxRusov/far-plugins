{------------------------------------------------------------------------------}

{$Define bUnicode}       { Ansi-версия использует Unicode-строки }

{$Define bThumbnail}     { Показывать Explorer Thumbnail }

{$ifdef bUnicodeFar}
 {$Define bSynchroCall}  { Вызов хинта через ProcessSynchroEventW }
{$endif bUnicodeFar}

{$ifdef bTrace}
 {$define bTrace1}
{$endif bTrace}

{------------------------------------------------------------------------------}
