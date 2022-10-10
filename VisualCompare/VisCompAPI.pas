{$I Defines.inc}

unit VisCompAPI;

interface

  uses
    Windows,
    Far_API;

  const
    cVisCompGUID = 'AF4DAB38-C00A-4653-900E-7A8230308010';

  const
    cVisCompAPIRevision = 1;

  type
    IVCFileList = interface;
    IVCContentCallback = interface;

    IVisCompApi = interface(IUnknown)
      ['{30ABFEF8-BB66-438A-B7B4-A2F49C66F197}']
      function GetRevision :Integer; stdcall;
      function CreateFileList :IVCFileList; stdcall;
      function CompareFileLists(const aList1, aList2 :IVCFileList; aOptions :DWORD) :Integer; stdcall;
      function CompareFiles(AFileName1, AFileName2 :PTChar; AOptions :DWORD) :Integer; stdcall;
    end;

    IVCFileList = interface(IUnknown)
      ['{B5DCB0BA-AD83-4FCE-BE23-4C60D5140B85}']
      function GetRoot :PWChar;
      procedure SetRoot(aName :PWChar);
      function GetTag :PWChar;
      procedure SetTag(aValue :PWChar);
      procedure AddFile(aFileName :PWChar; aAttr :Word; aSize :UInt64; aTime :Integer; aCRC :UINT); stdcall;
      procedure SetContentCallback(const aCallback :IVCContentCallback); stdcall;
    end;

    IVCContentCallback = interface(IUnknown)
      ['{2555449E-2C9E-4C14-BDA6-E80E14231744}']
      function GetRealFileName(const aList :IVCFileList; aFolder, aFileName :PWChar) :PWChar; stdcall;
    end;


//    IVCDataProvider = interface(IUnknown)
//      ['{DEA6784D-292E-4AC7-8A52-D63D925817D5}']
//      function OpenPath(const aPath :PWchar) :Boolean;
//      function FetchFile(var aFileName :PWChar; var aAttr :Word; var aSize :UInt64; var aTime :Integer; var aCRC :UINT) :Boolean;
//    end;


  type
    TGetVisCompAPI = function :IVisCompApi; stdcall;


{******************************************************************************}
{******************************} implementation {******************************}
{******************************************************************************}


end.
