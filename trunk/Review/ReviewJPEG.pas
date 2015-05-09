{$I Defines.inc}

unit ReviewJPEG;

{******************************************************************************}
{* Review - Media viewer plugin for FAR                                       *}
{* 2013, Max Rusov                                                            *}
{* License: WTFPL                                                             *}
{* Home: http://code.google.com/p/far-plugins/                                *}
{******************************************************************************}

interface

  uses
    Windows,
    libJPEG,

    MixTypes,
    MixUtils,
    MixStrings,

    PVApi,
    FarCtrl,
    GDIImageUtil,

    ReviewConst,
    ReviewDecoders,
    ReviewGDIPlus;



  type
    TJPEGView = class(TGPView)
    public
      procedure DecodeImage(ADX, ADY :Integer; const ACallback :TDecodeCallback; ACallbackData :Pointer); override;
    end;


    TReviewJPEGDecoder = class(TReviewGDIDecoder)
    public
      constructor Create; override;
      function NeedPrecache :boolean; override;
      procedure ResetSettings; override;
      function GetState :TDecoderState; override;
      function CanWork(aLoad :Boolean) :Boolean; override;
      function CreateView(const AFileName :TString; ABuf :Pointer; ABufSize :Integer) :TGPView; override;
      function pvdFileOpen(const AFileName :TString; AImage :TReviewImageRec) :Boolean; override;
      
    private
      FLibInited :Boolean;
      FLibLoaded :Boolean;
    end;


//function JPEGRender(const AName :TString; ABuffer :Pointer; ABufSize :Integer;
//  const ASize :TSize; const ACallback :TDecodeCallback; ACallbackData :Pointer) :HBitmap;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


  uses
    MixDebug;



  Procedure error_exit(cinfo: j_common_ptr); Cdecl;
 {$ifdef bTrace}
  var
    vMsg :TAnsiStr;
  begin
    SetLength(vMsg, 256);
    cinfo.err.format_message(cinfo, PAnsiChar(vMsg));
    Trace('JpegLib error: %s', [PAnsiChar(vMsg)]);
 {$else}
  begin
    NOP;
 {$endif bTrace}
  end;


  Procedure output_message(cinfo: j_common_ptr); Cdecl;
 {$ifdef bTrace}
  Var
    vMsg: AnsiString;
  begin
    SetLength(vMsg, 256);
    cinfo.err.format_message(cinfo, PAnsiChar(vMsg));
    Trace('JpegLib message: %s', [PAnsiChar(vMsg)]);
 {$else}
  begin
    NOP;
 {$endif bTrace}
  end;


  Procedure init_source(cinfo: j_decompress_ptr); Cdecl;
  begin
  end;

  Procedure term_source(cinfo: j_decompress_ptr); Cdecl;
  begin
  end;


  Function fill_input_buffer(cinfo: j_decompress_ptr): boolean; Cdecl;
  begin
    Result := False;
  end;

  procedure skip_input_data(cinfo: j_decompress_ptr; num_bytes: Longint); Cdecl;
  begin
    Dec(cinfo.src.bytes_in_buffer, num_bytes);
    Inc(cinfo.src.next_input_byte, num_bytes);
  end;


  function LoadJPEGLib :Boolean;
  var
    vPath :TString;
  begin
    vPath := ExtractFilePath(FARAPI.ModuleName);
    Result := init_libJPEG(AddFileName(vPath, cDefPVDFolder));
    if not Result then begin
      Result := init_libJPEG(vPath);
      if not Result then
        Result := init_libJPEG('');
    end;
  end;


  function JPEGRender(const AName :TString; ABuffer :Pointer; ABufSize :Integer; const ASize :TSize; const ACallback :TDecodeCallback; ACallbackData :Pointer) :HBitmap;

    function LocChooseDenom(ADX, ADY :Integer) :Integer;
    var
      vDenom :Integer;
    begin
      Result := 1;
      while True do begin
        vDenom := Result * 2;
        if (ADX div vDenom < ASize.CX) or (ADY div vDenom < ASize.CY) then
          Exit;
        Result := vDenom;
      end;
    end;
  
  var
   i           :Integer;
   vDecoder    :jpeg_decompress_struct;
   vError      :jpeg_error_mgr;
   vSource     :jpeg_source_mgr;
   vRowSize    :Integer;
   vBitsBuf    :Pointer;
   vPtr        :Pointer1;
  begin
    Result := 0;

//  if not LibInited then begin
//    LibInited := True;
//    LibLoaded := LoadJPEGLib;
//  end;
//  if not LibLoaded then
//    Exit;

    FillZero(vDecoder, SizeOf(vDecoder));
    FillZero(vError, SizeOf(vError));

    vDecoder.err := jpeg_std_error(@vError);
    vError.error_exit := error_exit;
    vError.output_message := output_message;

    jpeg_create_decompress(@vDecoder);
    try
      FillZero(vSource, SizeOf(vSource));
      vSource.init_source := init_source;
      vSource.term_source := term_source;
      vSource.fill_input_buffer := fill_input_buffer;
      vSource.skip_input_data := skip_input_data;
      vSource.resync_to_restart := jpeg_resync_to_restart; { use default method }

      vDecoder.src := @vSource;

      vDecoder.global_state := DSTATE_START;

      vSource.bytes_in_buffer := ABufSize;
      vSource.next_input_byte := ABuffer;

      { read header of jpeg }
      if jpeg_read_header(@vDecoder, False) <> JPEG_HEADER_OK then
        Exit;

      if vDecoder.num_components = 4 then
        vDecoder.out_color_space := DWORD(JCS_CMYK)
      else
        vDecoder.out_color_space := DWORD(JCS_EXT_BGR);

      if (ASize.CX > 0) and (ASize.CY > 0) then
        vDecoder.scale_denom := LocChooseDenom(vDecoder.image_width, vDecoder.image_height);

//    FDecoder.do_fancy_upsampling := True;
//    FDecoder.do_block_smoothing := False;
//    FDecoder.quantize_colors := True;
      vDecoder.dct_method := JDCT_IFAST;

      jpeg_start_decompress(@vDecoder);
      try
        vRowSize := Integer(vDecoder.output_width) * vDecoder.out_color_components;
        vRowSize := (vRowSize + 3) div 4 * 4;

        vBitsBuf := MemAlloc(Integer(vDecoder.output_height) * vRowSize);
        try
         {$ifdef bTrace}
          TraceBegF('JPEG Decode: %d x %d, Denom=%d...', [vDecoder.image_width, vDecoder.image_height, vDecoder.scale_denom]);
         {$endif bTrace}

          vPtr := vBitsBuf;
          for i := 0 To vDecoder.output_height - 1 Do Begin
            jpeg_read_scanlines(@vDecoder, Pointer(@vPtr), 1);
            Inc(vPtr, vRowSize);
          end;

         {$ifdef bTrace}
          TraceEnd('  done');
         {$endif bTrace}

          Result := CreateBitmapAs(
            vDecoder.output_width,
            vDecoder.output_height,
            vDecoder.out_color_components * 8,
            vRowSize,
            vBitsBuf, nil,
            IntIf( vDecoder.out_color_space = DWORD(JCS_CMYK), PVD_CM_CMYK, PVD_CM_BGR),
            0);

        finally
          MemFree(vBitsBuf);
        end;

      finally
        jpeg_finish_decompress(@vDecoder);
      end;

    finally
      jpeg_destroy_decompress(@vDecoder);
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TReviewJPEGDecoder                                                          }
 {-----------------------------------------------------------------------------}

