{------------------------------------------------------------------------------}

{$Define Far3}                 { По умолчанию собирается версия для Far3 }
{$Define Unicode}              { По умолчанию собирается Unicode версия }

{$ifdef Debug}
  { Отладка }
  {$Define bDebug}       
  {$Define bTrace}
  {$Define bAsserts}
  {$Define bMemCheck}
{$else}
  { Сборка }
  {$Define bRelease}
  {$Define bOptimization}
{$endif bRelease}

{$ifdef bTrace}
 {$Define bTraceError}
 {$Define bStackFrames}
{$endif bTrace}

{$Define bDebugInfo}
{$Define bWindows}

{$ifdef ANSI}
  {$Undef Unicode}
{$endif ANSI}

{$ifdef Unicode}
  {$Define bUnicode}           { Внутренности плагина - в unicode }
  {$Define bUnicodeFar}        { Far 2 API }
{$endif Unicode}

{------------------------------------------------------------------------------}

{$ifdef FPC}
  {Free Pascal}

  {$Define bFreePascal}
  {$Define bInline}
  {-$Define bUnicodeStr}        { Поддерживается тип UnicodeString }

  {$ifdef CPUX86_64}
   {$Define b64}
  {$endif CPUX86_64}

  {$ifdef Ver2_3}
   {$Define bFPC23}
  {$endif Ver2_3}

  {$ifdef Ver2_4}
   {$Define bFPC23}
   {$Define bFPC24}
  {$endif Ver2_4}

{$else}
  {Delphi}

  {$Define bDelphi}

  {$ifdef Ver120}
   {$Define bDelphi4}
  {$endif Ver120}

  {$ifdef Ver130}
   {$Define bDelphi4}
   {$Define bDelphi5}
  {$endif Ver130}

  {$ifdef Ver140}
   {$Define bDelphi4}
   {$Define bDelphi5}
   {$Define bDelphi6}
  {$endif Ver140}

  {$ifdef Ver150}
   {$Define bDelphi4}
   {$Define bDelphi5}
   {$Define bDelphi6}
   {$Define bDelphi7}
  {$endif Ver150}

  {$ifdef Ver170}
   {$Define bDelphi4}
   {$Define bDelphi5}
   {$Define bDelphi6}
   {$Define bDelphi7}
   {$Define bDelphi8}
   {$Define bDelphi9}
  {$endif Ver150}

  {$ifdef Ver180}
   {$Define bDelphi4}
   {$Define bDelphi5}
   {$Define bDelphi6}
   {$Define bDelphi7}
   {$Define bDelphi8}
   {$Define bDelphi9}
   {$Define bDelphi10}  { D2006 }
  {$endif Ver180}

  {$ifdef Ver200}
   {$Define bDelphi4}
   {$Define bDelphi5}
   {$Define bDelphi6}
   {$Define bDelphi7}
   {$Define bDelphi8}
   {$Define bDelphi9}
   {$Define bDelphi10}
   {$Define bDelphi11}
   {$Define bDelphi12}   // Delphi 2009 - первая юникодная версия
  {$endif}

  {$ifdef Ver210}
   {$Define bDelphi4}
   {$Define bDelphi5}
   {$Define bDelphi6}
   {$Define bDelphi7}
   {$Define bDelphi8}
   {$Define bDelphi9}
   {$Define bDelphi10}
   {$Define bDelphi11}
   {$Define bDelphi12}
   {$Define bDelphi13}  // Delphi 2010
  {$endif}

  {$ifdef Ver220}       
   {$Define bDelphi4}
   {$Define bDelphi5}
   {$Define bDelphi6}
   {$Define bDelphi7}
   {$Define bDelphi8}
   {$Define bDelphi9}
   {$Define bDelphi10}
   {$Define bDelphi11}
   {$Define bDelphi12}
   {$Define bDelphi13}
   {$Define bDelphi14}  // Delphi XE
   {$Define bDelphiXE}
  {$endif}

  {$ifdef Ver230}
   {$Define bDelphi4}
   {$Define bDelphi5}
   {$Define bDelphi6}
   {$Define bDelphi7}
   {$Define bDelphi8}
   {$Define bDelphi9}
   {$Define bDelphi10}
   {$Define bDelphi11}
   {$Define bDelphi12}
   {$Define bDelphi13}
   {$Define bDelphi14}
   {$Define bDelphi15}  // Delphi XE2 (Pulsar) - первая версия с 64-х разрядным компилятором
   {$Define bDelphiXE}
  {$endif}

  {$ifdef Ver240}
   {$Define bDelphi4}
   {$Define bDelphi5}
   {$Define bDelphi6}
   {$Define bDelphi7}
   {$Define bDelphi8}
   {$Define bDelphi9}
   {$Define bDelphi10}
   {$Define bDelphi11}
   {$Define bDelphi12}
   {$Define bDelphi13}
   {$Define bDelphi14}
   {$Define bDelphi15}
   {$Define bDelphi16}  // Delphi XE3
   {$Define bDelphiXE}
  {$endif}

  {$ifdef Ver250}
   !
  {$endif Ver250}

  {$ifdef Ver260}
   !
  {$endif Ver260}

  {$ifdef Ver270}
   !
  {$endif Ver270}

  {$ifdef Ver280}
   !
  {$endif Ver280}

  {$ifdef Ver290}
   !
  {$endif Ver290}

  {$ifdef Ver300}
   !
  {$endif Ver300}

  {$ifdef Ver310}       { "Berlin"}
   {$Define bDelphi4}
   {$Define bDelphi5}
   {$Define bDelphi6}
   {$Define bDelphi7}
   {$Define bDelphi8}
   {$Define bDelphi9}
   {$Define bDelphi10}
   {$Define bDelphi11}
   {$Define bDelphi12}
   {$Define bDelphi13}
   {$Define bDelphi14}
   {$Define bDelphi15}
   {$Define bDelphi16}
   {$Define bDelphiXE}
  {$endif Ver310}


  {$ifdef Win32}
  {$endif}

  {$ifdef Win64}
   {$Define b64}
  {$endif}

  {$ifdef bDelphi12}
   {$Define bInline}
   {$Define bUnicodeStr}  { Поддерживается тип UnicodeString }
   {$Define bUnicodeRTL}

   {$Undef bMemCheck}     { Пока не поддерживается }
  {$endif}

  {$ifdef b64}
   {$Define bDelphi64}
   {$Define bStackX64}    { Новая модель стека, без использования RBP }
  {$else}
   {$Define bOldLocalCall}
  {$endif b64}

