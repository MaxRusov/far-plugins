{$I Defines.inc}

unit FarHintsDFMMain;

{******************************************************************************}
{* (c) 2007 Max Rusov                                                         *}
{*                                                                            *}
{* FarHints sub-plugin                                                        *}
{******************************************************************************}

interface

  uses
    Windows,
    Messages,
    FarHintsAPI,

    SysUtils,
    Classes,
    Graphics,
    Controls,
    StdCtrls,
    ExtCtrls,
    ComCtrls,
    Forms;


  var
    MaxViewSize   :Integer = 128;


  function GetPluginInterface :IHintPlugin; stdcall;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


  type
    TStrMessage = (
      strName,
      strModified,
      strSize
    );



  function Bounds(ALeft, ATop, AWidth, AHeight :Integer) :TRect;
  begin
    with Result do begin
      Left := ALeft;
      Top := ATop;
      Right := ALeft + AWidth;
      Bottom :=  ATop + AHeight;
    end;
  end;


 {-----------------------------------------------------------------------------}

  var
    gRegistered :Boolean;

  procedure MyRegisterClasses;
  begin
    if not gRegistered then begin
      gRegistered := True;

      RegisterClasses([
        { StdCtrls }
        TGroupBox,
        TLabel,
        TEdit,
        TMemo,
        TComboBox,
        TButton,
        TCheckBox,
        TRadioButton,
        TListBox,
        TScrollBar,
        TStaticText,

        { ExtCtrls }
        TBevel,
        TPanel,
        TImage,

        {ComCtrls}
        TPageControl,
        TTabSheet
      ]);

    end;
  end;


 {-----------------------------------------------------------------------------}

  type
    TMyForm = class(TForm)
    public
      constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
      destructor Destroy; override;

    protected
      procedure WndProc(var Mess :TMessage); override;
      procedure CreateWindowHandle(const Params: TCreateParams); override;
(*    procedure MySetVisible(AValue :Boolean);

    private
      FMyVisible :Boolean;

    published
      property Visible :Boolean read FMyVisible write MySetVisible; *)
    end;

    TMyControl = class(TCustomControl)
    protected
      procedure Paint; override;
      procedure DefineProperties(Filer: TFiler); override;

    private
      procedure SkipPropValue(Reader :TReader);

    published
      property Font;
    end;

    TMyReader = class(TReader)
    public
      constructor Create(AStream :TStream);
    private
      procedure MyFindMethod(Reader: TReader; const MethodName: string; var Address: Pointer; var Error: Boolean);
      procedure MyFindComponentClassEvent(Reader: TReader; const ClassName: string; var ComponentClass: TComponentClass);
      procedure MyReaderError(Reader :TReader; const Mess :string; var Handled: Boolean);
    end;


 {-----------------------------------------------------------------------------}


  constructor TMyForm.CreateNew(AOwner: TComponent; Dummy: Integer = 0); {override;}
  begin
    inherited CreateNew(AOwner);
    DoubleBuffered := True;
  end;


  destructor TMyForm.Destroy; {override;}
  begin
    inherited Destroy;
  end;


  procedure TMyForm.WndProc(var Mess :TMessage); {override;}
  begin
    inherited WndProc(Mess);
  end;


  procedure TMyForm.CreateWindowHandle(const Params: TCreateParams); {override;}
  begin
    inherited CreateWindowHandle(Params);
  end;


(*procedure TMyForm.MySetVisible(AValue :Boolean);
  begin
    {}
  end;*)


 {-----------------------------------------------------------------------------}

  procedure TMyControl.Paint; {override;}
  begin
    with Canvas do begin
//    Pen.Style := psDash;
      Pen.Color := clGray;
