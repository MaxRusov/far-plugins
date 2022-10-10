{$I Defines.inc}

unit GitShellMain;

interface

  uses
    Windows,
    MixTypes,
    MixUtils,
    MixStrings,
    MixClasses,
    Far_API,
    FarCtrl,
    FarPlug,
    FarMenu,
    FarDlg,
    FarGrid,
    FarColorDlg,
    FarListDlg,
    GitShellCtrl,
    GitShellClasses,
    GitShellHistory,
    GitShellBranches,
    GitShellCommit,
    GitShellInfo;

{ ToDo:

  * Управление через командную строку

  * Диалог Pre-Commit:
    * Revert changes
    * Групповые действия
      + Выделение
      - Stage/Unstage
      - Revert changes
    - Сравнение веток через VC
    - Столбец размера
    - Фильтрация
    - Улучшить позиционированпе при Stage/Unstage

  * Диалог истории
    * История файла/каталога
      + Показывать в шапке - что сравнивается
      + При сравнении показывать не все
        + Поддержать маски с wildcard-ми
      * Для файла - сразу показывать сравнение файла
        - Только если запрашивалась история файла
        - Заголовки сравниваемых файлов (доработка VisualCompare)
      - Улучшить фильтрацию commit-ов (не включать merge?)
    - Поддержка TimeZone
    - Показ дерева commit'ов
    - Сравнение неск. коммитов
    - Поддержка FarHints

  * Диалог Branches
    - Запрос на Checkout
    - Имя для Detached Head

  - Диалог Tags

  * Интеграция в VC
    - Убрать лишние имена в дереве сравнения
    - Сравнение без создания файлов?

  - Merge Commit

  - Callback'и для длительных операций

  - Диалог General Settings


  -------
  Готово:

  + Help

  + Загрузка DLL
  + x64
  + Удаление временных файлов

  * Диалог Pre-Commit:
    + Переход в файлу
    + Строки в ресурсы
    + Простой сommit
    + Выглядит некрасиво при 0 файлов

  * Диалог Commit'а
    + Большое поле ввода
    + Указание Author
    + Добавление Commit'а

  + Диалог истории
    + Показ подробной информации
    + Сокращенные ID

  + Информация о репозитории

  + Настройки
    + Сохранение настроек
    + Настройки цветов
}


  type
    TGitShellPlug = class(TFarPlug)
    public
      procedure Init; override;
      procedure Startup; override;
      procedure ExitFar; override;

      procedure GetInfo; override;
      procedure Configure; override;
      function Open(AFrom :Integer; AParam :TIntPtr) :THandle; override;
      function OpenCmdLine(AStr :PTChar) :THandle; override;

    private
      FRepo     :TGitRepository;
      FCmdWords :TKeywordsList;

      procedure InitRepo(const APath :TString);
      procedure RunCommand(const aCmd :TString);
      procedure ShellMenu;
      procedure OptionsMenu;
      procedure ColorMenu;
    end;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}

  uses
    MixDebug;




 {-----------------------------------------------------------------------------}
 { TGitShellPlug                                                               }
 {-----------------------------------------------------------------------------}

  procedure TGitShellPlug.Init; {override;}
  begin
    inherited Init;

    FName := cPluginName;
    FDescr := cPluginDescr;
    FAuthor := cPluginAuthor;
    FVersion := GetSelfVerison; 

    FGUID := cPluginID;
    FMinFarVer := MakeVersion(3, 0, 3000);
  end;


  procedure TGitShellPlug.Startup; {override;}
  begin
    RestoreDefColor;
    ReadSetup;
//  InitKeywords;
  end;


  procedure TGitShellPlug.ExitFar; {override;}
  begin
    FreeObj(FCmdWords);
    FreeObj(FRepo);
    inherited ExitFar;
  end;


  procedure TGitShellPlug.GetInfo; {override;}
  begin
    FFlags := PF_EDITOR or PF_VIEWER;
    FMenuStr := GetMsg(strTitle);
    FConfigStr := GetMsg(strTitle);
   {$ifdef Far3}
    FMenuID  := cMenuID;
    FConfigID := cConfigID;
   {$endif Far3}
    FPrefix := cPluginPrefix;
  end;


  procedure TGitShellPlug.Configure; {override;}
  begin
    OptionsMenu;
  end;


  function TGitShellPlug.Open(AFrom :Integer; AParam :TIntPtr) :THandle; {override;}
  begin
    Result := INVALID_HANDLE_VALUE;

    ReadSetup;

    case AFrom of
      OPEN_PLUGINSMENU:
        ShellMenu;
      OPEN_EDITOR, OPEN_VIEWER:
        ShellMenu;
    else
      Beep;
    end;
  end;


  function TGitShellPlug.OpenCmdLine(AStr :PTChar) :THandle; {override;}
  begin
    Result:= INVALID_HANDLE_VALUE;
    ReadSetup;
