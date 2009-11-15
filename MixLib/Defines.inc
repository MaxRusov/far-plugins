{------------------------------------------------------------------------------}

{$ifdef Debug}
  { Отладка }
  {$Define bDebug}       
  {$Define bTrace}
  {$Define bAsserts}
  {$Define bCodeChecks}
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
  {$Undef Unicode}             { Для Delphi 2009+}
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

  {$ifdef CPUX86_64}
   {$Define b64}
  {$endif CPUX86_64}

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
  {$endif Ver130}

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
   {$Define bDelphi12}  { D2009 }
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
   {$Define bDelphi13}  { D2010 }
  {$endif}

  {$ifdef bDelphi12}
   {$Define bUnicodeStr}  { Поддерживается тип UnicodeString }
   {$Define bUnicodeRTL}
  {$endif}

{$endif FPC}

{------------------------------------------------------------------------------}

{$I DefApp.inc}

{------------------------------------------------------------------------------}

{ Опции кодогенерации... }
{$Align On}
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


{$ifdef bFreePascal}
  {Free Pascal}
  {$SmartLink On}
  {$AsmMode Intel}
{$else}
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
   {$WARN SYMBOL_DEPRECATED OFF}
  {$endif bDelphi6}

{$endif bFreePascal}

{------------------------------------------------------------------------------}