{$endif FPC}


{-$ifndef bUnicodeStr}
 {$Define bWideStr}       { Поддерживается тип WideString }
{-$endif bUnicodeStr}


{------------------------------------------------------------------------------}

{$I DefApp.inc}

{------------------------------------------------------------------------------}

{ Опции кодогенерации... }
{$BoolEval Off}
{$IOChecks Off}
{$LongStrings On}
{$MinEnumSize 1}

{ Опции синтаксиса... }
{$ExtendedSyntax On}
{$TypedAddress On}
{$WriteableConst Off}

{ Только для коротких строк... }
{$OpenStrings On}
{$VarStringChecks On}

{$ifdef bDelphi12}
 {$StringChecks Off}
{$endif bDelphi12}

{$ifdef bDelphi16}
 {$StrongLinkTypes Off} 
{$endif bDelphi16}

{$ifdef bFreePascal}
  {Free Pascal}
  {$Align On}
  {$SmartLink On}
  {$AsmMode Intel}
  {$packset 1}
{$else}
  {$ifdef bDelphiXE}
   {$ifdef b64}
     {$A8}
   {$else}
     {$A8} //A4?
   {$endif b64}
  {$else}
   {$Align On}
  {$endif bDelphiXE}
  {$SafeDivide Off}
{$endif bFreePascal}

{------------------------------------------------------------------------------}

{$ifdef bDebug}
 {$RangeChecks On}
 {$OverflowChecks On}
{$else}
 {$RangeChecks Off}
 {$OverflowChecks Off}
{$endif bDebug}

{$ifdef bOptimization}
 {$Stackframes Off}
 {$Optimization On}
{$else}
 {$Stackframes On}
 {$Optimization Off}
{$endif bOptimization}

{$ifdef bStackFrames}
 {$Stackframes On}
{$endif bStackFrames}

{$ifdef bAsserts}
 {$Assertions On}
{$else}
 {$Assertions Off}
{$endif bAsserts}


{$ifdef bFreePascal}
  {Free Pascal}
{$else}

  {$ifdef bDebugInfo}
   {$DebugInfo On}
   {$LocalSymbols On}
   {$ReferenceInfo On}
  {$else}
   {$DebugInfo Off}
  {$endif bDebugInfo}

  {$ifdef bDelphi6}
   {$WARN SYMBOL_PLATFORM OFF}
   {-$WARN SYMBOL_DEPRECATED OFF}
  {$endif bDelphi6}

  {$ifdef bDelphi15}
   {$Define bExcludeRTTI}
  {$endif bDelphi15}

{$endif bFreePascal}

{------------------------------------------------------------------------------}

