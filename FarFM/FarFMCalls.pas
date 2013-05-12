{$I Defines.inc}

unit FarFmCalls;

interface

  uses
    Windows,
    ActiveX,
    ShellAPI,
    MSXML,
    WinINet,

    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixCRC,
    Far_API,  //Plugin3.pas
    FarCtrl,

    FarFMCtrl;

    
  const
    {LastFM}
    cLastFmAPI = 'http://ws.audioscrobbler.com/2.0/?method=';
    cFarFmAPIKey = '14a56443d61d426fb3728192526028e6';
    cFarFmSecret = '928a6eb331ca98c54510aeca28a1f227';

    cLFMAuthStr = 'http://www.last.fm/api/auth/?api_key=%s&token=%s';
    cLFMAuthRes = 'http://www.lastfm.ru/api/grantaccess';

  const
    {VK.com}
    cVKApiID = '3435219';
//  cVKApiKey = 'sQ0qruxwL3nUqIg1qcAz';

    cVkApi = 'https://api.vk.com/method/';
    cVkAuthStr = 'http://oauth.vk.com/authorize?client_id=%s&scope=audio&redirect_uri=http://oauth.vk.com/blank.html&display=page&response_type=token';
    cVkAuthRes = 'http://oauth.vk.com/blank.html#access_token=';


  var
    FVKToken  :TString;   { Ключ VK.com }
    FVKUser   :TString;   

    FLFM_SK   :TString;   { Ключ Last.FM }
    FLFMUser  :TString;

  function CreateComObject(const ClassID :TGUID) :IUnknown;


  var
    DownloadCallback :procedure(const AURL :TString; ASize :TIntPtr) of object = nil;

  procedure HTTPDownload(const AURL :TString; const AFileName :TString);

  function XMLParseNode(const ADoc :IXMLDOMDocument; const ANode :TString; const AAttr :TString = '') :TString;
  function XMLParseArray(const ADoc :IXMLDOMDocument; const ANodes :TString; const ASubNodes :array of TString) :TStringArray2;

  function LastFMCall(const AMethod :TString; const Args :array of TString; ASign :Boolean = False; APost :Boolean = False) :IXMLDOMDocument;
  function LastFmCall1(const AMethod :TString; const Args :array of TString; const ANode :TString; const ASubNodes :array of TString) :TStringArray2;
  procedure LastFMPost(const AMethod :TString; const Args :array of TString);

  function VkCall(const AMethod :TString; const Args :array of TString; RecallOnTimeout :Boolean = True) :IXMLDOMDocument;

