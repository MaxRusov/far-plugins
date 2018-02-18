{$I Defines.inc}

unit VisCompIntegration;

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    MixCRC,

    VisCompCtrl,
    VisCompFiles,
    VisCompFilesDlg,
    VisCompTextsDlg,
    VisCompAPI;


  type
    TVisCompApi = class(TComBasis, IVisCompApi)
    public
      function _AddRef :Integer; override;
      function _Release :Integer; override;

    private
      {IVisCompApi}
      function GetRevision :Integer; stdcall;
      function CreateFileList :IVCFileList; stdcall;
      function CompareFileLists(const aList1, aList2 :IVCFileList; aOptions :DWORD) :Integer; stdcall;
      function CompareFiles(AFileName1, AFileName2 :PTChar; AOptions :DWORD) :Integer; stdcall;
    end;


  function GetVisCompAPI :IVisCompApi; stdcall;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;


 {-----------------------------------------------------------------------------}
 { TFileItem                                                                   }

  type
    TFileItem = class(TNamedObject)
    public
      constructor Create(const aName :TString; aAttr :Word; aSize :TInt64; aTime :Integer; aCRC :TCRC);

    private
//    FName  :TString;  == Path
      FFile  :TString;
      FAttr  :Word;
      FSize  :TInt64;
      FTime  :Integer;
      FCRC   :TCRC;

    public
      property Path :TString read FName;
    end;


  constructor TFileItem.Create(const aName :TString; aAttr :Word; aSize :TInt64; aTime :Integer; aCRC :TCRC);
  begin
    FName := ExtractFilePath(aName);
    FFile := ExtractFileName(aName);

    FAttr := aAttr;
    FSize := aSize;
    FTime := aTime;
    FCRC  := aCRC;
  end;


 {-----------------------------------------------------------------------------}
 { TVCFileList                                                                 }

  type
    TVCFileList = class(TComBasis, IVCFileList, IBasis)
    public
      constructor Create; override;
      destructor Destroy; override;

    private
      {IVCFileList}
      function GetRoot :PWChar;
      procedure SetRoot(aName :PWChar);
      function GetTag :PWChar;
      procedure SetTag(aValue :PWChar);
      procedure AddFile(aFileName :PWChar; aAttr :Word; aSize :UInt64; aTime :Integer; aCRC :UINT); stdcall;
      procedure SetContentCallback(const aCallback :IVCContentCallback); stdcall;

    private
      FRoot :TString;
      FTag :TString;
      FList :TObjList;
      FContentCallback :IVCContentCallback;
    end;


  constructor TVCFileList.Create; {override;}
  begin
    inherited Create;
    FList := TObjList.Create;
  end;


  destructor TVCFileList.Destroy; {override;}
  begin
    FreeObj(FList);
    inherited Destroy;
  end;


  function TVCFileList.GetRoot :PWChar;
  begin
    Result := PWChar(FRoot);
  end;


  procedure TVCFileList.SetRoot(aName :PWChar);
  begin
    FRoot := aName;
  end;


  function TVCFileList.GetTag :PWChar;
  begin
    Result := PWChar(FTag);
  end;

  procedure TVCFileList.SetTag(aValue :PWChar);
  begin
    FTag := aValue;
  end;


  procedure TVCFileList.AddFile(aFileName :PWChar; aAttr :Word; aSize :UInt64; aTime :Integer; aCRC :UINT);
  begin
    FList.AddSorted( TFileItem.Create(aFileName, aAttr, aSize, aTime, aCRC), 0, dupAccept );
  end;


  procedure TVCFileList.SetContentCallback(const aCallback :IVCContentCallback);
  begin
    FContentCallback := aCallback;
  end;



 {-----------------------------------------------------------------------------}
 { TListProvider                                                               }

  type
    TListProvider = class(TDataProvider)
    public
      constructor Create(const aList :IVCFileList); overload;

      function CanGetFile :Boolean; override;
      function CanGetCRC :Boolean; override;
      function GetViewFileName(const AFolder, AFileName :TString) :TString; override;
      function GetRealFileName(const AFolder, AFileName :TString) :TString; override;
      procedure Enumerate(const AFolder :TString); override;

    private
      FList  :IVCFileList;

      function GetFileList :TVCFileList;
      procedure AddDirs;
    end;


  constructor TListProvider.Create(const aList :IVCFileList);
  begin
    Create;
    FList := aList;
    AddDirs;
  end;


  function TListProvider.GetFileList :TVCFileList;
  begin
    Result := (FList as IBasis).Instance as TVCFileList;
  end;


  function TListProvider.CanGetFile :Boolean;
  begin
    Result := GetFileList.FContentCallback <> nil;
  end;


  function TListProvider.CanGetCRC :Boolean;
  begin
    {!!!}
    Result := True;
  end;


  function TListProvider.GetViewFileName(const AFolder, AFileName :TString) :TString;
  begin
    Result := GetFileList.FRoot + AddFileName(AFolder, AFileName);
  end;


  function TListProvider.GetRealFileName(const AFolder, AFileName :TString) :TString;
  begin
    Assert(CanGetFile);
    Result := GetFileList.FContentCallback.GetRealFileName(FList, PWChar(aFolder), PWChar(aFileName));
  end;



  procedure TListProvider.Enumerate(const AFolder :TString); {override;}
  var
    i :Integer;
    vPath :TString;
    vFiles :TObjList;
    vItem :TFileItem;
  begin
    vFiles := GetFileList.FList;
    vPath := AddBackSlash(AddFileName(FFolder, AFolder));
    if vFiles.FindKey(pointer(vPath), 0, [foBinary], i) then begin
      while i < vFiles.Count do begin
        vItem := vFiles[i];
        if not StrEqual(vItem.Name, vPath) then
          Break;
        FComparator.AddItem(vItem.FFile, vItem.FAttr, vItem.FSize, vItem.FTime, vItem.FCRC);
        i := i + 1;
      end;
    end;
  end;



  procedure TListProvider.AddDirs;
  var
    i :Integer;
    vPaths :TStringList;
    vFiles :TObjList;
    vItem :TFileItem;
    vPath, vLastPath, vFileName :TString;
  begin
    vFiles := GetFileList.FList;
    vPaths := TStringList.Create;
    vPaths.Sorted := True;
    vPaths.Duplicates := dupIgnore;
    try
      vLastPath := '';
      for i := 0 to vFiles.Count - 1 do begin
        vItem := vFiles[i];
        if vLastPath <> vItem.Path then begin
          vPath := vItem.Path;
          while vPath <> '' do begin
            vPaths.Add(vPath);
            vPath := ExtractFilePath(RemoveBackSlash(vPath));
          end;
          vLastPath := vItem.Path;
        end;
      end;

      for i := 0 to vPaths.Count - 1  do begin
        vFileName := RemoveBackSlash(vPaths[i]);
        vFiles.AddSorted( TFileItem.Create(vFileName, faDirectory, 0, 0, 0), 0, dupAccept );
      end;

    finally
      FreeObj(vPaths);
    end;
  end;



  procedure CompareLists(const aList1, aList2 :IVCFileList);
  var
    vSource1, vSource2 :TDataProvider;
    vComp :TComparator;
  begin
    vSource1 := nil; vSource2 := nil; vComp := nil;
    try
      vSource1 := TListProvider.Create(aList1);
      vSource2 := TListProvider.Create(aList2);

      vComp := TComparator.CreateEx(vSource1, vSource2);
      vComp.CompareFolders;

      ShowFilesDlg(vComp);

    finally
      FreeObj(vComp);
      FreeObj(vSource1);
      FreeObj(vSource2);
    end
  end;


 {-----------------------------------------------------------------------------}
 { TVisCompApi                                                                 }
 {-----------------------------------------------------------------------------}

  function TVisCompApi.GetRevision :Integer;
  begin
    Result := cVisCompAPIRevision;
  end;

  function TVisCompApi.CreateFileList :IVCFileList;
  begin
    Result := TVCFileList.Create;
  end;


  function TVisCompApi.CompareFileLists(const aList1, aList2 :IVCFileList; aOptions :DWORD) :Integer; stdcall;
  begin
    try
      CompareLists(aList1, aList2);
      Result := 0;
    except
      on E :Exception do begin
        HandleError(E);
        Result := -1;
      end;
    end;
  end;


  function TVisCompApi.CompareFiles(AFileName1, AFileName2 :PTChar; AOptions :DWORD) :Integer; stdcall;
  begin
    try
      CompareTexts(AFileName1, AFileName2);
      Result := 0;
    except
      on E :Exception do begin
        HandleError(E);
        Result := -1;
      end;
    end;
  end;


  function TVisCompApi._AddRef :Integer; {override;}
  begin
    Result := -1;
  end;

  function TVisCompApi._Release :Integer; {override;}
  begin
    Result := -1;
  end;


 {-----------------------------------------------------------------------------}
 {                                                                             }
 {-----------------------------------------------------------------------------}

  var
    VisCompAPI :TVisCompApi;


  function GetVisCompAPI :IVisCompApi;
  begin
    Result := VisCompAPI;
  end;


initialization
  VisCompAPI := TVisCompApi.Create;

finalization
  FreeObj(VisCompAPI);
end.



