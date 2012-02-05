{$I Defines.inc}

unit FarDraw;

{******************************************************************************}
{* (c) 2010-2012, Max Rusov                                                   *}
{*                                                                            *}
{* Advanced draw support                                                      *}
{******************************************************************************}

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,

    Far_API,
    FarCtrl;


  type
    TDrawBuf = class(TBasis)
    public
      constructor Create; override;
      destructor Destroy; override;

      procedure SetPalette(const APalette :array of TFarColor);

      procedure Clear;
      procedure Add(AChr :TChar; Attr :Byte; ACount :Integer = 1);
      procedure AddStrExpandTabsEx(AStr :PTChar; ALen :Integer; AColor :Byte);
      procedure FillAttr(APos, ACount :Integer; AColor :Byte);
      procedure FillLoAttr(APos, ACount :Integer; ALoColor :Byte);

      procedure Paint(X, Y, ADelta, ALimit :Integer);

    protected
      FTabSize      :Integer;
      FChars        :PTChar;
      FAttrs        :PByteArray;
      FCount        :Integer;
      FSize         :Integer;
      FPalette      :array of TFarColor;

      procedure SetSize(ASize :Integer);

    public
      property Count :Integer read FCount;
    end;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { TDrawBuf                                                                    }
 {-----------------------------------------------------------------------------}

  constructor TDrawBuf.Create; {override;}
  begin
    inherited Create;
    FTabSize := DefTabSize;
  end;


  destructor TDrawBuf.Destroy; {override;}
  begin
    MemFree(FChars);
    MemFree(FAttrs);
    inherited Destroy;
  end;


  procedure TDrawBuf.SetPalette(const APalette :array of TFarColor);
  var
    I :Integer;
  begin
    SetLength(FPalette, High(APalette) + 1);
    for I := 0 to High(APalette) do
      FPalette[I] := APalette[I];
  end;


  procedure TDrawBuf.Clear;
  begin
    FCount := 0;
  end;


  procedure TDrawBuf.Add(AChr :TChar; Attr :Byte; ACount :Integer = 1);
  var
    I :Integer;
  begin
    if FCount + ACount + 1 > FSize then
      SetSize(FCount + ACount + 1);
    for I := 0 to ACount - 1 do begin
      FChars[FCount] := AChr;
      FAttrs[FCount] := Attr;
      Inc(FCount);
    end;
  end;


  procedure TDrawBuf.AddStrExpandTabsEx(AStr :PTChar; ALen :Integer; AColor :Byte);
  var
    vEnd :PTChar;
    vChr :TChar;
    vAtr :Byte;
    vDPos, vDstLen, vSize :Integer;
  begin
    vDstLen := ChrExpandTabsLen(AStr, ALen, FTabSize);
    if FCount + vDstLen + 1 > FSize then
      SetSize(FCount + vDstLen + 1);

    vEnd := AStr + ALen;
    vDPos := 0;
    while AStr < vEnd do begin
      vChr := AStr^;
      vAtr := AColor;

      if vChr <> charTab then begin
        Assert(vDPos < vDstLen);
        Add(vChr, vAtr);
        Inc(vDPos);
      end else
      begin
        vSize := FTabSize - (vDPos mod FTabSize);
        Assert(vDPos + vSize <= vDstLen);
        Add(' ', vAtr, vSize);
        Inc(vDPos, vSize);
      end;
      Inc(AStr);
    end;
    FChars[FCount] := #0;
  end;


  procedure TDrawBuf.FillAttr(APos, ACount :Integer; AColor :Byte);
  begin
    Assert(APos + ACount <= FCount);
    FillChar(FAttrs[APos], ACount, AColor);
  end;


  procedure TDrawBuf.FillLoAttr(APos, ACount :Integer; ALoColor :Byte);
  var
    I :Integer;
  begin
    Assert(APos + ACount <= FCount);
    for I := APos to APos + ACount - 1 do
      FAttrs[I] := (FAttrs[I] and $F0) or (ALoColor and $0F);
  end;


  procedure TDrawBuf.Paint(X, Y, ADelta, ALimit :Integer);
  var
    I, J, vEnd, vPartLen :Integer;
    vAtr :Byte;
    vTmp :TChar;
  begin
    vEnd := FCount;
    if FCount - ADelta > ALimit then
      vEnd := ADelta + ALimit;

    I := ADelta;
    while I < vEnd do begin
      vAtr := FAttrs[I];
      J := I + 1;
      while (J < vEnd) and (FAttrs[J] = vAtr) do
        Inc(J);
      vPartLen := J - I;
      if I + vPartLen = FCount then
        FARAPI.Text(X, Y, FPalette[vAtr], FChars + I )
      else begin
        vTmp := (FChars + I + vPartLen)^;
        (FChars + I + vPartLen)^ := #0;
        FARAPI.Text(X, Y, FPalette[vAtr], FChars + I );
        (FChars + I + vPartLen)^ := vTmp;
      end;
      Inc(X, vPartLen);
      Inc(I, vPartLen);
    end;
  end;


  procedure TDrawBuf.SetSize(ASize :Integer);
  begin
    ReallocMem(FChars, ASize * SizeOf(TChar));
    ReallocMem(FAttrs, ASize * SizeOf(Byte));
    FSize := ASize;
  end;


end.