{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;



  const
    cNeedMask = ['?', '&', '\', '%'];

  function StrMaskURL(const AStr :TString) :TString;
  const
    HexChars :array[0..15] of TChar = ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');
  var
    I, vLen :Integer;
    vStr :TAnsiStr;
    vChr :PAnsiChar;
    vDst :PWideChar;
  begin
    vStr := WideToUTF8(AStr);

    vLen := 0;
    vChr := PAnsiChar(vStr);
    for I := 1 to length(vStr) do begin
      if (vChr^ < #$80) and not (vChr^ in cNeedMask) then
        Inc(vLen)
      else
        Inc(vLen, 3);
      Inc(vChr);
    end;

    SetLength(Result, vLen);
    vChr := PAnsiChar(vStr);
    vDst := PWideChar(Result);
    for I := 1 to length(vStr) do begin
      if (vChr^ < #$80) and not (vChr^ in cNeedMask) then begin
        vDst^ := WideChar(vChr^);
        Inc(vDst);
      end else
      begin
        vDst^ := '%';
        Inc(vDst);
        vDst^ := HexChars[(byte(vChr^) shr 4) and $f];
        Inc(vDst);
        vDst^ := HexChars[byte(vChr^) and $f];;
        Inc(vDst);
      end;
      Inc(vChr);
    end;
  end;


 {-----------------------------------------------------------------------------}

  procedure OleError(ErrorCode: HResult);
  begin
    raise EOleSysError.Create('', ErrorCode, 0);
  end;

  procedure OleCheck(Result: HResult);
  begin
    if not Succeeded(Result) then
      OleError(Result);
  end;

  function CreateComObject(const ClassID :TGUID) :IUnknown;
  begin
    OleCheck(CoCreateInstance(ClassID, nil, CLSCTX_INPROC_SERVER or CLSCTX_LOCAL_SERVER, IUnknown, Result));
  end;


 {-----------------------------------------------------------------------------}

  function ParseLastFMErrorDoc(const ADoc :IXMLDOMDocument) :TString; forward;


  procedure HTTPError(ACode :Integer; const AResponse :TString);

    function TryParseLastFMError(const AText :TString) :TString;
    var
      vXML :IXMLDOMDocument;
    begin
      Result := '';
      vXML := CreateComObject(CLASS_DOMDocument) as IXMLDOMDocument;
      if vXML.loadXML(AText) then
        Result := ParseLastFMErrorDoc(vXML);
    end;

  var
    vMess :TString;
  begin
    vMess := '';
    if (ACode = 400) or (ACode = 403) or (ACode = 503) then
      vMess := TryParseLastFMError(AResponse);

    if vMess = '' then begin
      case ACode of
        404: vMess := 'Not found';
      end;

      if vMess = '' then
        vMess := 'Response text:'#10#10 + AResponse;

      vMess := Format('HTTP error code %d.', [ACode]) + #10 + vMess;
    end;

    AppError(vMess);
  end;


  function HTTPGet(const AURL :TString; APost :Boolean = False) :TString;
  var
    vRequest :IXMLHttpRequest;
  begin
    vRequest := CreateComObject(CLASS_XMLHTTPRequest) as IXMLHttpRequest;
   {$ifdef bDebug}
    Trace(AURL);
   {$endif bDebug}
    if APost then
      vRequest.open('POST', AURL, False, '', '')
    else
      vRequest.open('GET', AURL, False, '', '');
    vRequest.send('');
    if vRequest.status <> 200 then
      HTTPError(vRequest.status, vRequest.responseText);
    Result := vRequest.responseText;
  end;


  procedure XMLParseError(const AError :IXMLDOMParseError);
  var
    vStr :TString;
  begin
    vStr := GetMsgStr(strXMLParseError);
    if AError <> nil then
      vStr := vStr + #10 + Trim(AError.reason) {+ ' (code: ' + HexStr(AError.errorCode, 8) + ')'} + #10 + AError.srcText;
    AppError(vStr);
  end;


  function XMLParseNode(const ADoc :IXMLDOMDocument; const ANode :TString; const AAttr :TString = '') :TString;
  var
    vNode, vNode1 :IXMLDOMNode;
    vAttrs :IXMLDOMNamedNodeMap;
  begin
    Result := '';
    vNode := ADoc.selectSingleNode(ANode);
    if vNode <> nil then
      if AAttr = '' then
        Result := vNode.text
      else begin
        vAttrs := vNode.attributes;
        if vAttrs <> nil then begin
          vNode1 := vAttrs.getNamedItem(AAttr);
          if vNode1 <> nil then
            Result := vNode1.Text;
        end;
      end;
  end;


  function XMLParseArray(const ADoc :IXMLDOMDocument; const ANodes :TString; const ASubNodes :array of TString) :TStringArray2;
  var
    I, J :Integer;
    vNodes :IXMLDOMNodeList;
    vNode, vNode1 :IXMLDOMNode;
    vAttrs :IXMLDOMNamedNodeMap;
  begin
    Result := nil;
    vNodes := ADoc.selectNodes(ANodes);
    if vNodes <> nil then begin
      SetLength(Result, vNodes.length, High(ASubNodes) + 1);
      for I := 0 to vNodes.length - 1 do begin
        vNode := vNodes[I];
        for J := 0 to High(ASubNodes) do begin
          if ASubNodes[J] = '' then
            Result[I, J] := vNode.Text
          else
          if ASubNodes[J][1] = '%' then begin
            vAttrs := vNode.attributes;
            if vAttrs <> nil then begin
              vNode1 := vAttrs.getNamedItem(copy(ASubNodes[J], 2, MaxInt));
              if vNode1 <> nil then
                Result[I, J] := vNode1.Text;
            end;
          end else
          begin
            vNode1 := vNode.SelectSingleNode(ASubNodes[J]);
            if vNode1 <> nil then
              Result[I, J] := vNode1.Text;
          end;
        end;
      end;
    end;
  end;

 {-----------------------------------------------------------------------------}


  function ParseLastFMErrorDoc(const ADoc :IXMLDOMDocument) :TString;
  var
    vCode :TString;
  begin
    Result := Trim(XMLParseNode(ADoc, 'lfm/error'));
    if Result <> '' then begin
      vCode := XMLParseNode(ADoc, 'lfm/error', 'code');
      Result := 'LastFM call error' +
        StrIf(vCode <> '', ' (code ' + vCode + ')', '') +
        ':'#10 + Result;
    end;
  end;


  procedure LastFMCallError(const ADoc :IXMLDOMDocument; const AResponse :TString);
  var
    vMess :TString;
  begin
    vMess := ParseLastFMErrorDoc(ADoc);
    if vMess = '' then
      vMess := 'LastFM call error.'#10'Response text:'#10#10 + AResponse;
    AppError(vMess);
  end;


  function LastFMCall(const AMethod :TString; const Args :array of TString; ASign :Boolean = False; APost :Boolean = False) :IXMLDOMDocument;

    function LocMakeSign :TString;
    var
      I :Integer;
      vList :TStringList;
      vStr :TAnsiStr;
    begin
      vList := TStringList.Create;
      try
        vList.Sorted := True;
        vList.Add('method' + AMethod);
        vList.Add('api_key' + cFarFmAPIKey);
        if APost then
          vList.Add('sk' + FLFM_SK);
        for I := 0 to ((High(Args) + 1) div 2) - 1 do
//        vList.Add(Args[I * 2] + StrMaskURL(Args[I * 2 + 1]));
          vList.Add(Args[I * 2] + WideToUTF8(Args[I * 2 + 1]));

        vStr := vList.GetTextStrEx('');
        vStr := vStr + cFarFmSecret;

        Result := GetMD5(PAnsiChar(vStr), Length(vStr));

      finally
        FreeObj(vList);
      end;
    end;

  var
    I :Integer;
    vRequest, vResponse, vStatus :TString;
  begin
    vRequest := cLastFmAPI + AMethod + '&api_key=' + cFarFmAPIKey;
    if APost then
      vRequest := vRequest + '&sk=' + FLFM_SK;
    for I := 0 to ((High(Args) + 1) div 2) - 1 do
      vRequest := vRequest + '&' + Args[I * 2] + '=' + StrMaskURL(Args[I * 2 + 1]);
    if ASign then
      vRequest := vRequest + '&' + 'api_sig=' + LocMakeSign;

    vResponse := HTTPGet(vRequest, APost);
   {$ifdef bDebug}
    Trace(vResponse);
   {$endif bDebug}

    Result := CreateComObject(CLASS_DOMDocument) as IXMLDOMDocument;
    if not Result.loadXML(vResponse) then
      XMLParseError(Result.parseError);

    vStatus := XMLParseNode(Result, 'lfm', 'status');
    if not StrEqual(vStatus, 'ok') then
      LastFMCallError(Result, vResponse);
  end;


  procedure LastFMPost(const AMethod :TString; const Args :array of TString);
  begin
    LastFMCall(AMethod, Args, True, True);
  end;


  function LastFmCall1(const AMethod :TString; const Args :array of TString; const ANode :TString; const ASubNodes :array of TString) :TStringArray2;
  var
    vDoc :IXMLDOMDocument;
  begin
    vDoc := LastFMCall(AMethod, Args);
    Result := XMLParseArray(vDoc, ANode, ASubNodes);
  end;


 {-----------------------------------------------------------------------------}

  procedure VkCallError(const ADoc :IXMLDOMDocument; const AResponse :TString);
  var
    vMess, vCode :TString;
  begin
    vMess := Trim(XMLParseNode(ADoc, 'error/error_msg'));
    vCode := Trim(XMLParseNode(ADoc, 'error/error_code'));
    if vMess = '' then
      vMess := 'Response text:'#10#10 + AResponse;

    AppError('VK call error' +
      StrIf(vCode <> '', ' (code ' + vCode + ')', '') + '.'#10 +
      vMess);
  end;


  var
    FCallTime  :DWORD;
    FCallCount :DWORD;


  function VkCall(const AMethod :TString; const Args :array of TString; RecallOnTimeout :Boolean = True) :IXMLDOMDocument;
  const
    cSafePeriod = 1200;
    cMaxCallPerSecond = 3;
    cMaxTry = 5;
  var
    I, vTry :Integer;
    vRequest, vResponse, vError :TString;
    vTime, vPause :DWORD;
  begin
    vRequest := cVkApi + AMethod + '.xml' + '?access_token=' + FVKToken;
    for I := 0 to ((High(Args) + 1) div 2) - 1 do
      vRequest := vRequest + '&' + Args[I * 2] + '=' + StrMaskURL(Args[I * 2 + 1]);

    vTry := 1;
    while True do begin

      vTime := GetTickCount;
      if (FCallTime = 0) or (TickCountDiff(vTime, FCallTime) > 1000) then begin
        FCallTime := vTime;
        FCallCount := 0;
      end else
      begin
        if FCallCount >= cMaxCallPerSecond then begin
          vPause := cSafePeriod - TickCountDiff(vTime, FCallTime);

//        TraceF('Sleep: %d', [vPause]);
          Sleep(vPause);

          FCallTime := GetTickCount;
          FCallCount := 0;
        end;
      end;

      vResponse := HTTPGet(vRequest);
      Inc(FCallCount);
     {$ifdef bDebug}
      Trace(vResponse);
     {$endif bDebug}

      Result := CreateComObject(CLASS_DOMDocument) as IXMLDOMDocument;
      if not Result.loadXML(vResponse) then
        XMLParseError(Result.parseError);

      vError := XMLParseNode(Result, 'error/error_code');
      if (vError = '6') and RecallOnTimeout and (vTry < cMaxTry) then begin
        Inc(vTry);
        Continue;
      end;

      Break;
    end;

    if vError <> '' then
      VkCallError(Result, vResponse);
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  procedure HTTPDownload(const AURL :TString; const AFileName :TString);
  const
    cBufSize = 32 * 1024;
  var
    vSession, vHandle :HINTERNET;
    vBuffer :array[0..cBufSize - 1] of byte;
    vRead, vDummy :DWORD;
    vFile :THandle;
    vSize :TIntPtr;
    vCode :Integer;
    vStr :TString;
    vAStr :TAnsiStr;
  begin
    try
      vHandle := nil;
      vSession := InternetOpen(cPluginName, INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
      Win32Check( vSession <> nil );
      try
        vHandle := InternetOpenUrl(vSession, PTChar(AURL), nil, 0, 0, 0);
        Win32Check( vHandle <> nil );

        vDummy := 0;
        vRead := SizeOf(vBuffer);
        if not HttpQueryInfo(vHandle, HTTP_QUERY_STATUS_CODE, @vBuffer, vRead, vDummy) then
          RaiseLastWin32Error;

        SetString(vStr, PTChar(@vBuffer), vRead div SizeOf(TChar));
        vCode := Str2IntDef(vStr, 0);

        if vCode <> 200 then begin
          if not InternetReadFile(vHandle, @vBuffer, SizeOf(vBuffer), vRead) then
            RaiseLastWin32Error;
          SetString(vAStr, PAnsiChar(@vBuffer), vRead);
          HTTPError(vCode, vAStr);
        end;

        vFile := FileCreate(AFileName);
        Win32Check(vFile <> INVALID_HANDLE_VALUE);
        try
          try
            vSize := 0;
            while True do begin
              if Assigned(DownloadCallback) then
                DownloadCallback(AURL, vSize);

              if not InternetReadFile(vHandle, @vBuffer, SizeOf(vBuffer), vRead) then
                RaiseLastWin32Error;
              if vRead = 0 then
                Break;

              if FileWrite(vFile, vBuffer, vRead) <> Integer(vRead) then
                RaiseLastWin32Error;

              Inc(vSize, vRead);
            end;

          finally
            FileClose(vFile);
          end;
        except
          DeleteFile(AFileName);
          raise;
        end;

      finally
        InternetCloseHandle(vHandle);
        InternetCloseHandle(vSession);
      end;

    except
      on E :ECtrlBreak do
        raise;
      on E :Exception do
        AppError('Download error'#10 + AURL + #10#10 + E.Message);
    end;
  end;


  procedure HTTPDownload1(const AURL :TString; const AFileName :TString);
 {$ifdef b64}
  begin
    Sorry;
 {$else}
  var
    vRequest :IXMLHttpRequest;
    vBytes :OleVariant;
    vLen :Integer;
    vData :Pointer;
    vFile :THandle;
  begin
    vRequest := CreateComObject(CLASS_XMLHTTPRequest) as IXMLHttpRequest;
   {$ifdef bDebug}
    TraceF('Download: %s...', [AURL]);
   {$endif bDebug}
    vRequest.open('GET', AURL, False, '', '');
    vRequest.send('');
    if vRequest.status <> 200 then
      HTTPError(vRequest.status, vRequest.responseText);
   {$ifdef bDebug}
    Trace('Done');
   {$endif bDebug}

    vBytes := vRequest.responseBody;
    if VarType(vBytes) = (varArray + varByte) then begin
      vLen := VarArrayHighBound(vBytes, 1) + 1;
      vData := VarArrayLock(vBytes);
      try
        vFile := FileCreate(AFileName);
        Win32Check(vFile <> INVALID_HANDLE_VALUE);
        try
          if FileWrite(vFile, vData^, vLen) <> vLen then
            RaiseLastWin32Error
        finally
          FileClose(vFile);
        end;
      finally
        VarArrayUnlock(vBytes);
      end;
    end else
      Wrong;
 {$endif b64}
  end;


(* //
  procedure HTTPDownload(const AURL :TString; const AFileName :TString);
 {$ifdef b64}
  begin
    Sorry;
 {$else}
  var
    vRequest :IXMLHttpRequest;
    vBytes :OleVariant;
    vLen, vRes :Integer;
    vData :Pointer;
    vFile :THandle;
  begin
    vRequest := CreateComObject(CLASS_XMLHTTPRequest) as IXMLHttpRequest;
   {$ifdef bDebug}
    TraceF('Download: %s...', [AURL]);
   {$endif bDebug}
    vRequest.open('GET', AURL, True, '', '');
    vRequest.send('');

    vRes := 0;
    while True do begin
      vRes := vRequest.status;
      if vRes = 200 then
        Break;
      TraceF('Status: %d', [vRes]);
      Sleep(100);
    end;

    if vRes <> 200 then
      HTTPError(vRequest);
   {$ifdef bDebug}
    Trace('Done');
   {$endif bDebug}

    vBytes := vRequest.responseBody;
    if VarType(vBytes) = (varArray + varByte) then begin
      vLen := VarArrayHighBound(vBytes, 1) + 1;
      vData := VarArrayLock(vBytes);
      try
        vFile := FileCreate(AFileName);
        Win32Check(vFile <> INVALID_HANDLE_VALUE);
        try
          if FileWrite(vFile, vData^, vLen) <> vLen then
            RaiseLastWin32Error
        finally
          FileClose(vFile);
        end;
      finally
        VarArrayUnlock(vBytes);
      end;
    end else
      Wrong;
 {$endif b64}
  end;
*)


end.

