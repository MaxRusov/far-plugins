{$I Defines.inc}

unit MFVideo_Api;

interface

uses
  Windows,
  Messages,
  ActiveX,

  Win32.MFPlay,

  MixTypes,
  MixUtils,
  MixClasses,
  MixStrings;


  const
    WM_GRAPH_EVENT = WM_APP + 1;


  type
    TMedia = class(TBasis)
    public
      constructor Create; override;
      destructor Destroy; override;

      function Load(const aFileName :TString; aWnd :HWND) :Boolean;

//    procedure SetWindow(aWnd :HWND);
      procedure ResizeWindow(aWnd :HWND; const aRect :TRect);
      procedure Repaint(aWnd :HWND; aDC :HDC);

      procedure GetVideoSize(var aWidth, aHeight :Integer);
      function GetLength :Double;
      function GetPosition :Double;
      procedure SetPosition(aPos :Double);

      procedure Play;
      procedure Stop;
      procedure Pause;

      procedure SetVolume(aValue :Double);

      procedure HandleEvents(aCallback :Pointer);

    private
      FPlayer   :IMFPMediaPlayer;
      FItem     :IMFPMediaItem;

      FIsAudio  :Boolean;
      FIsVideo  :Boolean;

    public
      property IsVideo :Boolean read FIsVideo;
    end;


  function OpenMediaFile(const aFileName :TString; aAppWnd, aVideoWnd :HWND; aFlags :DWORD = 0) :TMedia;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


  uses
    MixDebug;

 {-----------------------------------------------------------------------------}

  constructor TMedia.Create; {override;}
  begin
    inherited Create;
  end;


  destructor TMedia.Destroy; {override;}
  begin
//  if FEvent <> nil then
//     FEvent.SetNotifyWindow(0, 0, 0);

    FreeIntf(FItem);

    if FPlayer <> nil then begin
      FPlayer.Shutdown;
      FreeIntf(FPlayer);
    end;

    inherited Destroy;
  end;


  function TMedia.Load(const aFileName :TString; aWnd :HWND) :Boolean;
  var
    vRes :HResult;
    vHas, vSelected :Boolean;
  begin
   {$ifdef bTrace}
    Trace('CreatePlayer...');
   {$endif bTrace}
//  vRes := MFPCreateMediaPlayer(PTChar(aFileName), True, MFP_OPTION_NONE, nil, aWnd, FPlayer);
    vRes := MFPCreateMediaPlayer(nil, False, MFP_OPTION_NONE, nil, aWnd, FPlayer);
   {$ifdef bTrace}
    TraceF('  Res=%x (%s)', [vRes, SysErrorMessage(vRes)]);
   {$endif bTrace}
    if vRes <> S_OK then
      Exit(False);

   {$ifdef bTrace}
    TraceF('LoadMedia %s...', [aFileName]);
   {$endif bTrace}
    vRes := FPlayer.CreateMediaItemFromURL(PTChar(aFileName), {Sync}True, 0, FItem);
   {$ifdef bTrace}
    TraceF('  Res=%x (%s)', [vRes, SysErrorMessage(vRes)]);
   {$endif bTrace}
    if vRes <> S_OK then
      Exit(False);

    FIsVideo := True;

//    if FItem.HasVideo(vHas, vSelected) = S_OK then
//      FIsVideo := vHas and vSelected;
//
//    if FItem.HasAudio(vHas, vSelected) = S_OK then
//      FIsAudio := vHas and vSelected;

    FPlayer.SetMediaItem(FItem);

    Result := True;
  end;


  procedure TMedia.ResizeWindow(aWnd :HWND; const aRect :TRect);
  begin
//    if FIsVideo then
//      FRenderer.ResizeWindow(aWnd, aRect);
  end;


  procedure TMedia.Repaint(aWnd :HWND; aDC :HDC);
  begin
//    if FIsVideo then
//      FRenderer.Repaint(aWnd, aDC);
  end;


  procedure TMedia.GetVideoSize(var aWidth, aHeight :Integer);
  var
    vSize, vRatio :TSize;
  begin
    aWidth := 0; aHeight := 0;
    if FPlayer.GetNativeVideoSize(vSize, vRatio) = S_OK then begin
      aWidth := vSize.cx;
      aHeight := vSize.cy;
    end;
  end;


  function TMedia.GetLength :Double;
  var
    vVar :TPropVariant;
  begin
    Result := 0;
    if FPlayer.GetDuration(MFP_POSITIONTYPE_100NS, vVar) = S_OK then
      Result := vVar.uhVal.QuadPart / 10000000;
  end;


  function TMedia.GetPosition :Double;
  var
    vVar :TPropVariant;
  begin
    Result := 0;
    if FPlayer.GetPosition(MFP_POSITIONTYPE_100NS, vVar) = S_OK then
      Result := vVar.uhVal.QuadPart / 10000000;
  end;


  procedure TMedia.SetPosition(aPos :Double);
  var
    vVar :TPropVariant;
  begin
    FillZero(vVar, SizeOf(vVar));
    vVar.vt := VT_I8;
    vVar.uhVal.QuadPart := Round(aPos * 10000000);
    FPlayer.SetPosition(MFP_POSITIONTYPE_100NS, @vVar);
  end;


  procedure TMedia.Play;
  begin
    OleCheck(FPlayer.Play);
  end;

  procedure TMedia.Stop;
  begin
    OleCheck(FPlayer.Stop);
  end;

  procedure TMedia.Pause;
  begin
    OleCheck(FPlayer.Pause);
  end;


  procedure TMedia.SetVolume(aValue :Double);
  begin
    if FPlayer <> nil then
      FPlayer.SetVolume(RangeLimitF(aValue, 0, 100) / 100);
  end;


  procedure TMedia.HandleEvents(aCallback :Pointer);
//  var
//    vCode :Integer;
//    vParam1, vParam2 :LONG_PTR;
  begin
//    while Succeeded( FEvent.GetEvent(vCode, vParam1, vParam2, 0)) do begin
//      if Assigned(aCallback) then
//        {};
//      if not Succeeded(FEvent.FreeEventParams(vCOde, vParam1, vParam2)) then
//        break;
//    end;
  end;


 {-----------------------------------------------------------------------------}

  function OpenMediaFile(const aFileName :TString; aAppWnd, aVideoWnd :HWND; aFlags :DWORD = 0) :TMedia;
  var
    vMedia :TMedia;
  begin
    vMedia := nil;
    try
      vMedia := TMedia.Create;

      if vMedia.Load(aFileName, aVideoWnd) then begin
//      if (aWindow <> 0) and vMedia.FIsVideo then
//        vMedia.SetWindow(aWindow);
      end else
        FreeObj(vMedia);

    except
      FreeObj(vMedia);
    end;

    Result := vMedia;
  end;


end.