(*
  procedure TJPEGView.DecodeImage(ADX, ADY :Integer; const ACallback :TDecodeCallback; ACallbackData :Pointer);
  var
    vSize :TSize;
    vThumb :HBitmap;
  begin
    vSize := FImgSize;
    if (ADX > 0) and (ADY > 0) {and optUseWinSize При вызове} then
//    CorrectBoundEx(vSize, Size(ADX, ADY));
      vSize := Size(ADX, ADY);

    vThumb := 0;

   {$ifdef bUseLibJPEG}
    if optUseLibJPEG and IsEqualGUID(FFmtID, ImageFormatJPEG) and (FSrcBuf <> nil) then
      vThumb := JPEGRender(FSrcName, FSrcBuf, FSrcSize, vSize, ACallback, ACallbackData);
   {$endif bUseLibJPEG}

    if vThumb = 0 then begin
      LockGDIPlus;
      try
        vThumb := GDIRender(FSrcName, FSrcImage, vSize, ACallback, ACallbackData);
      finally
        UnlockGDIPlus;
      end;
    end;

    if vThumb <> 0 then begin
      SetThumbnail(vThumb);
      FIsThumbnail := False;
    end;
  end;
*)

  procedure TJPEGView.DecodeImage(ADX, ADY :Integer; const ACallback :TDecodeCallback; ACallbackData :Pointer);
  var
    vThumb :HBitmap;
  begin
    vThumb := JPEGRender(FSrcName, FSrcBuf, FSrcSize, Size(ADX, ADY), ACallback, ACallbackData);

    if vThumb <> 0 then begin
      SetThumbnail(vThumb);
      FIsThumbnail := False;
    end else
      inherited DecodeImage(ADX, ADY, ACallback, ACallbackData);
  end;


 {-----------------------------------------------------------------------------}
 { TReviewJPEGDecoder                                                          }
 {-----------------------------------------------------------------------------}

  constructor TReviewJPEGDecoder.Create; {override;}
  begin
    inherited Create;
    FName := 'JPEG';
    FTitle := FName;
    FPriority := MaxInt;
  end;


  function TReviewJPEGDecoder.NeedPrecache :boolean; {override;}
  begin
    Result := True;
  end;


  procedure TReviewJPEGDecoder.ResetSettings; {override;}
  begin
    SetExtensions('JPG,JPEG', '');
  end;


  function TReviewJPEGDecoder.GetState :TDecoderState; {override;}
  begin
    if FInitState <> 2 then
      Result := rdsInternal
    else
      Result := rdsError;
  end;


  function TReviewJPEGDecoder.CanWork(aLoad :Boolean) :Boolean; {override;}
  begin
    if not FLibInited then begin
      FLibInited := True;
      FLibLoaded := LoadJPEGLib;

      if not FLibLoaded then begin
        FInitState := 2;
        FLastError := 'Error load ' + cJPegLibDLLName;
      end;
    end;
    Result := FLibLoaded;
  end;


  function TReviewJPEGDecoder.CreateView(const AFileName :TString; ABuf :Pointer; ABufSize :Integer) :TGPView; {override;}
  begin
    Result := TJPEGView.CreateView(AFileName, ABuf, ABufSize)
  end;


  function TReviewJPEGDecoder.pvdFileOpen(const AFileName :TString; AImage :TReviewImageRec) :Boolean; {override;}
  begin
    if AImage.FSize > AImage.FCacheSize then
      begin Result := False; Exit; end;

    Result := inherited pvdFileOpen(AFileName, AImage);
  end;



end.