//    Brush.Style := bsClear;
      Rectangle(0, 0, Width, Height);
    end;
  end;


  procedure TMyControl.DefineProperties(Filer: TFiler); {override;}
  begin
    with TMyReader(Filer) do
      DefineProperty(PropName, SkipPropValue, nil, False);
  end;


  procedure TMyControl.SkipPropValue(Reader :TReader);
  begin
    TMyReader(Reader).SkipValue;
  end;


 {-----------------------------------------------------------------------------}

  constructor TMyReader.Create(AStream :TStream);
  begin
    inherited Create(AStream, 4096);
    OnFindComponentClass := MyFindComponentClassEvent;
    OnFindMethod := MyFindMethod;
    OnError := MyReaderError;
  end;


  procedure TMyReader.MyFindComponentClassEvent(Reader: TReader; const ClassName: string; var ComponentClass: TComponentClass);
  begin
    if ComponentClass = nil then
      ComponentClass := TMyControl;
  end;


  procedure TMyReader.MyFindMethod(Reader: TReader; const MethodName: string; var Address: Pointer; var Error: Boolean);
  begin
    Error := False;
  end;


  procedure TMyReader.MyReaderError(Reader :TReader; const Mess :string; var Handled: Boolean);
  begin
    Handled := True;
  end;


 {-----------------------------------------------------------------------------}

  function SkipDFMHeader(AStream :TStream) :Boolean;
  var
    vWord :Word;
    vByte :Byte;
  begin
    Result := False;
    if (AStream.Read(vWord, SizeOf(vWord)) <> 2) or (vWord <> $0AFF) then
      Exit;
    AStream.Read(vByte, 1);
    while (AStream.Read(vByte, 1) = 1) and (vByte <> 0) do
      {};
    AStream.Seek(6, soFromCurrent);
    Result := True;
  end;


  function LoadForm(const AFileName :string) :TMyForm;
  var
    vStream :TStream;
    vReader :TMyReader;
    vOk :Boolean;
  begin
    MyRegisterClasses;

    Result := nil; vStream := nil; vReader := nil;
    vOk := False;
    try
      SetFileApisToAnsi;
      try
        vStream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
        if SkipDFMHeader(vStream) then begin
          vReader := TMyReader.Create(vStream);
          Result := TMyForm.CreateNew(nil);
          Result.SetDesigning(True);
          Result.ControlStyle := Result.ControlStyle + [csNoDesignVisible];
          vReader.ReadRootComponent(Result);
          Result.ControlStyle := Result.ControlStyle - [csNoDesignVisible];
          Result.DestroyHandle;
          vOk := True;
        end;
      finally
        FreeAndNil(vReader);
        FreeAndNil(vStream);
        SetFileApisToOEM;
      end;
    except
    end;

    try
      if not vOk then
        FreeAndNil(Result);
    except
    end;
  end;


  function GetFormBitmap(const AFileName :string) :TBitmap;
  var
    vForm :TMyForm;
  begin
    Result := nil;
    try
      vForm := LoadForm(AFileName);
      if vForm <> nil then begin
        try

          vForm.Visible := False;
          vForm.SetDesigning(False);
          vForm.Visible := True;

          Result := vForm.GetFormImage;


        finally

          try
            FreeAndNil(vForm);
          except
          end;

        end;
      end;

    except
      FreeAndNil(Result);
    end;
  end;


 {-----------------------------------------------------------------------------}
 { TMemCanvas                                                                  }
 {-----------------------------------------------------------------------------}

(*
  type
    TMemCanvas = class(TCanvas)
    public
      constructor Create(ACanvas :TCanvas; DX, DY :Integer);
      destructor Destroy; override;

    protected
      FMemDC  :HDC;
      FMemBMP :HBITMAP;
      FOldBMP :HBITMAP;

      procedure InitDC(ACanvas :TCanvas);

    public
      property MemBMP :HBITMAP read FMemBMP;
    end; {TMemCanvas}


  constructor TMemCanvas.Create(ACanvas :TCanvas; DX, DY :Integer);
  begin
    inherited Create;
    FMemBmp := CreateCompatibleBitmap(ACanvas.Handle, DX, DY);
    InitDC(ACanvas);
  end;


  procedure TMemCanvas.InitDC(ACanvas :TCanvas);
  begin
    FMemDC  := CreateCompatibleDC(ACanvas.Handle);
    FOldBMP := SelectObject(FMemDC, FMemBMP);
    Handle  := FMemDC;
  end;


  destructor TMemCanvas.Destroy; {override;}
  begin
    Handle := 0;

    if FOldBmp <> 0 then
      SelectObject(FMemDC, FOldBMP);
    if FMemDC <> 0 then
      DeleteDC(FMemDC);
    if FMemBMP <> 0 then
      DeleteObject(FMemBMP);

    inherited Destroy;
  end;
*)

 {-----------------------------------------------------------------------------}
 { TPluginObject                                                               }
 {-----------------------------------------------------------------------------}

  type
    TPluginObject = class(TInterfacedObject, IHintPlugin, IHintPluginDraw)
    public
      {IHintPlugin}
      procedure InitPlugin(const API :IFarHintsApi; const AInfo :IHintPluginInfo); stdcall;
      procedure DonePlugin; stdcall;
      function Process(const AItem :IFarItem) :Boolean; stdcall;
      procedure PostProcess(const AItem :IFarItem); stdcall;
      procedure DoneItem(const AItem :IFarItem); stdcall;

      {IHintPluginDraw}
      procedure DrawIcon(ADC :HDC; const ARect :TRect; const AItem :IFarItem); stdcall;

    private
      FAPI      :IFarHintsApi;

      FForm     :TForm;
      FImage    :TBitmap;

      FFormSize :TSize;
      FViewSize :TSize;

      function GetMsg(AIndex :TStrMessage) :WideString;
      procedure OnAppException(Sender: TObject; E: Exception);
    end;


  procedure TPluginObject.InitPlugin(const API :IFarHintsApi; const AInfo :IHintPluginInfo); {stdcall;}
  const
    cMinimalRevision = 3;
  begin
    FAPI := API;

    if FAPI.GetRevision < cMinimalRevision then
      FAPI.RaiseError(FAPI.Format('FarHints API revision %d is required', [cMinimalRevision]));

    MaxViewSize := FAPI.GetRegValueInt(HKEY_CURRENT_USER, FAPI.GetRegRoot + '\DFM', 'MaxSize', MaxViewSize);

    Application.OnException := OnAppException;
  end;


  procedure TPluginObject.DonePlugin; {stdcall;}
  begin
    Application.OnException := nil;
  end;


  function TPluginObject.Process(const AItem :IFarItem) :Boolean; {stdcall;}
  var
    vExt :WideString;
  begin
    Result := False;
    vExt := FAPI.ExtractFileExt(AItem.Name);
    if FAPI.CompareStr(vExt, 'dfm') = 0 then begin

