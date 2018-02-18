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

  {$else}

   {$Define bDelphi4}
   {$Define bDelphi5}

   {$if CompilerVersion >= 14.0}
     {$Define bDelphi6}
   {$ifend}

   {$if CompilerVersion >= 15.0}
     {$Define bDelphi7}
   {$ifend}

   {$if CompilerVersion >= 16.0}    
     {$Define bDelphi8}             { D8 - .Net }
   {$ifend}

   {$if CompilerVersion >= 17.0}
     {$Define bDelphi9}             { D2005 }
   {$ifend}

   {$if CompilerVersion >= 18.0}
     {$Define bDelphi10}            { D2006 }
   {$ifend}

   {$if CompilerVersion >= 19.0}    
     {$Define bDelphi11}            { D2007 - .Net }
   {$ifend}

   {$if CompilerVersion >= 20.0}
     {$Define bDelphi12}            { D2009 - +UnicodeString }
   {$ifend}

   {$if CompilerVersion >= 21.0}
     {$Define bDelphi14}            { D2010 }
   {$ifend}

   {$if CompilerVersion >= 22.0}
     {$Define bDelphi15}            { XE }
     {$Define bDelphiXE}            
   {$ifend}

   {$if CompilerVersion >= 23.0}
     {$Define bDelphi16}            { XE2 (Pulsar) - +x64, +OSX }
     {$Define bDelphiXE2}            
   {$ifend}

   {$if CompilerVersion >= 24.0}
     {$Define bDelphi17}            { XE3 }
     {$Define bDelphiXE3}            
   {$ifend}

   {$if CompilerVersion >= 25.0}
     {$Define bDelphi18}            { XE4 - +iOS}
     {$Define bDelphiXE4}            
   {$ifend}

   {$if CompilerVersion >= 26.0}
     {$Define bDelphi19}            { XE5 - +Android }
     {$Define bDelphiXE5}            
   {$ifend}

   {$if CompilerVersion >= 27.0}
     {$Define bDelphi20}
     {$Define bDelphiXE6}            
   {$ifend}

   {$if CompilerVersion >= 28.0}
     {$Define bDelphi21}
     {$Define bDelphiXE7}            
   {$ifend}

   {$if CompilerVersion >= 29.0}
     {$Define bDelphi22}
     {$Define bDelphiXE8}            
   {$ifend}

   {$if CompilerVersion >= 30.0}
     {$Define bDelphi23}            { 10 - Seattle }
   {$ifend}

   {$if CompilerVersion >= 31.0}
     {$Define bDelphi24}            { 10.1 - Berlin }
   {$ifend}

   {$if CompilerVersion >= 32.0}
     {$Define bDelphi25}            { 10.2 - Tokyo }
   {$ifend}

   {$if CompilerVersion >= 33.0}
     !
   {$ifend}

  {$endif}

  {$ifdef Win32}
  {$endif}

  {$ifdef Win64}
   {$Define b64}
  {$endif}

  {$ifdef bDelphi12}
   {$Define bInline}
   {$Define bUnicodeStr}  { Поддерживается тип UnicodeString }
   {$Define bUnicodeRTL}

   {-$Undef bMemCheck}     { Пока не поддерживается }
  {$endif}

  {$ifdef b64}
   {$Define bDelphi64}
   {$Define bStackX64}    { Новая модель стека, без использования RBP }
   {$Undef bMemCheck}     { Пока не поддерживается }
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
 {$Undef bInline}
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
   {$WARN UNSAFE_CAST OFF}
  {$endif bDelphi6}

  {$ifdef bDelphi25}
   {$WARN EXPLICIT_STRING_CAST OFF}
   {$WARN EXPLICIT_STRING_CAST_LOSS OFF}
   {$WARN IMPLICIT_INTEGER_CAST_LOSS OFF}
   {$WARN IMPLICIT_CONVERSION_LOSS OFF}
  {$endif bDelphi25}

  {$ifdef bDelphi15}
   {$Define bExcludeRTTI}
  {$endif bDelphi15}

{$endif bFreePascal}

{------------------------------------------------------------------------------}