//  ShellMenu;
    RunCommand(Trim(AStr));
  end;



  procedure TGitShellPlug.RunCommand(const aCmd :TString);
  const
    kwBranch  = 1;
    kwCommit  = 2;
    kwHist    = 3;

    procedure InitKeywords;
    begin
      if FCmdWords <> nil then
        Exit;
      FCmdWords := TKeywordsList.Create;
      with FCmdWords do begin
        Add('branch', kwBranch);
        Add('commit', kwCommit);
        Add('log', kwHist);
        Add('hist', kwHist);
      end;
    end;

    procedure LocInitRepo(var aPath :TString);
    var
      vPath :TString;
    begin
      if aPath <> '' then begin
        aPath := FarExpandFileName(aPath);
        vPath := aPath;
      end else
        vPath := FarGetCurrentDirectory;
      InitRepo(vPath);
    end;

    procedure LocBranch(aPath :TString);
    begin
      LocInitRepo(aPath);
      FRepo.ShowBranches;
    end;

    procedure LocCommit(aPath :TString);
    begin
      LocInitRepo(aPath);
      FRepo.PrepareCommit(aPath);
    end;

    procedure LocHist(aPath :TString);
    begin
      LocInitRepo(aPath);
      FRepo.ShowHistory(aPath);
    end;


  var
    vPtr :PTChar;
    vCmd :TString;
  begin
    if aCmd = '' then
      ShellMenu
    else begin
      try
        InitKeywords;
        vPtr := PTChar(aCmd);
        vCmd := ExtractNextWord(vPtr, [' '], True);
        case FCmdWords.GetKeywordStr(vCmd) of
          kwBranch : LocBranch(vPtr);
          kwCommit : LocCommit(vPtr);
          kwHist   : LocHist(vPtr);
        else
          Beep;
        end;
      finally
        FreeObj(FRepo);
      end;
    end;
  end;


  procedure TGitShellPlug.ShellMenu;
  var
    vPath :TString;
    vMenu :TFarMenu;
    vRes :Integer;
  begin
    vPath := FarGetCurrentDirectory;
    InitRepo(vPath);
    try

      vRes := 0;
      CloseMainMenu := False;
      while not CloseMainMenu do begin

        vMenu := TFarMenu.CreateEx(
          GetMsg(strTitle),
        [
          PTChar(GetMsg(strMBranch) + ': ' + FRepo.GetCurrentBranchName),
          GetMsg(strMDiff),
          GetMsg(strMHistory),
          GetMsg(strMCommit),
          GetMsg(strMPush),
          GetMsg(strMPull),
          GetMsg(strMInfo),
          '',
          GetMsg(strMOptions)
        ]);
        try
          vMenu.Help := 'MainMenu';
          vMenu.SetSelected(vMenu.ResIdx);

          vMenu.Enabled[4] := False;
          vMenu.Enabled[5] := False;

          vMenu.SetSelected(vRes);

          if not vMenu.Run then
            Exit;

          vRes := vMenu.ResIdx;
          case vRes of
            0: FRepo.ShowBranches;
            1: FRepo.ShowDiff('');
            2: FRepo.ShowHistory(vPath);
            3: FRepo.PrepareCommit(vPath);
            4: Sorry;
            5: Sorry;
            6: FRepo.ShowInfo;
            7: {---};
            8: OptionsMenu;
          end;

        finally
          FreeObj(vMenu);
        end;

      end;

    finally
      FRepo.DeleteTempFiles;
      FreeObj(FRepo);
    end;
  end;


  procedure TGitShellPlug.OptionsMenu;
  var
    vMenu :TFarMenu;
  begin
    vMenu := TFarMenu.CreateEx(
      GetMsg(strTitle),
    [
      GetMsg(strMGeneral),
      '',
      GetMsg(strMColors)
    ]);
    try
      vMenu.Help := 'Options';

      while True do begin
//      vMenu.Checked[0] := optProcessHotkey;

        vMenu.SetSelected(vMenu.ResIdx);

        if not vMenu.Run then
          Exit;

        case vMenu.ResIdx of
          0 : Beep;
          2 : ColorMenu;
        end;
      end;

    finally
      FreeObj(vMenu);
    end;
  end;


  procedure TGitShellPlug.ColorMenu;
  var
    vMenu :TFarMenu;
    vBkColor :DWORD;
    vOk, vChanged :Boolean;
  begin
    vBkColor := GetColorBG(FarGetColor(COL_MENUTEXT));

    vMenu := TFarMenu.CreateEx(
      GetMsg(strColorsTitle),
    [
      GetMsg(strClColumnTitle),
      GetMsg(strClGroup),
      GetMsg(strClSelectedLine),
      GetMsg(strClFilter),
      GetMsg(strClDiffFile),
      GetMsg(strClAddedFile),
      GetMsg(strClDeletedFile),
      '',
      GetMsg(strRestoreDefaults)
    ]);
    try
      vChanged := False;

      while True do begin
        vMenu.SetSelected(vMenu.ResIdx);

        if not vMenu.Run then
          Break;

        case vMenu.ResIdx of
          0: vOk := ColorDlg('', optTitleColor, vBkColor);
          1: vOk := ColorDlg('', optGroupColor, vBkColor);
          2: vOk := ColorDlg('', optSelectedColor);
          3: vOk := ColorDlg('', optFoundColor, vBkColor);
          4: vOk := ColorDlg('', optModColor, vBkColor);
          5: vOk := ColorDlg('', optAddColor, vBkColor);
          6: vOk := ColorDlg('', optDelColor, vBkColor);
        else
          RestoreDefColor;
          vOk := True;
        end;

        if vOk then begin
          FarAdvControl(ACTL_REDRAWALL, nil);
          vChanged := True;
        end;
      end;

      if vChanged then
        WriteSetup;

    finally
      FreeObj(vMenu);
    end;
  end;



  procedure TGitShellPlug.InitRepo(const APath :TString);
  var
    vPath :TString;
  begin
    vPath := AddBackSlash(APath);
    if (FRepo <> nil) and (UpCompareSubStr(FRepo.WorkDir, vPath) <> 0) then
      FreeObj(FRepo);
    if FRepo = nil then
      FRepo := TGitRepository.Create(vPath);
  end;


end.