(*
      FForm := LoadForm(AItem.FullName);
      if FForm <> nil then begin
        FFormSize.cx := FForm.Width;
        FFormSize.cy := FForm.Height;

        FViewSize := FFormSize;

        {!!!}

        AItem.IconWidth := FViewSize.CX;
        AItem.IconHeight := FViewSize.CY;

        AItem.AddStringInfo(GetMsg(strName), AItem.Name);
        AItem.AddDateInfo(GetMsg(strModified), AItem.Modified);
        AItem.AddInt64Info(GetMsg(strSize), AItem.Size);

        Result := True;
      end;
*)
      FImage := GetFormBitmap(AItem.FullName);
      if FImage <> nil then begin
        FFormSize.cx := FImage.Width;
        FFormSize.cy := FImage.Height;

        FViewSize := FFormSize;

        {!!!}

        AItem.IconWidth := FViewSize.CX;
        AItem.IconHeight := FViewSize.CY;

        AItem.AddStringInfo(GetMsg(strName), AItem.Name);
        AItem.AddDateInfo(GetMsg(strModified), AItem.Modified);
        AItem.AddInt64Info(GetMsg(strSize), AItem.Size);

        Result := True;
      end;

    end;
  end;


  procedure TPluginObject.PostProcess(const AItem :IFarItem); {stdcall;}
  begin
  end;


  procedure TPluginObject.DoneItem(const AItem :IFarItem); {stdcall;}
  begin
(*
    try
      FreeAndNil(FForm);
    except
    end;
*)
    FreeAndNil(FImage);
  end;



  procedure DrawBitmap(ADC :HDC; ABitmap :HBitmap; dX, dY, dW, dH, sX, sY, sW, sH :Integer);
  var
    vDC :HDC;
    vSave :THandle;
  begin
    vDC := CreateCompatibleDC(0);
    vSave := SelectObject(vDC, ABitmap);

//  SetStretchBltMode(ADC, STRETCH_DELETESCANS);
    SetStretchBltMode(ADC, HALFTONE);
    StretchBlt(ADC, dX, dY, dW, dH, vDC, sX, sY, sW, sH, SrcCopy);

    SelectObject(vDC, vSave);
    DeleteDC(vDC);
  end;

  
  procedure TPluginObject.DrawIcon(ADC :HDC; const ARect :TRect; const AItem :IFarItem);
  begin
(*
    try
//    FForm.HandleNeeded;
      FForm.UpdateControlState;
      FForm.PaintTo(ADC, ARect.Left, ARect.Top);
    except
      {};
    end;
*)

    DrawBitmap(ADC, FImage.Handle, ARect.Left, ARect.Top, AItem.IconWidth, AItem.IconHeight, 0, 0, FFormSize.CX, FFormSize.CY);

  end;


  function TPluginObject.GetMsg(AIndex :TStrMessage) :WideString;
  begin
    Result := FAPI.GetMsg(Self, Byte(AIndex));
  end;


  procedure TPluginObject.OnAppException(Sender: TObject; E: Exception);
  begin
    {Nothing}
  end;


 {-----------------------------------------------------------------------------}

  function GetPluginInterface :IHintPlugin; stdcall;
  begin
    Result := TPluginObject.Create;
  end;


end.
