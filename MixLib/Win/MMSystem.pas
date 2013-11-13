{*******************************************************}
{                                                       }
{                Delphi Runtime Library                 }
{                                                       }
{   File: mmsystem.h                                    }
{   Copyright (c) 1992-1998 Microsoft Corporation       }
{   All Rights Reserved.                                }
{                                                       }
{       Translator: Embarcadero Technologies, Inc.      }
{ Copyright(c) 1995-2012 Embarcadero Technologies, Inc. }
{                                                       }
{*******************************************************}

{*******************************************************}
{       Win32 multimedia API Interface Unit             }
{*******************************************************}

unit MMSystem;

{$ALIGN Off}
{-$ALIGN 1}
{$MINENUMSIZE 4}
{$WEAKPACKAGEUNIT}

interface

(*$HPPEMIT '' *)
(*$HPPEMIT '#include <mmsystem.h>' *)
(*$HPPEMIT '' *)

uses Windows;


{***************************************************************************

                    General constants and data types

***************************************************************************}

{ general constants }
const
  {$EXTERNALSYM MAXPNAMELEN}
  MAXPNAMELEN      =  32;    { max product name length (including nil) }
  {$EXTERNALSYM MAXERRORLENGTH}
  MAXERRORLENGTH   = 256;    { max error text length (including nil) }
  {$EXTERNALSYM MAX_JOYSTICKOEMVXDNAME}
  MAX_JOYSTICKOEMVXDNAME = 260; { max oem vxd name length (including nil) }

{***************************************************************************

                         Manufacturer and product IDs

    Used with wMid and wPid fields in WAVEOUTCAPS, WAVEINCAPS,
    MIDIOUTCAPS, MIDIINCAPS, AUXCAPS, JOYCAPS structures.

***************************************************************************}

{ manufacturer IDs }
const
  {$EXTERNALSYM MM_MICROSOFT}
  MM_MICROSOFT            = 1;       { Microsoft Corp. }

{ product IDs }
  {$EXTERNALSYM MM_MIDI_MAPPER}
  MM_MIDI_MAPPER          = 1;       { MIDI Mapper }
  {$EXTERNALSYM MM_WAVE_MAPPER}
  MM_WAVE_MAPPER          = 2;       { Wave Mapper }
  {$EXTERNALSYM MM_SNDBLST_MIDIOUT}
  MM_SNDBLST_MIDIOUT      = 3;       { Sound Blaster MIDI output port }
  {$EXTERNALSYM MM_SNDBLST_MIDIIN}
  MM_SNDBLST_MIDIIN       = 4;       { Sound Blaster MIDI input port  }
  {$EXTERNALSYM MM_SNDBLST_SYNTH}
  MM_SNDBLST_SYNTH        = 5;       { Sound Blaster internal synthesizer }
  {$EXTERNALSYM MM_SNDBLST_WAVEOUT}
  MM_SNDBLST_WAVEOUT      = 6;       { Sound Blaster waveform output }
  {$EXTERNALSYM MM_SNDBLST_WAVEIN}
  MM_SNDBLST_WAVEIN       = 7;       { Sound Blaster waveform input }
  {$EXTERNALSYM MM_ADLIB}
  MM_ADLIB                = 9;       { Ad Lib-compatible synthesizer }
  {$EXTERNALSYM MM_MPU401_MIDIOUT}
  MM_MPU401_MIDIOUT       = 10;      { MPU401-compatible MIDI output port }
  {$EXTERNALSYM MM_MPU401_MIDIIN}
  MM_MPU401_MIDIIN        = 11;      { MPU401-compatible MIDI input port }
  {$EXTERNALSYM MM_PC_JOYSTICK}
  MM_PC_JOYSTICK          = 12;      { Joystick adapter }


{ general data types }
type
  {$EXTERNALSYM VERSION}
  VERSION = UINT;               { major (high byte), minor (low byte) }
  {$EXTERNALSYM MMVERSION}
  MMVERSION = UINT;             { major (high byte), minor (low byte) }
  {$EXTERNALSYM MMRESULT}
  MMRESULT = UINT;              { error return code, 0 means no error }

{ types for wType field in MMTIME struct }
const
  {$EXTERNALSYM TIME_MS}
  TIME_MS         = $0001;  { time in milliseconds }
  {$EXTERNALSYM TIME_SAMPLES}
  TIME_SAMPLES    = $0002;  { number of wave samples }
  {$EXTERNALSYM TIME_BYTES}
  TIME_BYTES      = $0004;  { current byte offset }
  {$EXTERNALSYM TIME_SMPTE}
  TIME_SMPTE      = $0008;  { SMPTE time }
  {$EXTERNALSYM TIME_MIDI}
  TIME_MIDI       = $0010;  { MIDI time }
  {$EXTERNALSYM TIME_TICKS}
  TIME_TICKS      = $0020;  { Ticks within MIDI stream }

{ MMTIME data structure }
type
  PMMTime = ^TMMTime;
  {$EXTERNALSYM mmtime_tag}
  mmtime_tag = record
    case wType: UINT of        { indicates the contents of the variant record }
     TIME_MS:      (ms: DWORD);
     TIME_SAMPLES: (sample: DWORD);
     TIME_BYTES:   (cb: DWORD);
     TIME_TICKS:   (ticks: DWORD);
     TIME_SMPTE: (
        hour: Byte;
        min: Byte;
        sec: Byte;
        frame: Byte;
        fps: Byte;
        dummy: Byte;
        pad: array[0..1] of Byte);
      TIME_MIDI : (songptrpos: DWORD);
  end;
  TMMTime = mmtime_tag;
  {$EXTERNALSYM MMTIME}
  MMTIME = mmtime_tag;


{***************************************************************************

                    Multimedia Extensions Window Messages

***************************************************************************}

{ joystick }
const
  {$EXTERNALSYM MM_JOY1MOVE}
  MM_JOY1MOVE         = $3A0;
  {$EXTERNALSYM MM_JOY2MOVE}
  MM_JOY2MOVE         = $3A1;
  {$EXTERNALSYM MM_JOY1ZMOVE}
  MM_JOY1ZMOVE        = $3A2;
  {$EXTERNALSYM MM_JOY2ZMOVE}
  MM_JOY2ZMOVE        = $3A3;
  {$EXTERNALSYM MM_JOY1BUTTONDOWN}
  MM_JOY1BUTTONDOWN   = $3B5;
  {$EXTERNALSYM MM_JOY2BUTTONDOWN}
  MM_JOY2BUTTONDOWN   = $3B6;
  {$EXTERNALSYM MM_JOY1BUTTONUP}
  MM_JOY1BUTTONUP     = $3B7;
  {$EXTERNALSYM MM_JOY2BUTTONUP}
  MM_JOY2BUTTONUP     = $3B8;

{ MCI }
  {$EXTERNALSYM MM_MCINOTIFY}
  MM_MCINOTIFY        = $3B9;

{ waveform output }
  {$EXTERNALSYM MM_WOM_OPEN}
  MM_WOM_OPEN         = $3BB;
  {$EXTERNALSYM MM_WOM_CLOSE}
  MM_WOM_CLOSE        = $3BC;
  {$EXTERNALSYM MM_WOM_DONE}
  MM_WOM_DONE         = $3BD;

{ waveform input }
  {$EXTERNALSYM MM_WIM_OPEN}
  MM_WIM_OPEN         = $3BE;
  {$EXTERNALSYM MM_WIM_CLOSE}
  MM_WIM_CLOSE        = $3BF;
  {$EXTERNALSYM MM_WIM_DATA}
  MM_WIM_DATA         = $3C0;

{ MIDI input }
  {$EXTERNALSYM MM_MIM_OPEN}
  MM_MIM_OPEN         = $3C1;
  {$EXTERNALSYM MM_MIM_CLOSE}
  MM_MIM_CLOSE        = $3C2;
  {$EXTERNALSYM MM_MIM_DATA}
  MM_MIM_DATA         = $3C3;
  {$EXTERNALSYM MM_MIM_LONGDATA}
  MM_MIM_LONGDATA     = $3C4;
  {$EXTERNALSYM MM_MIM_ERROR}
  MM_MIM_ERROR        = $3C5;
  {$EXTERNALSYM MM_MIM_LONGERROR}
  MM_MIM_LONGERROR    = $3C6;

{ MIDI output }
  {$EXTERNALSYM MM_MOM_OPEN}
  MM_MOM_OPEN         = $3C7;
  {$EXTERNALSYM MM_MOM_CLOSE}
  MM_MOM_CLOSE        = $3C8;
  {$EXTERNALSYM MM_MOM_DONE}
  MM_MOM_DONE         = $3C9;

  {$EXTERNALSYM MM_DRVM_OPEN}
  MM_DRVM_OPEN        = $3D0;
  {$EXTERNALSYM MM_DRVM_CLOSE}
  MM_DRVM_CLOSE       = $3D1;
  {$EXTERNALSYM MM_DRVM_DATA}
  MM_DRVM_DATA        = $3D2;
  {$EXTERNALSYM MM_DRVM_ERROR}
  MM_DRVM_ERROR       = $3D3;

  {$EXTERNALSYM MM_STREAM_OPEN}
  MM_STREAM_OPEN	    = $3D4;
  {$EXTERNALSYM MM_STREAM_CLOSE}
  MM_STREAM_CLOSE	    = $3D5;
  {$EXTERNALSYM MM_STREAM_DONE}
  MM_STREAM_DONE	    = $3D6;
  {$EXTERNALSYM MM_STREAM_ERROR}
  MM_STREAM_ERROR	    = $3D7;

  {$EXTERNALSYM MM_MOM_POSITIONCB}
  MM_MOM_POSITIONCB   = $3CA;

  {$EXTERNALSYM MM_MCISIGNAL}
  MM_MCISIGNAL        = $3CB;
  {$EXTERNALSYM MM_MIM_MOREDATA}
  MM_MIM_MOREDATA     = $3CC;

  {$EXTERNALSYM MM_MIXM_LINE_CHANGE}
  MM_MIXM_LINE_CHANGE     = $3D0;
  {$EXTERNALSYM MM_MIXM_CONTROL_CHANGE}
  MM_MIXM_CONTROL_CHANGE  = $3D1;

{***************************************************************************

                String resource number bases (internal use)

***************************************************************************}

const
  {$EXTERNALSYM MMSYSERR_BASE}
  MMSYSERR_BASE          = 0;
  {$EXTERNALSYM WAVERR_BASE}
  WAVERR_BASE            = 32;
  {$EXTERNALSYM MIDIERR_BASE}
  MIDIERR_BASE           = 64;
  {$EXTERNALSYM TIMERR_BASE}
  TIMERR_BASE            = 96;
  {$EXTERNALSYM JOYERR_BASE}
  JOYERR_BASE            = 160;
  {$EXTERNALSYM MCIERR_BASE}
  MCIERR_BASE            = 256;
  {$EXTERNALSYM MIXERR_BASE}
  MIXERR_BASE            = 1024;

  {$EXTERNALSYM MCI_STRING_OFFSET}
  MCI_STRING_OFFSET      = 512;
  {$EXTERNALSYM MCI_VD_OFFSET}
  MCI_VD_OFFSET          = 1024;
  {$EXTERNALSYM MCI_CD_OFFSET}
  MCI_CD_OFFSET          = 1088;
  {$EXTERNALSYM MCI_WAVE_OFFSET}
  MCI_WAVE_OFFSET        = 1152;
  {$EXTERNALSYM MCI_SEQ_OFFSET}
  MCI_SEQ_OFFSET         = 1216;

{***************************************************************************

                        General error return values

***************************************************************************}

{ general error return values }
const
  {$EXTERNALSYM MMSYSERR_NOERROR}
  MMSYSERR_NOERROR      = 0;                  { no error }
  {$EXTERNALSYM MMSYSERR_ERROR}
  MMSYSERR_ERROR        = MMSYSERR_BASE + 1;  { unspecified error }
  {$EXTERNALSYM MMSYSERR_BADDEVICEID}
  MMSYSERR_BADDEVICEID  = MMSYSERR_BASE + 2;  { device ID out of range }
  {$EXTERNALSYM MMSYSERR_NOTENABLED}
  MMSYSERR_NOTENABLED   = MMSYSERR_BASE + 3;  { driver failed enable }
  {$EXTERNALSYM MMSYSERR_ALLOCATED}
  MMSYSERR_ALLOCATED    = MMSYSERR_BASE + 4;  { device already allocated }
  {$EXTERNALSYM MMSYSERR_INVALHANDLE}
  MMSYSERR_INVALHANDLE  = MMSYSERR_BASE + 5;  { device handle is invalid }
  {$EXTERNALSYM MMSYSERR_NODRIVER}
  MMSYSERR_NODRIVER     = MMSYSERR_BASE + 6;  { no device driver present }
  {$EXTERNALSYM MMSYSERR_NOMEM}
  MMSYSERR_NOMEM        = MMSYSERR_BASE + 7;  { memory allocation error }
  {$EXTERNALSYM MMSYSERR_NOTSUPPORTED}
  MMSYSERR_NOTSUPPORTED = MMSYSERR_BASE + 8;  { function isn't supported }
  {$EXTERNALSYM MMSYSERR_BADERRNUM}
  MMSYSERR_BADERRNUM    = MMSYSERR_BASE + 9;  { error value out of range }
  {$EXTERNALSYM MMSYSERR_INVALFLAG}
  MMSYSERR_INVALFLAG    = MMSYSERR_BASE + 10; { invalid flag passed }
  {$EXTERNALSYM MMSYSERR_INVALPARAM}
  MMSYSERR_INVALPARAM   = MMSYSERR_BASE + 11; { invalid parameter passed }
  {$EXTERNALSYM MMSYSERR_HANDLEBUSY}
  MMSYSERR_HANDLEBUSY   = MMSYSERR_BASE + 12; { handle being used
                                                simultaneously on another
                                                thread (eg callback) }
  {$EXTERNALSYM MMSYSERR_INVALIDALIAS}
  MMSYSERR_INVALIDALIAS = MMSYSERR_BASE + 13; { specified alias not found }
  {$EXTERNALSYM MMSYSERR_BADDB}
  MMSYSERR_BADDB        = MMSYSERR_BASE + 14; { bad registry database }
  {$EXTERNALSYM MMSYSERR_KEYNOTFOUND}
  MMSYSERR_KEYNOTFOUND  = MMSYSERR_BASE + 15; { registry key not found }
  {$EXTERNALSYM MMSYSERR_READERROR}
  MMSYSERR_READERROR    = MMSYSERR_BASE + 16; { registry read error }
  {$EXTERNALSYM MMSYSERR_WRITEERROR}
  MMSYSERR_WRITEERROR   = MMSYSERR_BASE + 17; { registry write error }
  {$EXTERNALSYM MMSYSERR_DELETEERROR}
  MMSYSERR_DELETEERROR  = MMSYSERR_BASE + 18; { registry delete error }
  {$EXTERNALSYM MMSYSERR_VALNOTFOUND}
  MMSYSERR_VALNOTFOUND  = MMSYSERR_BASE + 19; { registry value not found }
  {$EXTERNALSYM MMSYSERR_NODRIVERCB}
  MMSYSERR_NODRIVERCB   = MMSYSERR_BASE + 20; { driver does not call DriverCallback }
  {$EXTERNALSYM MMSYSERR_MOREDATA}
  MMSYSERR_MOREDATA     = MMSYSERR_BASE + 21; { more data to be returned }
  {$EXTERNALSYM MMSYSERR_LASTERROR}
  MMSYSERR_LASTERROR    = MMSYSERR_BASE + 21; { last error in range }

type
  {$EXTERNALSYM HDRVR}
  HDRVR = IntPtr;

{***************************************************************************

                        Installable driver support

***************************************************************************}

type
  PDrvConfigInfoEx = ^TDrvConfigInfoEx;
  {$EXTERNALSYM DRVCONFIGINFOEX}
  DRVCONFIGINFOEX = record
    dwDCISize: DWORD;
    lpszDCISectionName: PWideChar;
    lpszDCIAliasName: PWideChar;
    dnDevNode: DWORD;
  end;
  TDrvConfigInfoEx = DRVCONFIGINFOEX;

const
{ Driver messages }
  {$EXTERNALSYM DRV_LOAD}
  DRV_LOAD                = $0001;
  {$EXTERNALSYM DRV_ENABLE}
  DRV_ENABLE              = $0002;
  {$EXTERNALSYM DRV_OPEN}
  DRV_OPEN                = $0003;
  {$EXTERNALSYM DRV_CLOSE}
  DRV_CLOSE               = $0004;
  {$EXTERNALSYM DRV_DISABLE}
  DRV_DISABLE             = $0005;
  {$EXTERNALSYM DRV_FREE}
  DRV_FREE                = $0006;
  {$EXTERNALSYM DRV_CONFIGURE}
  DRV_CONFIGURE           = $0007;
  {$EXTERNALSYM DRV_QUERYCONFIGURE}
  DRV_QUERYCONFIGURE      = $0008;
  {$EXTERNALSYM DRV_INSTALL}
  DRV_INSTALL             = $0009;
  {$EXTERNALSYM DRV_REMOVE}
  DRV_REMOVE              = $000A;
  {$EXTERNALSYM DRV_EXITSESSION}
  DRV_EXITSESSION         = $000B;
  {$EXTERNALSYM DRV_POWER}
  DRV_POWER               = $000F;
  {$EXTERNALSYM DRV_RESERVED}
  DRV_RESERVED            = $0800;
  {$EXTERNALSYM DRV_USER}
  DRV_USER                = $4000;

type
{ LPARAM of DRV_CONFIGURE message }
  PDrvConfigInfo = ^TDrvConfigInfo;
  {$EXTERNALSYM tagDRVCONFIGINFO}
  tagDRVCONFIGINFO = record
    dwDCISize: DWORD;
    lpszDCISectionName: PWideChar;
    lpszDCIAliasName: PWideChar;
  end;
  TDrvConfigInfo = tagDRVCONFIGINFO;
  {$EXTERNALSYM DRVCONFIGINFO}
  DRVCONFIGINFO = tagDRVCONFIGINFO;

const
{ Supported return values for DRV_CONFIGURE message }
  {$EXTERNALSYM DRVCNF_CANCEL}
  DRVCNF_CANCEL           = $0000;
  {$EXTERNALSYM DRVCNF_OK}
  DRVCNF_OK               = $0001;
  {$EXTERNALSYM DRVCNF_RESTART}
  DRVCNF_RESTART          = $0002;


{ installable driver function prototypes }
type 
  TFNDriverProc = function(dwDriverId: DWORD_PTR; hdrvr: HDRVR;
    msg: UINT; lparam1, lparam2: LPARAM): Longint stdcall;

{$EXTERNALSYM CloseDriver}
function CloseDriver(hDriver: HDRVR; lParam1, lParam2: Longint): Longint; stdcall;
{$EXTERNALSYM OpenDriver}
function OpenDriver(szDriverName: PWideChar; szSectionName: PWideChar; lParam2: Longint): HDRVR; stdcall;
{$EXTERNALSYM SendDriverMessage}
function SendDriverMessage(hDriver: HDRVR; message: UINT; lParam1, lParam2: Longint): Longint; stdcall;
{$EXTERNALSYM DrvGetModuleHandle}
function DrvGetModuleHandle(hDriver: HDRVR): HMODULE; stdcall;
{$EXTERNALSYM GetDriverModuleHandle}
function GetDriverModuleHandle(hDriver: HDRVR): HMODULE; stdcall;
{$EXTERNALSYM DefDriverProc}
function DefDriverProc(dwDriverIdentifier: DWORD_PTR; hdrvr: HDRVR; uMsg: UINT;
  lParam1, lParam2: LPARAM): Longint; stdcall;

{ return values from DriverProc() function }
const
  {$EXTERNALSYM DRV_CANCEL}
  DRV_CANCEL             = DRVCNF_CANCEL;
  {$EXTERNALSYM DRV_OK}
  DRV_OK                 = DRVCNF_OK;
  {$EXTERNALSYM DRV_RESTART}
  DRV_RESTART            = DRVCNF_RESTART;

  {$EXTERNALSYM DRV_MCI_FIRST}
  DRV_MCI_FIRST          = DRV_RESERVED;
  {$EXTERNALSYM DRV_MCI_LAST}
  DRV_MCI_LAST           = DRV_RESERVED + $FFF;


{***************************************************************************

                          Driver callback support

***************************************************************************}

{ flags used with waveOutOpen(), waveInOpen(), midiInOpen(), and }
{ midiOutOpen() to specify the type of the dwCallback parameter. }

const
  {$EXTERNALSYM CALLBACK_TYPEMASK}
  CALLBACK_TYPEMASK   = $00070000;    { callback type mask }
  {$EXTERNALSYM CALLBACK_NULL}
  CALLBACK_NULL       = $00000000;    { no callback }
  {$EXTERNALSYM CALLBACK_WINDOW}
  CALLBACK_WINDOW     = $00010000;    { dwCallback is a HWND }
  {$EXTERNALSYM CALLBACK_TASK}
  CALLBACK_TASK       = $00020000;    { dwCallback is a HTASK }
  {$EXTERNALSYM CALLBACK_FUNCTION}
  CALLBACK_FUNCTION   = $00030000;    { dwCallback is a FARPROC }
  {$EXTERNALSYM CALLBACK_THREAD}
  CALLBACK_THREAD     = CALLBACK_TASK;{ thread ID replaces 16 bit task }
  {$EXTERNALSYM CALLBACK_EVENT}
  CALLBACK_EVENT      = $00050000;    { dwCallback is an EVENT Handle }

{ driver callback prototypes }

type
  TFNDrvCallBack = procedure(hdrvr: HDRVR; uMsg: UINT; dwUser: DWORD_PTR;
    dw1, dw2: DWORD_PTR) stdcall;


{***************************************************************************

                    General MMSYSTEM support

***************************************************************************}

{$EXTERNALSYM mmsystemGetVersion}
function mmsystemGetVersion: UINT; stdcall;

{***************************************************************************

                            Sound support

***************************************************************************}

{$EXTERNALSYM sndPlaySound}
function sndPlaySound(lpszSoundName: LPCWSTR; uFlags: UINT): BOOL; stdcall;
{$EXTERNALSYM sndPlaySoundA}
function sndPlaySoundA(lpszSoundName: LPCSTR; uFlags: UINT): BOOL; stdcall;
{$EXTERNALSYM sndPlaySoundW}
function sndPlaySoundW(lpszSoundName: LPCWSTR; uFlags: UINT): BOOL; stdcall;

{ flag values for wFlags parameter }
const
  {$EXTERNALSYM SND_SYNC}
  SND_SYNC            = $0000;  { play synchronously (default) }
  {$EXTERNALSYM SND_ASYNC}
  SND_ASYNC           = $0001;  { play asynchronously }
  {$EXTERNALSYM SND_NODEFAULT}
  SND_NODEFAULT       = $0002;  { don't use default sound }
  {$EXTERNALSYM SND_MEMORY}
  SND_MEMORY          = $0004;  { lpszSoundName points to a memory file }
  {$EXTERNALSYM SND_LOOP}
  SND_LOOP            = $0008;  { loop the sound until next sndPlaySound }
  {$EXTERNALSYM SND_NOSTOP}
  SND_NOSTOP          = $0010;  { don't stop any currently playing sound }

  {$EXTERNALSYM SND_NOWAIT}
  SND_NOWAIT          = $00002000;  { don't wait if the driver is busy }
  {$EXTERNALSYM SND_ALIAS}
  SND_ALIAS           = $00010000;  { name is a registry alias }
  {$EXTERNALSYM SND_ALIAS_ID}
  SND_ALIAS_ID        = $00110000;  { alias is a predefined ID }
  {$EXTERNALSYM SND_FILENAME}
  SND_FILENAME        = $00020000;  { name is file name }
  {$EXTERNALSYM SND_RESOURCE}
  SND_RESOURCE        = $00040004;  { name is resource name or atom }
  {$EXTERNALSYM SND_PURGE}
  SND_PURGE           = $0040;      { purge non-static events for task }
  {$EXTERNALSYM SND_APPLICATION}
  SND_APPLICATION     = $0080;      { look for application specific association }

  {$EXTERNALSYM SND_SENTRY}
  SND_SENTRY     = $00080000;      { Generate a SoundSentry event with this sound }
  {$EXTERNALSYM SND_RING}
  SND_RING       = $00100000;      { Treat this as a "ring" from a communications app - don't duck me }
  {$EXTERNALSYM SND_SYSTEM}
  SND_SYSTEM     = $00200000;      { Treat this as a system sound }

  {$EXTERNALSYM SND_ALIAS_START}
  SND_ALIAS_START     = 0;   { alias base }

  {$EXTERNALSYM SND_ALIAS_SYSTEMASTERISK}
  SND_ALIAS_SYSTEMASTERISK       = SND_ALIAS_START + (Longint(Ord('S')) or (Longint(Ord('*')) shl 8));
  {$EXTERNALSYM SND_ALIAS_SYSTEMQUESTION}
  SND_ALIAS_SYSTEMQUESTION       = SND_ALIAS_START + (Longint(Ord('S')) or (Longint(Ord('?')) shl 8));
  {$EXTERNALSYM SND_ALIAS_SYSTEMHAND}
  SND_ALIAS_SYSTEMHAND           = SND_ALIAS_START + (Longint(Ord('S')) or (Longint(Ord('H')) shl 8));
  {$EXTERNALSYM SND_ALIAS_SYSTEMEXIT}
  SND_ALIAS_SYSTEMEXIT           = SND_ALIAS_START + (Longint(Ord('S')) or (Longint(Ord('E')) shl 8));
  {$EXTERNALSYM SND_ALIAS_SYSTEMSTART}
  SND_ALIAS_SYSTEMSTART          = SND_ALIAS_START + (Longint(Ord('S')) or (Longint(Ord('S')) shl 8));
  {$EXTERNALSYM SND_ALIAS_SYSTEMWELCOME}
  SND_ALIAS_SYSTEMWELCOME        = SND_ALIAS_START + (Longint(Ord('S')) or (Longint(Ord('W')) shl 8));
  {$EXTERNALSYM SND_ALIAS_SYSTEMEXCLAMATION}
  SND_ALIAS_SYSTEMEXCLAMATION    = SND_ALIAS_START + (Longint(Ord('S')) or (Longint(Ord('!')) shl 8));
  {$EXTERNALSYM SND_ALIAS_SYSTEMDEFAULT}
  SND_ALIAS_SYSTEMDEFAULT        = SND_ALIAS_START + (Longint(Ord('S')) or (Longint(Ord('D')) shl 8));

{$EXTERNALSYM PlaySound}
function PlaySound(pszSound: LPCWSTR; hmod: HMODULE; fdwSound: DWORD): BOOL; stdcall;
{$EXTERNALSYM PlaySoundA}
function PlaySoundA(pszSound: LPCSTR; hmod: HMODULE; fdwSound: DWORD): BOOL; stdcall;
{$EXTERNALSYM PlaySoundW}
function PlaySoundW(pszSound: LPCWSTR; hmod: HMODULE; fdwSound: DWORD): BOOL; stdcall;

{***************************************************************************

                        Waveform audio support

***************************************************************************}

{ waveform audio error return values }
const
  {$EXTERNALSYM WAVERR_BADFORMAT}
  WAVERR_BADFORMAT      = WAVERR_BASE + 0;    { unsupported wave format }
  {$EXTERNALSYM WAVERR_STILLPLAYING}
  WAVERR_STILLPLAYING   = WAVERR_BASE + 1;    { still something playing }
  {$EXTERNALSYM WAVERR_UNPREPARED}
  WAVERR_UNPREPARED     = WAVERR_BASE + 2;    { header not prepared }
  {$EXTERNALSYM WAVERR_SYNC}
  WAVERR_SYNC           = WAVERR_BASE + 3;    { device is synchronous }
  {$EXTERNALSYM WAVERR_LASTERROR}
  WAVERR_LASTERROR      = WAVERR_BASE + 3;    { last error in range }

{ waveform audio data types }
type
  PHWAVE = ^HWAVE;
  {$EXTERNALSYM HWAVE}
  HWAVE = IntPtr;
  PHWAVEIN = ^HWAVEIN;
  {$EXTERNALSYM HWAVEIN}
  HWAVEIN = IntPtr;
  PHWAVEOUT = ^HWAVEOUT;
  {$EXTERNALSYM HWAVEOUT}
  HWAVEOUT = IntPtr;

type
  TFNWaveCallBack = TFNDrvCallBack;

{ wave callback messages }
const
  {$EXTERNALSYM WOM_OPEN}
  WOM_OPEN        = MM_WOM_OPEN;
  {$EXTERNALSYM WOM_CLOSE}
  WOM_CLOSE       = MM_WOM_CLOSE;
  {$EXTERNALSYM WOM_DONE}
  WOM_DONE        = MM_WOM_DONE;
  {$EXTERNALSYM WIM_OPEN}
  WIM_OPEN        = MM_WIM_OPEN;
  {$EXTERNALSYM WIM_CLOSE}
  WIM_CLOSE       = MM_WIM_CLOSE;
  {$EXTERNALSYM WIM_DATA}
  WIM_DATA        = MM_WIM_DATA;

{ device ID for wave device mapper }
  {$EXTERNALSYM WAVE_MAPPER}
  WAVE_MAPPER     = UINT(-1);

{ flags for dwFlags parameter in waveOutOpen() and waveInOpen() }
  {$EXTERNALSYM WAVE_FORMAT_QUERY}
  WAVE_FORMAT_QUERY     = $0001;
  {$EXTERNALSYM WAVE_ALLOWSYNC}
  WAVE_ALLOWSYNC        = $0002;
  {$EXTERNALSYM WAVE_MAPPED}
  WAVE_MAPPED           = $0004;

  {$EXTERNALSYM WAVE_FORMAT_DIRECT}
  WAVE_FORMAT_DIRECT       = $0008;
  {$EXTERNALSYM WAVE_FORMAT_DIRECT_QUERY}
  WAVE_FORMAT_DIRECT_QUERY = WAVE_FORMAT_QUERY or WAVE_FORMAT_DIRECT;
  {$EXTERNALSYM WAVE_MAPPED_DEFAULT_COMMUNICATION_DEVICE}
  WAVE_MAPPED_DEFAULT_COMMUNICATION_DEVICE = $0010;

{ wave data block header }
type
  PWaveHdr = ^TWaveHdr;
  {$EXTERNALSYM wavehdr_tag}
  wavehdr_tag = record
    lpData: PAnsiChar;          { pointer to locked data buffer }
    dwBufferLength: DWORD;      { length of data buffer }
    dwBytesRecorded: DWORD;     { used for input only }
    dwUser: DWORD_PTR;          { for client's use }
    dwFlags: DWORD;             { assorted flags (see defines) }
    dwLoops: DWORD;             { loop control counter }
    lpNext: PWaveHdr;           { reserved for driver }
    reserved: DWORD_PTR;        { reserved for driver }
  end;
  TWaveHdr = wavehdr_tag;
  {$EXTERNALSYM WAVEHDR}
  WAVEHDR = wavehdr_tag;


{ flags for dwFlags field of WAVEHDR }
const
  {$EXTERNALSYM WHDR_DONE}
  WHDR_DONE       = $00000001;              
  {$EXTERNALSYM WHDR_PREPARED}
  WHDR_PREPARED   = $00000002;  { set if this header has been prepared }
  {$EXTERNALSYM WHDR_BEGINLOOP}
  WHDR_BEGINLOOP  = $00000004;  { loop start block }
  {$EXTERNALSYM WHDR_ENDLOOP}
  WHDR_ENDLOOP    = $00000008;  { loop end block }
  {$EXTERNALSYM WHDR_INQUEUE}
  WHDR_INQUEUE    = $00000010;  { reserved for driver }

{ waveform output device capabilities structure }
type
  PWaveOutCapsA = ^TWaveOutCapsA;
  PWaveOutCapsW = ^TWaveOutCapsW;
  PWaveOutCaps = PWaveOutCapsW;
  {$EXTERNALSYM tagWAVEOUTCAPSA}
  tagWAVEOUTCAPSA = record
    wMid: Word;                 { manufacturer ID }
    wPid: Word;                 { product ID }
    vDriverVersion: MMVERSION;  { version of the driver }
    szPname: array[0..MAXPNAMELEN-1] of AnsiChar;  { product name (NULL terminated AnsiString) }
    dwFormats: DWORD;          { formats supported }
    wChannels: WORD;           { number of sources supported }
    wReserved1: WORD;          { packing }
    dwSupport: DWORD;          { functionality supported by driver }
  end;
  {$EXTERNALSYM tagWAVEOUTCAPSW}
  tagWAVEOUTCAPSW = record
    wMid: Word;                 { manufacturer ID }
    wPid: Word;                 { product ID }
    vDriverVersion: MMVERSION;  { version of the driver }
    szPname: array[0..MAXPNAMELEN-1] of WideChar;  { product name (NULL terminated UnicodeString) }
    dwFormats: DWORD;          { formats supported }
    wChannels: WORD;           { number of sources supported }
    wReserved1: WORD;          { packing }
    dwSupport: DWORD;          { functionality supported by driver }
  end;
  {$EXTERNALSYM tagWAVEOUTCAPS}
  tagWAVEOUTCAPS = tagWAVEOUTCAPSW;
  TWaveOutCapsA = tagWAVEOUTCAPSA;
  TWaveOutCapsW = tagWAVEOUTCAPSW;
  TWaveOutCaps = TWaveOutCapsW;
  {$EXTERNALSYM WAVEOUTCAPSA}
  WAVEOUTCAPSA = tagWAVEOUTCAPSA;
  {$EXTERNALSYM WAVEOUTCAPSW}
  WAVEOUTCAPSW = tagWAVEOUTCAPSW;
  {$EXTERNALSYM WAVEOUTCAPS}
  WAVEOUTCAPS = WAVEOUTCAPSW;


{ flags for dwSupport field of WAVEOUTCAPS }
const
  {$EXTERNALSYM WAVECAPS_PITCH}
  WAVECAPS_PITCH          = $0001;   { supports pitch control }
  {$EXTERNALSYM WAVECAPS_PLAYBACKRATE}
  WAVECAPS_PLAYBACKRATE   = $0002;   { supports playback rate control }
  {$EXTERNALSYM WAVECAPS_VOLUME}
  WAVECAPS_VOLUME         = $0004;   { supports volume control }
  {$EXTERNALSYM WAVECAPS_LRVOLUME}
  WAVECAPS_LRVOLUME       = $0008;   { separate left-right volume control }
  {$EXTERNALSYM WAVECAPS_SYNC}
  WAVECAPS_SYNC           = $0010;
  {$EXTERNALSYM WAVECAPS_SAMPLEACCURATE}
  WAVECAPS_SAMPLEACCURATE = $0020;
  {$EXTERNALSYM WAVECAPS_DIRECTSOUND}
  WAVECAPS_DIRECTSOUND    = $0040;

{ waveform input device capabilities structure }
type
  PWaveInCapsA = ^TWaveInCapsA;
  PWaveInCapsW = ^TWaveInCapsW;
  PWaveInCaps = PWaveInCapsW;
  {$EXTERNALSYM tagWAVEINCAPSA}
  tagWAVEINCAPSA = record
    wMid: Word;                   { manufacturer ID }
    wPid: Word;                   { product ID }
    vDriverVersion: MMVERSION;         { version of the driver }
    szPname: array[0..MAXPNAMELEN-1] of AnsiChar;    { product name (NULL terminated AnsiString) }
    dwFormats: DWORD;             { formats supported }
    wChannels: Word;              { number of channels supported }
    wReserved1: Word;             { structure packing }
  end;
  {$EXTERNALSYM tagWAVEINCAPSW}
  tagWAVEINCAPSW = record
    wMid: Word;                   { manufacturer ID }
    wPid: Word;                   { product ID }
    vDriverVersion: MMVERSION;         { version of the driver }
    szPname: array[0..MAXPNAMELEN-1] of WideChar;    { product name (NULL terminated UnicodeString) }
    dwFormats: DWORD;             { formats supported }
    wChannels: Word;              { number of channels supported }
    wReserved1: Word;             { structure packing }
  end;
  {$EXTERNALSYM tagWAVEINCAPS}
  tagWAVEINCAPS = tagWAVEINCAPSW;
  TWaveInCapsA = tagWAVEINCAPSA;
  TWaveInCapsW = tagWAVEINCAPSW;
  TWaveInCaps = TWaveInCapsW;
  {$EXTERNALSYM WAVEINCAPSA}
  WAVEINCAPSA = tagWAVEINCAPSA;
  {$EXTERNALSYM WAVEINCAPSW}
  WAVEINCAPSW = tagWAVEINCAPSW;
  {$EXTERNALSYM WAVEINCAPS}
  WAVEINCAPS = WAVEINCAPSW;


{ defines for dwFormat field of WAVEINCAPS and WAVEOUTCAPS }
const
  {$EXTERNALSYM WAVE_INVALIDFORMAT}
  WAVE_INVALIDFORMAT     = $00000000;       { invalid format }
  {$EXTERNALSYM WAVE_FORMAT_1M08}
  WAVE_FORMAT_1M08       = $00000001;       { 11.025 kHz, Mono,   8-bit  }
  {$EXTERNALSYM WAVE_FORMAT_1S08}
  WAVE_FORMAT_1S08       = $00000002;       { 11.025 kHz, Stereo, 8-bit  }
  {$EXTERNALSYM WAVE_FORMAT_1M16}
  WAVE_FORMAT_1M16       = $00000004;       { 11.025 kHz, Mono,   16-bit }
  {$EXTERNALSYM WAVE_FORMAT_1S16}
  WAVE_FORMAT_1S16       = $00000008;       { 11.025 kHz, Stereo, 16-bit }
  {$EXTERNALSYM WAVE_FORMAT_2M08}
  WAVE_FORMAT_2M08       = $00000010;       { 22.05  kHz, Mono,   8-bit  }
  {$EXTERNALSYM WAVE_FORMAT_2S08}
  WAVE_FORMAT_2S08       = $00000020;       { 22.05  kHz, Stereo, 8-bit  }
  {$EXTERNALSYM WAVE_FORMAT_2M16}
  WAVE_FORMAT_2M16       = $00000040;       { 22.05  kHz, Mono,   16-bit }
  {$EXTERNALSYM WAVE_FORMAT_2S16}
  WAVE_FORMAT_2S16       = $00000080;       { 22.05  kHz, Stereo, 16-bit }
  {$EXTERNALSYM WAVE_FORMAT_4M08}
  WAVE_FORMAT_4M08       = $00000100;       { 44.1   kHz, Mono,   8-bit  }
  {$EXTERNALSYM WAVE_FORMAT_4S08}
  WAVE_FORMAT_4S08       = $00000200;       { 44.1   kHz, Stereo, 8-bit  }
  {$EXTERNALSYM WAVE_FORMAT_4M16}
  WAVE_FORMAT_4M16       = $00000400;       { 44.1   kHz, Mono,   16-bit }
  {$EXTERNALSYM WAVE_FORMAT_4S16}
  WAVE_FORMAT_4S16       = $00000800;       { 44.1   kHz, Stereo, 16-bit }

  {$EXTERNALSYM WAVE_FORMAT_44M08}
  WAVE_FORMAT_44M08       = $00000100;       { 44.1   kHz, Mono,   8-bit  }
  {$EXTERNALSYM WAVE_FORMAT_44S08}
  WAVE_FORMAT_44S08       = $00000200;       { 44.1   kHz, Stereo, 8-bit  }
  {$EXTERNALSYM WAVE_FORMAT_44M16}
  WAVE_FORMAT_44M16       = $00000400;       { 44.1   kHz, Mono,   16-bit }
  {$EXTERNALSYM WAVE_FORMAT_44S16}
  WAVE_FORMAT_44S16       = $00000800;       { 44.1   kHz, Stereo, 16-bit }
  {$EXTERNALSYM WAVE_FORMAT_48M08}
  WAVE_FORMAT_48M08       = $00001000;       { 48     kHz, Mono,   8-bit  }
  {$EXTERNALSYM WAVE_FORMAT_48S08}
  WAVE_FORMAT_48S08       = $00002000;       { 48     kHz, Stereo, 8-bit  }
  {$EXTERNALSYM WAVE_FORMAT_48M16}
  WAVE_FORMAT_48M16       = $00004000;       { 48     kHz, Mono,   16-bit }
  {$EXTERNALSYM WAVE_FORMAT_48S16}
  WAVE_FORMAT_48S16       = $00008000;       { 48     kHz, Stereo, 16-bit }
  {$EXTERNALSYM WAVE_FORMAT_96M08}
  WAVE_FORMAT_96M08       = $00010000;       { 96     kHz, Mono,   8-bit  }
  {$EXTERNALSYM WAVE_FORMAT_96S08}
  WAVE_FORMAT_96S08       = $00020000;       { 96     kHz, Stereo, 8-bit  }
  {$EXTERNALSYM WAVE_FORMAT_96M16}
  WAVE_FORMAT_96M16       = $00040000;       { 96     kHz, Mono,   16-bit }
  {$EXTERNALSYM WAVE_FORMAT_96S16}
  WAVE_FORMAT_96S16       = $00080000;       { 96     kHz, Stereo, 16-bit }


{ general waveform format structure (information common to all formats) }
type
  PWaveFormat = ^TWaveFormat;
  {$EXTERNALSYM waveformat_tag}
  waveformat_tag = record
    wFormatTag: Word;         { format type }
    nChannels: Word;          { number of channels (i.e. mono, stereo, etc.) }
    nSamplesPerSec: DWORD;  { sample rate }
    nAvgBytesPerSec: DWORD; { for buffer estimation }
    nBlockAlign: Word;      { block size of data }
  end;
  TWaveFormat = waveformat_tag;
  {$EXTERNALSYM WAVEFORMAT}
  WAVEFORMAT = waveformat_tag;

{ flags for wFormatTag field of WAVEFORMAT }
const
  {$EXTERNALSYM WAVE_FORMAT_PCM}
  WAVE_FORMAT_PCM     = 1;

{ specific waveform format structure for PCM data }
type
  PPCMWaveFormat = ^TPCMWaveFormat;
  {$EXTERNALSYM pcmwaveformat_tag}
  pcmwaveformat_tag = record
      wf: TWaveFormat;
      wBitsPerSample: Word;
   end;
  TPCMWaveFormat = pcmwaveformat_tag;
  {$EXTERNALSYM PCMWAVEFORMAT}
  PCMWAVEFORMAT = pcmwaveformat_tag;


{ extended waveform format structure used for all non-PCM formats. this
  structure is common to all non-PCM formats. }

  PWaveFormatEx = ^TWaveFormatEx;
  {$EXTERNALSYM tWAVEFORMATEX}
  tWAVEFORMATEX = record
    wFormatTag: Word;         { format type }
    nChannels: Word;          { number of channels (i.e. mono, stereo, etc.) }
    nSamplesPerSec: DWORD;  { sample rate }
    nAvgBytesPerSec: DWORD; { for buffer estimation }
    nBlockAlign: Word;      { block size of data }
    wBitsPerSample: Word;   { number of bits per sample of mono data }
    cbSize: Word;           { the count in bytes of the size of }
  end;


{ waveform audio function prototypes }
{$EXTERNALSYM waveOutGetNumDevs}
function waveOutGetNumDevs: UINT; stdcall;

{$EXTERNALSYM waveOutGetDevCaps}
function waveOutGetDevCaps(uDeviceID: UIntPtr; lpCaps: PWaveOutCaps; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM waveOutGetDevCapsA}
function waveOutGetDevCapsA(uDeviceID: UIntPtr; lpCaps: PWaveOutCapsA; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM waveOutGetDevCapsW}
function waveOutGetDevCapsW(uDeviceID: UIntPtr; lpCaps: PWaveOutCapsW; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM waveOutGetVolume}
function waveOutGetVolume(hwo: HWAVEOUT; lpdwVolume: PDWORD): MMRESULT; stdcall;
{$EXTERNALSYM waveOutSetVolume}
function waveOutSetVolume(hwo: HWAVEOUT; dwVolume: DWORD): MMRESULT; stdcall;
{$EXTERNALSYM waveOutGetErrorText}
function waveOutGetErrorText(mmrError: MMRESULT; lpText: LPWSTR; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM waveOutGetErrorTextA}
function waveOutGetErrorTextA(mmrError: MMRESULT; lpText: LPSTR; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM waveOutGetErrorTextW}
function waveOutGetErrorTextW(mmrError: MMRESULT; lpText: LPWSTR; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM waveOutOpen}
function waveOutOpen(lphWaveOut: PHWaveOut; uDeviceID: UINT;
  lpFormat: PWaveFormatEx; dwCallback, dwInstance: DWORD_PTR; dwFlags: DWORD): MMRESULT; stdcall;
{$EXTERNALSYM waveOutClose}
function waveOutClose(hWaveOut: HWAVEOUT): MMRESULT; stdcall;
{$EXTERNALSYM waveOutPrepareHeader}
function waveOutPrepareHeader(hWaveOut: HWAVEOUT; lpWaveOutHdr: PWaveHdr;
  uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM waveOutUnprepareHeader}
function waveOutUnprepareHeader(hWaveOut: HWAVEOUT; lpWaveOutHdr: PWaveHdr;
  uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM waveOutWrite}
function waveOutWrite(hWaveOut: HWAVEOUT; lpWaveOutHdr: PWaveHdr;
  uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM waveOutPause}
function waveOutPause(hWaveOut: HWAVEOUT): MMRESULT; stdcall;
{$EXTERNALSYM waveOutRestart}
function waveOutRestart(hWaveOut: HWAVEOUT): MMRESULT; stdcall;
{$EXTERNALSYM waveOutReset}
function waveOutReset(hWaveOut: HWAVEOUT): MMRESULT; stdcall;
{$EXTERNALSYM waveOutBreakLoop}
function waveOutBreakLoop(hWaveOut: HWAVEOUT): MMRESULT; stdcall;
{$EXTERNALSYM waveOutGetPosition}
function waveOutGetPosition(hWaveOut: HWAVEOUT; lpInfo: PMMTime; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM waveOutGetPitch}
function waveOutGetPitch(hWaveOut: HWAVEOUT; lpdwPitch: PDWORD): MMRESULT; stdcall;
{$EXTERNALSYM waveOutSetPitch}
function waveOutSetPitch(hWaveOut: HWAVEOUT; dwPitch: DWORD): MMRESULT; stdcall;
{$EXTERNALSYM waveOutGetPlaybackRate}
function waveOutGetPlaybackRate(hWaveOut: HWAVEOUT; lpdwRate: PDWORD): MMRESULT; stdcall;
{$EXTERNALSYM waveOutSetPlaybackRate}
function waveOutSetPlaybackRate(hWaveOut: HWAVEOUT; dwRate: DWORD): MMRESULT; stdcall;
{$EXTERNALSYM waveOutGetID}
function waveOutGetID(hWaveOut: HWAVEOUT; lpuDeviceID: PUINT): MMRESULT; stdcall;
{$EXTERNALSYM waveOutMessage}
function waveOutMessage(hWaveOut: HWAVEOUT; uMessage: UINT; dw1, dw2: DWORD_PTR): Longint; stdcall;
{$EXTERNALSYM waveInGetNumDevs}
function waveInGetNumDevs: UINT; stdcall;
{$EXTERNALSYM waveInGetDevCaps}
function waveInGetDevCaps(hwo: HWAVEOUT; lpCaps: PWaveInCaps; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM waveInGetDevCapsA}
function waveInGetDevCapsA(hwo: HWAVEOUT; lpCaps: PWaveInCapsA; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM waveInGetDevCapsW}
function waveInGetDevCapsW(hwo: HWAVEOUT; lpCaps: PWaveInCapsW; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM waveInGetErrorText}
function waveInGetErrorText(mmrError: MMRESULT; lpText: LPWSTR; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM waveInGetErrorTextA}
function waveInGetErrorTextA(mmrError: MMRESULT; lpText: LPSTR; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM waveInGetErrorTextW}
function waveInGetErrorTextW(mmrError: MMRESULT; lpText: LPWSTR; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM waveInOpen}
function waveInOpen(lphWaveIn: PHWAVEIN; uDeviceID: UINT;
  lpFormatEx: PWaveFormatEx; dwCallback, dwInstance: DWORD_PTR; dwFlags: DWORD): MMRESULT; stdcall;
{$EXTERNALSYM waveInClose}
function waveInClose(hWaveIn: HWAVEIN): MMRESULT; stdcall;
{$EXTERNALSYM waveInPrepareHeader}
function waveInPrepareHeader(hWaveIn: HWAVEIN; lpWaveInHdr: PWaveHdr;
  uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM waveInUnprepareHeader}
function waveInUnprepareHeader(hWaveIn: HWAVEIN; lpWaveInHdr: PWaveHdr;
  uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM waveInAddBuffer}
function waveInAddBuffer(hWaveIn: HWAVEIN; lpWaveInHdr: PWaveHdr;
  uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM waveInStart}
function waveInStart(hWaveIn: HWAVEIN): MMRESULT; stdcall;
{$EXTERNALSYM waveInStop}
function waveInStop(hWaveIn: HWAVEIN): MMRESULT; stdcall;
{$EXTERNALSYM waveInReset}
function waveInReset(hWaveIn: HWAVEIN): MMRESULT; stdcall;
{$EXTERNALSYM waveInGetPosition}
function waveInGetPosition(hWaveIn: HWAVEIN; lpInfo: PMMTime;
  uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM waveInGetID}
function waveInGetID(hWaveIn: HWAVEIN; lpuDeviceID: PUINT): MMRESULT; stdcall;
{$EXTERNALSYM waveInMessage}
function waveInMessage(hWaveIn: HWAVEIN; uMessage: UINT;
  dw1, dw2: DWORD_PTR): MMRESULT; stdcall;

{***************************************************************************

                            MIDI audio support

***************************************************************************}

{ MIDI error return values }
const
  {$EXTERNALSYM MIDIERR_UNPREPARED}
  MIDIERR_UNPREPARED    = MIDIERR_BASE + 0;   { header not prepared }
  {$EXTERNALSYM MIDIERR_STILLPLAYING}
  MIDIERR_STILLPLAYING  = MIDIERR_BASE + 1;   { still something playing }
  {$EXTERNALSYM MIDIERR_NOMAP}
  MIDIERR_NOMAP         = MIDIERR_BASE + 2;   { no current map }
  {$EXTERNALSYM MIDIERR_NOTREADY}
  MIDIERR_NOTREADY      = MIDIERR_BASE + 3;   { hardware is still busy }
  {$EXTERNALSYM MIDIERR_NODEVICE}
  MIDIERR_NODEVICE      = MIDIERR_BASE + 4;   { port no longer connected }
  {$EXTERNALSYM MIDIERR_INVALIDSETUP}
  MIDIERR_INVALIDSETUP  = MIDIERR_BASE + 5;   { invalid setup }
  {$EXTERNALSYM MIDIERR_BADOPENMODE}
  MIDIERR_BADOPENMODE   = MIDIERR_BASE + 6;   { operation unsupported w/ open mode }
  {$EXTERNALSYM MIDIERR_DONT_CONTINUE}
  MIDIERR_DONT_CONTINUE = MIDIERR_BASE + 7;   { thru device 'eating' a message }
  {$EXTERNALSYM MIDIERR_LASTERROR}
  MIDIERR_LASTERROR     = MIDIERR_BASE + 7;   { last error in range }

{ MIDI audio data types }
type
  PHMIDI = ^HMIDI;
  {$EXTERNALSYM HMIDI}
  HMIDI = IntPtr;
  PHMIDIIN = ^HMIDIIN;
  {$EXTERNALSYM HMIDIIN}
  HMIDIIN = IntPtr;
  PHMIDIOUT = ^HMIDIOUT;
  {$EXTERNALSYM HMIDIOUT}
  HMIDIOUT = IntPtr;
  PHMIDISTRM = ^HMIDISTRM;
  {$EXTERNALSYM HMIDISTRM}
  HMIDISTRM = IntPtr;

type
  TFNMidiCallBack = TFNDrvCallBack;

const
  {$EXTERNALSYM MIDIPATCHSIZE}
  MIDIPATCHSIZE   = 128;

type
  PPatchArray = ^TPatchArray;
  TPatchArray = array[0..MIDIPATCHSIZE-1] of Word;

  PKeyArray = ^TKeyArray;
  TKeyArray = array[0..MIDIPATCHSIZE-1] of Word;


{ MIDI callback messages }
const
  {$EXTERNALSYM MIM_OPEN}
  MIM_OPEN        = MM_MIM_OPEN;
  {$EXTERNALSYM MIM_CLOSE}
  MIM_CLOSE       = MM_MIM_CLOSE;
  {$EXTERNALSYM MIM_DATA}
  MIM_DATA        = MM_MIM_DATA;
  {$EXTERNALSYM MIM_LONGDATA}
  MIM_LONGDATA    = MM_MIM_LONGDATA;
  {$EXTERNALSYM MIM_ERROR}
  MIM_ERROR       = MM_MIM_ERROR;
  {$EXTERNALSYM MIM_LONGERROR}
  MIM_LONGERROR   = MM_MIM_LONGERROR;
  {$EXTERNALSYM MOM_OPEN}
  MOM_OPEN        = MM_MOM_OPEN;
  {$EXTERNALSYM MOM_CLOSE}
  MOM_CLOSE       = MM_MOM_CLOSE;
  {$EXTERNALSYM MOM_DONE}
  MOM_DONE        = MM_MOM_DONE;

  {$EXTERNALSYM MIM_MOREDATA}
  MIM_MOREDATA    = MM_MIM_MOREDATA;
  {$EXTERNALSYM MOM_POSITIONCB}
  MOM_POSITIONCB  = MM_MOM_POSITIONCB;

{ device ID for MIDI mapper }
  {$EXTERNALSYM MIDIMAPPER}
  MIDIMAPPER     = UINT(-1);
  {$EXTERNALSYM MIDI_MAPPER}
  MIDI_MAPPER    = UINT(-1);

{ flags for dwFlags parm of midiInOpen() }
  {$EXTERNALSYM MIDI_IO_STATUS}
  MIDI_IO_STATUS = $00000020;

{ flags for wFlags parm of midiOutCachePatches(), midiOutCacheDrumPatches() }
  {$EXTERNALSYM MIDI_CACHE_ALL}
  MIDI_CACHE_ALL      = 1;
  {$EXTERNALSYM MIDI_CACHE_BESTFIT}
  MIDI_CACHE_BESTFIT  = 2;
  {$EXTERNALSYM MIDI_CACHE_QUERY}
  MIDI_CACHE_QUERY    = 3;
  {$EXTERNALSYM MIDI_UNCACHE}
  MIDI_UNCACHE        = 4;

{ MIDI output device capabilities structure }
type
  PMidiOutCapsA = ^TMidiOutCapsA;
  PMidiOutCapsW = ^TMidiOutCapsW;
  PMidiOutCaps = PMidiOutCapsW;
  {$EXTERNALSYM tagMIDIOUTCAPSA}
  tagMIDIOUTCAPSA = record
    wMid: Word;                  { manufacturer ID }
    wPid: Word;                  { product ID }
    vDriverVersion: MMVERSION;        { version of the driver }
    szPname: array[0..MAXPNAMELEN-1] of AnsiChar;  { product name (NULL terminated AnsiString) }
    wTechnology: Word;           { type of device }
    wVoices: Word;               { # of voices (internal synth only) }
    wNotes: Word;                { max # of notes (internal synth only) }
    wChannelMask: Word;          { channels used (internal synth only) }
    dwSupport: DWORD;            { functionality supported by driver }
  end;
  {$EXTERNALSYM tagMIDIOUTCAPSW}
  tagMIDIOUTCAPSW = record
    wMid: Word;                  { manufacturer ID }
    wPid: Word;                  { product ID }
    vDriverVersion: MMVERSION;        { version of the driver }
    szPname: array[0..MAXPNAMELEN-1] of WideChar;  { product name (NULL terminated UnicodeString) }
    wTechnology: Word;           { type of device }
    wVoices: Word;               { # of voices (internal synth only) }
    wNotes: Word;                { max # of notes (internal synth only) }
    wChannelMask: Word;          { channels used (internal synth only) }
    dwSupport: DWORD;            { functionality supported by driver }
  end;
  {$EXTERNALSYM tagMIDIOUTCAPS}
  tagMIDIOUTCAPS = tagMIDIOUTCAPSW;
  TMidiOutCapsA = tagMIDIOUTCAPSA;
  TMidiOutCapsW = tagMIDIOUTCAPSW;
  TMidiOutCaps = TMidiOutCapsW;
  {$EXTERNALSYM MIDIOUTCAPSA}
  MIDIOUTCAPSA = tagMIDIOUTCAPSA;
  {$EXTERNALSYM MIDIOUTCAPSW}
  MIDIOUTCAPSW = tagMIDIOUTCAPSW;
  {$EXTERNALSYM MIDIOUTCAPS}
  MIDIOUTCAPS = MIDIOUTCAPSW;


{ flags for wTechnology field of MIDIOUTCAPS structure }
const
  {$EXTERNALSYM MOD_MIDIPORT}
  MOD_MIDIPORT    = 1;  { output port }
  {$EXTERNALSYM MOD_SYNTH}
  MOD_SYNTH       = 2;  { generic internal synth }
  {$EXTERNALSYM MOD_SQSYNTH}
  MOD_SQSYNTH     = 3;  { square wave internal synth }
  {$EXTERNALSYM MOD_FMSYNTH}
  MOD_FMSYNTH     = 4;  { FM internal synth }
  {$EXTERNALSYM MOD_MAPPER}
  MOD_MAPPER      = 5;  { MIDI mapper }
  {$EXTERNALSYM MOD_WAVETABLE}
  MOD_WAVETABLE   = 6;  { hardware wavetable synth }
  {$EXTERNALSYM MOD_SWSYNTH}
  MOD_SWSYNTH     = 7;  { software synth }


{ flags for dwSupport field of MIDIOUTCAPS structure }
const
  {$EXTERNALSYM MIDICAPS_VOLUME}
  MIDICAPS_VOLUME          = $0001;  { supports volume control }
  {$EXTERNALSYM MIDICAPS_LRVOLUME}
  MIDICAPS_LRVOLUME        = $0002;  { separate left-right volume control }
  {$EXTERNALSYM MIDICAPS_CACHE}
  MIDICAPS_CACHE           = $0004;
  {$EXTERNALSYM MIDICAPS_STREAM}
  MIDICAPS_STREAM          = $0008;  { driver supports midiStreamOut directly }

{ MIDI output device capabilities structure }

type
  PMidiInCapsA = ^TMidiInCapsA;
  PMidiInCapsW = ^TMidiInCapsW;
  PMidiInCaps = PMidiInCapsW;
  {$EXTERNALSYM tagMIDIINCAPSA}
  tagMIDIINCAPSA = record
    wMid: Word;                  { manufacturer ID }
    wPid: Word;                  { product ID }
    vDriverVersion: MMVERSION;   { version of the driver }
    szPname: array[0..MAXPNAMELEN-1] of AnsiChar;  { product name (NULL terminated AnsiString) }
    dwSupport: DWORD;            { functionality supported by driver }
  end;
  {$EXTERNALSYM tagMIDIINCAPSW}
  tagMIDIINCAPSW = record
    wMid: Word;                  { manufacturer ID }
    wPid: Word;                  { product ID }
    vDriverVersion: MMVERSION;   { version of the driver }
    szPname: array[0..MAXPNAMELEN-1] of WideChar;  { product name (NULL terminated UnicodeString) }
    dwSupport: DWORD;            { functionality supported by driver }
  end;
  {$EXTERNALSYM tagMIDIINCAPS}
  tagMIDIINCAPS = tagMIDIINCAPSW;
  TMidiInCapsA = tagMIDIINCAPSA;
  TMidiInCapsW = tagMIDIINCAPSW;
  TMidiInCaps = TMidiInCapsW;
  {$EXTERNALSYM MIDIINCAPSA}
  MIDIINCAPSA = tagMIDIINCAPSA;
  {$EXTERNALSYM MIDIINCAPSW}
  MIDIINCAPSW = tagMIDIINCAPSW;
  {$EXTERNALSYM MIDIINCAPS}
  MIDIINCAPS = MIDIINCAPSW;

{ MIDI data block header }
type
  PMidiHdr = ^TMidiHdr;
  {$EXTERNALSYM midihdr_tag}
  midihdr_tag = record
    lpData: PAnsiChar;           { pointer to locked data block }
    dwBufferLength: DWORD;       { length of data in data block }
    dwBytesRecorded: DWORD;      { used for input only }
    dwUser: DWORD_PTR;           { for client's use }
    dwFlags: DWORD;              { assorted flags (see defines) }
    lpNext: PMidiHdr;            { reserved for driver }
    reserved: DWORD_PTR;         { reserved for driver }
    dwOffset: DWORD;             { Callback offset into buffer }
    dwReserved: array[0..7] of DWORD_PTR; { Reserved for MMSYSTEM }
  end;
  TMidiHdr = midihdr_tag;
  {$EXTERNALSYM MIDIHDR}
  MIDIHDR = midihdr_tag;

  PMidiEvent = ^TMidiEvent;
  {$EXTERNALSYM midievent_tag}
  midievent_tag = record
    dwDeltaTime: DWORD;          { Ticks since last event }
    dwStreamID: DWORD;           { Reserved; must be zero }
    dwEvent: DWORD;              { Event type and parameters }
    dwParms: array[0..0] of DWORD;  { Parameters if this is a long event }
  end;
  TMidiEvent = midievent_tag;
  {$EXTERNALSYM MIDIEVENT}
  MIDIEVENT = midievent_tag;

  PMidiStrmBuffVer = ^TMidiStrmBuffVer;
  {$EXTERNALSYM midistrmbuffver_tag}
  midistrmbuffver_tag = record
    dwVersion: DWORD;                  { Stream buffer format version }
    dwMid: DWORD;                      { Manufacturer ID as defined in MMREG.H }
    dwOEMVersion: DWORD;               { Manufacturer version for custom ext }
  end;
  TMidiStrmBuffVer = midistrmbuffver_tag;
  {$EXTERNALSYM MIDISTRMBUFFVER}
  MIDISTRMBUFFVER = midistrmbuffver_tag;

{ flags for dwFlags field of MIDIHDR structure }
const
  {$EXTERNALSYM MHDR_DONE}
  MHDR_DONE       = $00000001;                   
  {$EXTERNALSYM MHDR_PREPARED}
  MHDR_PREPARED   = $00000002;       { set if header prepared }
  {$EXTERNALSYM MHDR_INQUEUE}
  MHDR_INQUEUE    = $00000004;       { reserved for driver }
  {$EXTERNALSYM MHDR_ISSTRM}
  MHDR_ISSTRM     = $00000008;       { Buffer is stream buffer }

(* 
  Type codes which go in the high byte of the event DWORD of a stream buffer 
 
  Type codes 00-7F contain parameters within the low 24 bits 
  Type codes 80-FF contain a length of their parameter in the low 24 
  bits, followed by their parameter data in the buffer. The event 
  DWORD contains the exact byte length; the parm data itself must be 
  padded to be an even multiple of 4 bytes long. 
*) 

  {$EXTERNALSYM MEVT_F_SHORT}
  MEVT_F_SHORT       = $00000000;
  {$EXTERNALSYM MEVT_F_LONG}
  MEVT_F_LONG        = $80000000;
  {$EXTERNALSYM MEVT_F_CALLBACK}
  MEVT_F_CALLBACK    = $40000000;

  {$EXTERNALSYM MEVT_SHORTMSG}
  MEVT_SHORTMSG     = $00;    { parm = shortmsg for midiOutShortMsg }
  {$EXTERNALSYM MEVT_TEMPO}
  MEVT_TEMPO        = $01;    { parm = new tempo in microsec/qn     }
  {$EXTERNALSYM MEVT_NOP}
  MEVT_NOP          = $02;    { parm = unused; does nothing         }

{ 0x04-0x7F reserved }

  {$EXTERNALSYM MEVT_LONGMSG}
  MEVT_LONGMSG      = $80;    { parm = bytes to send verbatim       }
  {$EXTERNALSYM MEVT_COMMENT}
  MEVT_COMMENT      = $82;    { parm = comment data                 }
  {$EXTERNALSYM MEVT_VERSION}
  MEVT_VERSION      = $84;    { parm = MIDISTRMBUFFVER struct       }

{ 0x81-0xFF reserved }

  {$EXTERNALSYM MIDISTRM_ERROR}
  MIDISTRM_ERROR    =  -2;

{ Structures and defines for midiStreamProperty }
  {$EXTERNALSYM MIDIPROP_SET}
  MIDIPROP_SET       = $80000000;
  {$EXTERNALSYM MIDIPROP_GET}
  MIDIPROP_GET       = $40000000;

{ These are intentionally both non-zero so the app cannot accidentally
  leave the operation off and happen to appear to work due to default
  action. }
  {$EXTERNALSYM MIDIPROP_TIMEDIV}
  MIDIPROP_TIMEDIV   = $00000001;
  {$EXTERNALSYM MIDIPROP_TEMPO}
  MIDIPROP_TEMPO     = $00000002;

type
  PMidiPropTimeDiv = ^TMidiPropTimeDiv;
  {$EXTERNALSYM midiproptimediv_tag}
  midiproptimediv_tag = record
    cbStruct: DWORD;
    dwTimeDiv: DWORD;
  end;
  TMidiPropTimeDiv = midiproptimediv_tag;
  {$EXTERNALSYM MIDIPROPTIMEDIV}
  MIDIPROPTIMEDIV = midiproptimediv_tag;

  PMidiPropTempo = ^TMidiPropTempo;
  {$EXTERNALSYM midiproptempo_tag}
  midiproptempo_tag = record
    cbStruct: DWORD;
    dwTempo: DWORD;
  end;
  TMidiPropTempo = midiproptempo_tag;
  {$EXTERNALSYM MIDIPROPTEMPO}
  MIDIPROPTEMPO = midiproptempo_tag;

{ MIDI function prototypes }

{$EXTERNALSYM midiOutGetNumDevs}
function midiOutGetNumDevs: UINT; stdcall;
{$EXTERNALSYM midiStreamOpen}
function midiStreamOpen(phms: PHMIDISTRM; puDeviceID: PUINT; 
  cMidi: DWORD; dwCallback, dwInstance: DWORD_PTR; fdwOpen: DWORD): MMRESULT; stdcall;
{$EXTERNALSYM midiStreamClose}
function midiStreamClose(hms: HMIDISTRM): MMRESULT; stdcall;
{$EXTERNALSYM midiStreamProperty}
function midiStreamProperty(hms: HMIDISTRM; lppropdata: PBYTE; dwProperty: DWORD): MMRESULT; stdcall;
{$EXTERNALSYM midiStreamPosition}
function midiStreamPosition(hms: HMIDISTRM; lpmmt: PMMTime; cbmmt: UINT): MMRESULT; stdcall;
{$EXTERNALSYM midiStreamOut}
function midiStreamOut(hms: HMIDISTRM; pmh: PMidiHdr; cbmh: UINT): MMRESULT; stdcall;
{$EXTERNALSYM midiStreamPause}
function midiStreamPause(hms: HMIDISTRM): MMRESULT; stdcall;
{$EXTERNALSYM midiStreamRestart}
function midiStreamRestart(hms: HMIDISTRM): MMRESULT; stdcall;
{$EXTERNALSYM midiStreamStop}
function midiStreamStop(hms: HMIDISTRM): MMRESULT; stdcall;
{$EXTERNALSYM midiConnect}
function midiConnect(hmi: HMIDI; hmo: HMIDIOUT; pReserved: Pointer): MMRESULT; stdcall;
{$EXTERNALSYM midiDisconnect}
function midiDisconnect(hmi: HMIDI; hmo: HMIDIOUT; pReserved: Pointer): MMRESULT; stdcall;
{$EXTERNALSYM midiOutGetDevCaps}
function midiOutGetDevCaps(uDeviceID: UIntPtr; lpCaps: PMidiOutCaps; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM midiOutGetDevCapsA}
function midiOutGetDevCapsA(uDeviceID: UIntPtr; lpCaps: PMidiOutCapsA; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM midiOutGetDevCapsW}
function midiOutGetDevCapsW(uDeviceID: UIntPtr; lpCaps: PMidiOutCapsW; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM midiOutGetVolume}
function midiOutGetVolume(hmo: HMIDIOUT; lpdwVolume: PDWORD): MMRESULT; stdcall;
{$EXTERNALSYM midiOutSetVolume}
function midiOutSetVolume(hmo: HMIDIOUT; dwVolume: DWORD): MMRESULT; stdcall;
{$EXTERNALSYM midiOutGetErrorText}
function midiOutGetErrorText(mmrError: MMRESULT; pszText: LPWSTR; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM midiOutGetErrorTextA}
function midiOutGetErrorTextA(mmrError: MMRESULT; pszText: LPSTR; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM midiOutGetErrorTextW}
function midiOutGetErrorTextW(mmrError: MMRESULT; pszText: LPWSTR; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM midiOutOpen}
function midiOutOpen(lphMidiOut: PHMIDIOUT; uDeviceID: UINT;
  dwCallback, dwInstance: DWORD_PTR; dwFlags: DWORD): MMRESULT; stdcall;
{$EXTERNALSYM midiOutClose}
function midiOutClose(hMidiOut: HMIDIOUT): MMRESULT; stdcall;
{$EXTERNALSYM midiOutPrepareHeader}
function midiOutPrepareHeader(hMidiOut: HMIDIOUT; lpMidiOutHdr: PMidiHdr; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM midiOutUnprepareHeader}
function midiOutUnprepareHeader(hMidiOut: HMIDIOUT; lpMidiOutHdr: PMidiHdr; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM midiOutShortMsg}
function midiOutShortMsg(hMidiOut: HMIDIOUT; dwMsg: DWORD): MMRESULT; stdcall;
{$EXTERNALSYM midiOutLongMsg}
function midiOutLongMsg(hMidiOut: HMIDIOUT; lpMidiOutHdr: PMidiHdr; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM midiOutReset}
function midiOutReset(hMidiOut: HMIDIOUT): MMRESULT; stdcall;
{$EXTERNALSYM midiOutCachePatches}
function midiOutCachePatches(hMidiOut: HMIDIOUT;
  uBank: UINT; lpwPatchArray: PWord; uFlags: UINT): MMRESULT; stdcall;
{$EXTERNALSYM midiOutCacheDrumPatches}
function midiOutCacheDrumPatches(hMidiOut: HMIDIOUT;
  uPatch: UINT; lpwKeyArray: PWord; uFlags: UINT): MMRESULT; stdcall;
{$EXTERNALSYM midiOutGetID}
function midiOutGetID(hMidiOut: HMIDIOUT; lpuDeviceID: PUINT): MMRESULT; stdcall;
{$EXTERNALSYM midiOutMessage}
function midiOutMessage(hMidiOut: HMIDIOUT; uMessage: UINT; dw1, dw2: DWORD_PTR): MMRESULT; stdcall;
{$EXTERNALSYM midiInGetNumDevs}
function midiInGetNumDevs: UINT; stdcall;
{$EXTERNALSYM midiInGetDevCaps}
function midiInGetDevCaps(DeviceID: UIntPtr; lpCaps: PMidiInCaps; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM midiInGetDevCapsA}
function midiInGetDevCapsA(DeviceID: UIntPtr; lpCaps: PMidiInCapsA; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM midiInGetDevCapsW}
function midiInGetDevCapsW(DeviceID: UIntPtr; lpCaps: PMidiInCapsW; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM midiInGetErrorText}
function midiInGetErrorText(mmrError: MMRESULT; pszText: LPWSTR; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM midiInGetErrorTextA}
function midiInGetErrorTextA(mmrError: MMRESULT; pszText: LPSTR; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM midiInGetErrorTextW}
function midiInGetErrorTextW(mmrError: MMRESULT; pszText: LPWSTR; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM midiInOpen}
function midiInOpen(lphMidiIn: PHMIDIIN; uDeviceID: UINT;
  dwCallback, dwInstance: DWORD_PTR; dwFlags: DWORD): MMRESULT; stdcall;
{$EXTERNALSYM midiInClose}
function midiInClose(hMidiIn: HMIDIIN): MMRESULT; stdcall;
{$EXTERNALSYM midiInPrepareHeader}
function midiInPrepareHeader(hMidiIn: HMIDIIN; lpMidiInHdr: PMidiHdr; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM midiInUnprepareHeader}
function midiInUnprepareHeader(hMidiIn: HMIDIIN; lpMidiInHdr: PMidiHdr; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM midiInAddBuffer}
function midiInAddBuffer(hMidiIn: HMIDIIN; lpMidiInHdr: PMidiHdr; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM midiInStart}
function midiInStart(hMidiIn: HMIDIIN): MMRESULT; stdcall;
{$EXTERNALSYM midiInStop}
function midiInStop(hMidiIn: HMIDIIN): MMRESULT; stdcall;
{$EXTERNALSYM midiInReset}
function midiInReset(hMidiIn: HMIDIIN): MMRESULT; stdcall;
{$EXTERNALSYM midiInGetID}
function midiInGetID(hMidiIn: HMIDIIN; lpuDeviceID: PUINT): MMRESULT; stdcall;
{$EXTERNALSYM midiInMessage}
function midiInMessage(hMidiIn: HMIDIIN; uMessage: UINT; dw1, dw2: DWORD_PTR): MMRESULT; stdcall;


{***************************************************************************

                        Auxiliary audio support

***************************************************************************}

{ device ID for aux device mapper }
const
  {$EXTERNALSYM AUX_MAPPER}
  AUX_MAPPER     = UINT(-1);

{ Auxiliary audio device capabilities structure }
type
  PAuxCapsA = ^TAuxCapsA;
  PAuxCapsW = ^TAuxCapsW;
  PAuxCaps = PAuxCapsW;
  {$EXTERNALSYM tagAUXCAPSA}
  tagAUXCAPSA = record
    wMid: WORD;                  { manufacturer ID }
    wPid: WORD;                  { product ID }
    vDriverVersion: MMVERSION;        { version of the driver }
    szPname: array[0..MAXPNAMELEN-1] of AnsiChar;  { product name (NULL terminated AnsiString) }
    wTechnology: WORD;           { type of device }
    wReserved1: WORD;            { padding }
    dwSupport: DWORD;            { functionality supported by driver }
  end;
  {$EXTERNALSYM tagAUXCAPSW}
  tagAUXCAPSW = record
    wMid: WORD;                  { manufacturer ID }
    wPid: WORD;                  { product ID }
    vDriverVersion: MMVERSION;        { version of the driver }
    szPname: array[0..MAXPNAMELEN-1] of WideChar;  { product name (NULL terminated UnicodeString) }
    wTechnology: WORD;           { type of device }
    wReserved1: WORD;            { padding }
    dwSupport: DWORD;            { functionality supported by driver }
  end;
  {$EXTERNALSYM tagAUXCAPS}
  tagAUXCAPS = tagAUXCAPSW;
  TAuxCapsA = tagAUXCAPSA;
  TAuxCapsW = tagAUXCAPSW;
  TAuxCaps = TAuxCapsW;
  {$EXTERNALSYM AUXCAPSA}
  AUXCAPSA = tagAUXCAPSA;
  {$EXTERNALSYM AUXCAPSW}
  AUXCAPSW = tagAUXCAPSW;
  {$EXTERNALSYM AUXCAPS}
  AUXCAPS = AUXCAPSW;

{ flags for wTechnology field in AUXCAPS structure }
const
  {$EXTERNALSYM AUXCAPS_CDAUDIO}
  AUXCAPS_CDAUDIO    = 1;       { audio from internal CD-ROM drive }
  {$EXTERNALSYM AUXCAPS_AUXIN}
  AUXCAPS_AUXIN      = 2;       { audio from auxiliary input jacks }

{ flags for dwSupport field in AUXCAPS structure }
const
  {$EXTERNALSYM AUXCAPS_VOLUME}
  AUXCAPS_VOLUME     = $0001;  { supports volume control }
  {$EXTERNALSYM AUXCAPS_LRVOLUME}
  AUXCAPS_LRVOLUME   = $0002;  { separate left-right volume control }

{ auxiliary audio function prototypes }
{$EXTERNALSYM auxGetNumDevs}
function auxGetNumDevs: UINT; stdcall;
{$EXTERNALSYM auxGetDevCaps}
function auxGetDevCaps(uDeviceID: UIntPtr; lpCaps: PAuxCaps; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM auxGetDevCapsA}
function auxGetDevCapsA(uDeviceID: UIntPtr; lpCaps: PAuxCapsA; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM auxGetDevCapsW}
function auxGetDevCapsW(uDeviceID: UIntPtr; lpCaps: PAuxCapsW; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM auxSetVolume}
function auxSetVolume(uDeviceID: UINT; dwVolume: DWORD): MMRESULT; stdcall;
{$EXTERNALSYM auxGetVolume}
function auxGetVolume(uDeviceID: UINT; lpdwVolume: PDWORD): MMRESULT; stdcall;
{$EXTERNALSYM auxOutMessage}
function auxOutMessage(uDeviceID, uMessage: UINT; dw1, dw2: DWORD_PTR): MMRESULT; stdcall;


{****************************************************************************

			    Mixer Support

****************************************************************************}

type
  PHMIXEROBJ = ^HMIXEROBJ;
  {$EXTERNALSYM HMIXEROBJ}
  HMIXEROBJ = IntPtr;

  PHMIXER = ^HMIXER;
  {$EXTERNALSYM HMIXER}
  HMIXER = IntPtr;

const
  {$EXTERNALSYM MIXER_SHORT_NAME_CHARS}
  MIXER_SHORT_NAME_CHARS   = 16;
  {$EXTERNALSYM MIXER_LONG_NAME_CHARS}
  MIXER_LONG_NAME_CHARS    = 64;

{ MMRESULT error return values specific to the mixer API }

  {$EXTERNALSYM MIXERR_INVALLINE}
  MIXERR_INVALLINE            = (MIXERR_BASE + 0);
  {$EXTERNALSYM MIXERR_INVALCONTROL}
  MIXERR_INVALCONTROL         = (MIXERR_BASE + 1);
  {$EXTERNALSYM MIXERR_INVALVALUE}
  MIXERR_INVALVALUE           = (MIXERR_BASE + 2);
  {$EXTERNALSYM MIXERR_LASTERROR}
  MIXERR_LASTERROR            = (MIXERR_BASE + 2);

  {$EXTERNALSYM MIXER_OBJECTF_HANDLE}
  MIXER_OBJECTF_HANDLE    = $80000000;
  {$EXTERNALSYM MIXER_OBJECTF_MIXER}
  MIXER_OBJECTF_MIXER     = $00000000;
  {$EXTERNALSYM MIXER_OBJECTF_HMIXER}
  MIXER_OBJECTF_HMIXER    = (MIXER_OBJECTF_HANDLE or MIXER_OBJECTF_MIXER);
  {$EXTERNALSYM MIXER_OBJECTF_WAVEOUT}
  MIXER_OBJECTF_WAVEOUT   = $10000000;
  {$EXTERNALSYM MIXER_OBJECTF_HWAVEOUT}
  MIXER_OBJECTF_HWAVEOUT  = (MIXER_OBJECTF_HANDLE or MIXER_OBJECTF_WAVEOUT);
  {$EXTERNALSYM MIXER_OBJECTF_WAVEIN}
  MIXER_OBJECTF_WAVEIN    = $20000000;
  {$EXTERNALSYM MIXER_OBJECTF_HWAVEIN}
  MIXER_OBJECTF_HWAVEIN   = (MIXER_OBJECTF_HANDLE or MIXER_OBJECTF_WAVEIN);
  {$EXTERNALSYM MIXER_OBJECTF_MIDIOUT}
  MIXER_OBJECTF_MIDIOUT   = $30000000;
  {$EXTERNALSYM MIXER_OBJECTF_HMIDIOUT}
  MIXER_OBJECTF_HMIDIOUT  = (MIXER_OBJECTF_HANDLE or MIXER_OBJECTF_MIDIOUT);
  {$EXTERNALSYM MIXER_OBJECTF_MIDIIN}
  MIXER_OBJECTF_MIDIIN    = $40000000;
  {$EXTERNALSYM MIXER_OBJECTF_HMIDIIN}
  MIXER_OBJECTF_HMIDIIN   = (MIXER_OBJECTF_HANDLE or MIXER_OBJECTF_MIDIIN);
  {$EXTERNALSYM MIXER_OBJECTF_AUX}
  MIXER_OBJECTF_AUX       = $50000000;

{$EXTERNALSYM mixerGetNumDevs}
function mixerGetNumDevs: UINT; stdcall;

type
  PMixerCapsA = ^TMixerCapsA;
  PMixerCapsW = ^TMixerCapsW;
  PMixerCaps = PMixerCapsW;
  {$EXTERNALSYM tagMIXERCAPSA}
  tagMIXERCAPSA = record
    wMid: WORD;                    { manufacturer id }
    wPid: WORD;                    { product id }
    vDriverVersion: MMVERSION;     { version of the driver }
    szPname: array [0..MAXPNAMELEN - 1] of AnsiChar;   { product name }
    fdwSupport: DWORD;             { misc. support bits }
    cDestinations: DWORD;          { count of destinations }
  end;
  {$EXTERNALSYM tagMIXERCAPSW}
  tagMIXERCAPSW = record
    wMid: WORD;                    { manufacturer id }
    wPid: WORD;                    { product id }
    vDriverVersion: MMVERSION;     { version of the driver }
    szPname: array [0..MAXPNAMELEN - 1] of WideChar;   { product name }
    fdwSupport: DWORD;             { misc. support bits }
    cDestinations: DWORD;          { count of destinations }
  end;
  {$EXTERNALSYM tagMIXERCAPS}
  tagMIXERCAPS = tagMIXERCAPSW;
  TMixerCapsA = tagMIXERCAPSA;
  TMixerCapsW = tagMIXERCAPSW;
  TMixerCaps = TMixerCapsW;
  {$EXTERNALSYM MIXERCAPSA}
  MIXERCAPSA = tagMIXERCAPSA;
  {$EXTERNALSYM MIXERCAPSW}
  MIXERCAPSW = tagMIXERCAPSW;
  {$EXTERNALSYM MIXERCAPS}
  MIXERCAPS = MIXERCAPSW;

function mixerGetDevCaps(uMxId: UIntPtr; pmxcaps: PMixerCaps; cbmxcaps: UINT): MMRESULT; stdcall;
{$EXTERNALSYM mixerGetDevCaps}
function mixerGetDevCapsA(uMxId: UIntPtr; pmxcaps: PMixerCapsA; cbmxcaps: UINT): MMRESULT; stdcall;
{$EXTERNALSYM mixerGetDevCapsA}
function mixerGetDevCapsW(uMxId: UIntPtr; pmxcaps: PMixerCapsW; cbmxcaps: UINT): MMRESULT; stdcall;
{$EXTERNALSYM mixerGetDevCapsW}
function mixerOpen(phmx: PHMIXER; uMxId: UINT; dwCallback, dwInstance: DWORD_PTR;
  fdwOpen: DWORD): MMRESULT; stdcall;
{$EXTERNALSYM mixerOpen}
function mixerClose(hmx: HMIXER): MMRESULT; stdcall;
{$EXTERNALSYM mixerClose}
function mixerMessage(hmx: HMIXER; uMsg: UINT; dwParam1, dwParam2: DWORD_PTR): DWORD; stdcall;
{$EXTERNALSYM mixerMessage}

type
  PMixerLineA = ^TMixerLineA;
  PMixerLineW = ^TMixerLineW;
  PMixerLine = PMixerLineW;
  {$EXTERNALSYM tagMIXERLINEA}
  tagMIXERLINEA = record
    cbStruct: DWORD;               { size of MIXERLINE structure }
    dwDestination: DWORD;          { zero based destination index }
    dwSource: DWORD;               { zero based source index (if source) }
    dwLineID: DWORD;               { unique line id for mixer device }
    fdwLine: DWORD;                { state/information about line }
    dwUser: DWORD_PTR;             { driver specific information }
    dwComponentType: DWORD;        { component type line connects to }
    cChannels: DWORD;              { number of channels line supports }
    cConnections: DWORD;           { number of connections [possible] }
    cControls: DWORD;              { number of controls at this line }
    szShortName: array[0..MIXER_SHORT_NAME_CHARS - 1] of AnsiChar;
    szName: array[0..MIXER_LONG_NAME_CHARS - 1] of AnsiChar;
    Target: record
      dwType: DWORD;                 { MIXERLINE_TARGETTYPE_xxxx }
      dwDeviceID: DWORD;             { target device ID of device type }
      wMid: WORD;                                   { of target device }
      wPid: WORD;                                   {      " }
      vDriverVersion: MMVERSION;                    {      " }
      szPname: array[0..MAXPNAMELEN - 1] of AnsiChar;  {      " }
	 end;
  end;
  {$EXTERNALSYM tagMIXERLINEW}
  tagMIXERLINEW = record
    cbStruct: DWORD;               { size of MIXERLINE structure }
    dwDestination: DWORD;          { zero based destination index }
    dwSource: DWORD;               { zero based source index (if source) }
    dwLineID: DWORD;               { unique line id for mixer device }
    fdwLine: DWORD;                { state/information about line }
    dwUser: DWORD_PTR;             { driver specific information }
    dwComponentType: DWORD;        { component type line connects to }
    cChannels: DWORD;              { number of channels line supports }
    cConnections: DWORD;           { number of connections [possible] }
    cControls: DWORD;              { number of controls at this line }
    szShortName: array[0..MIXER_SHORT_NAME_CHARS - 1] of WideChar;
    szName: array[0..MIXER_LONG_NAME_CHARS - 1] of WideChar;
    Target: record
      dwType: DWORD;                 { MIXERLINE_TARGETTYPE_xxxx }
      dwDeviceID: DWORD;             { target device ID of device type }
      wMid: WORD;                                   { of target device }
      wPid: WORD;                                   {      " }
      vDriverVersion: MMVERSION;                    {      " }
      szPname: array[0..MAXPNAMELEN - 1] of WideChar;  {      " }
	 end;
  end;
  {$EXTERNALSYM tagMIXERLINE}
  tagMIXERLINE = tagMIXERLINEW;
  TMixerLineA = tagMIXERLINEA;
  TMixerLineW = tagMIXERLINEW;
  TMixerLine = TMixerLineW;
  {$EXTERNALSYM MIXERLINEA}
  MIXERLINEA = tagMIXERLINEA;
  {$EXTERNALSYM MIXERLINEW}
  MIXERLINEW = tagMIXERLINEW;
  {$EXTERNALSYM MIXERLINE}
  MIXERLINE = MIXERLINEW;

const
{ TMixerLine.fdwLine }

  {$EXTERNALSYM MIXERLINE_LINEF_ACTIVE}
  MIXERLINE_LINEF_ACTIVE              = $00000001;
  {$EXTERNALSYM MIXERLINE_LINEF_DISCONNECTED}
  MIXERLINE_LINEF_DISCONNECTED        = $00008000;
  {$EXTERNALSYM MIXERLINE_LINEF_SOURCE}
  MIXERLINE_LINEF_SOURCE              = $80000000;

{ TMixerLine.dwComponentType
  component types for destinations and sources }

  {$EXTERNALSYM MIXERLINE_COMPONENTTYPE_DST_FIRST}
  MIXERLINE_COMPONENTTYPE_DST_FIRST       = $00000000;
  {$EXTERNALSYM MIXERLINE_COMPONENTTYPE_DST_UNDEFINED}
  MIXERLINE_COMPONENTTYPE_DST_UNDEFINED   = (MIXERLINE_COMPONENTTYPE_DST_FIRST + 0);
  {$EXTERNALSYM MIXERLINE_COMPONENTTYPE_DST_DIGITAL}
  MIXERLINE_COMPONENTTYPE_DST_DIGITAL     = (MIXERLINE_COMPONENTTYPE_DST_FIRST + 1);
  {$EXTERNALSYM MIXERLINE_COMPONENTTYPE_DST_LINE}
  MIXERLINE_COMPONENTTYPE_DST_LINE        = (MIXERLINE_COMPONENTTYPE_DST_FIRST + 2);
  {$EXTERNALSYM MIXERLINE_COMPONENTTYPE_DST_MONITOR}
  MIXERLINE_COMPONENTTYPE_DST_MONITOR     = (MIXERLINE_COMPONENTTYPE_DST_FIRST + 3);
  {$EXTERNALSYM MIXERLINE_COMPONENTTYPE_DST_SPEAKERS}
  MIXERLINE_COMPONENTTYPE_DST_SPEAKERS    = (MIXERLINE_COMPONENTTYPE_DST_FIRST + 4);
  {$EXTERNALSYM MIXERLINE_COMPONENTTYPE_DST_HEADPHONES}
  MIXERLINE_COMPONENTTYPE_DST_HEADPHONES  = (MIXERLINE_COMPONENTTYPE_DST_FIRST + 5);
  {$EXTERNALSYM MIXERLINE_COMPONENTTYPE_DST_TELEPHONE}
  MIXERLINE_COMPONENTTYPE_DST_TELEPHONE   = (MIXERLINE_COMPONENTTYPE_DST_FIRST + 6);
  {$EXTERNALSYM MIXERLINE_COMPONENTTYPE_DST_WAVEIN}
  MIXERLINE_COMPONENTTYPE_DST_WAVEIN      = (MIXERLINE_COMPONENTTYPE_DST_FIRST + 7);
  {$EXTERNALSYM MIXERLINE_COMPONENTTYPE_DST_VOICEIN}
  MIXERLINE_COMPONENTTYPE_DST_VOICEIN     = (MIXERLINE_COMPONENTTYPE_DST_FIRST + 8);
  {$EXTERNALSYM MIXERLINE_COMPONENTTYPE_DST_LAST}
  MIXERLINE_COMPONENTTYPE_DST_LAST        = (MIXERLINE_COMPONENTTYPE_DST_FIRST + 8);

  {$EXTERNALSYM MIXERLINE_COMPONENTTYPE_SRC_FIRST}
  MIXERLINE_COMPONENTTYPE_SRC_FIRST       = $00001000;
  {$EXTERNALSYM MIXERLINE_COMPONENTTYPE_SRC_UNDEFINED}
  MIXERLINE_COMPONENTTYPE_SRC_UNDEFINED   = (MIXERLINE_COMPONENTTYPE_SRC_FIRST + 0);
  {$EXTERNALSYM MIXERLINE_COMPONENTTYPE_SRC_DIGITAL}
  MIXERLINE_COMPONENTTYPE_SRC_DIGITAL     = (MIXERLINE_COMPONENTTYPE_SRC_FIRST + 1);
  {$EXTERNALSYM MIXERLINE_COMPONENTTYPE_SRC_LINE}
  MIXERLINE_COMPONENTTYPE_SRC_LINE        = (MIXERLINE_COMPONENTTYPE_SRC_FIRST + 2);
  {$EXTERNALSYM MIXERLINE_COMPONENTTYPE_SRC_MICROPHONE}
  MIXERLINE_COMPONENTTYPE_SRC_MICROPHONE  = (MIXERLINE_COMPONENTTYPE_SRC_FIRST + 3);
  {$EXTERNALSYM MIXERLINE_COMPONENTTYPE_SRC_SYNTHESIZER}
  MIXERLINE_COMPONENTTYPE_SRC_SYNTHESIZER = (MIXERLINE_COMPONENTTYPE_SRC_FIRST + 4);
  {$EXTERNALSYM MIXERLINE_COMPONENTTYPE_SRC_COMPACTDISC}
  MIXERLINE_COMPONENTTYPE_SRC_COMPACTDISC = (MIXERLINE_COMPONENTTYPE_SRC_FIRST + 5);
  {$EXTERNALSYM MIXERLINE_COMPONENTTYPE_SRC_TELEPHONE}
  MIXERLINE_COMPONENTTYPE_SRC_TELEPHONE   = (MIXERLINE_COMPONENTTYPE_SRC_FIRST + 6);
  {$EXTERNALSYM MIXERLINE_COMPONENTTYPE_SRC_PCSPEAKER}
  MIXERLINE_COMPONENTTYPE_SRC_PCSPEAKER   = (MIXERLINE_COMPONENTTYPE_SRC_FIRST + 7);
  {$EXTERNALSYM MIXERLINE_COMPONENTTYPE_SRC_WAVEOUT}
  MIXERLINE_COMPONENTTYPE_SRC_WAVEOUT     = (MIXERLINE_COMPONENTTYPE_SRC_FIRST + 8);
  {$EXTERNALSYM MIXERLINE_COMPONENTTYPE_SRC_AUXILIARY}
  MIXERLINE_COMPONENTTYPE_SRC_AUXILIARY   = (MIXERLINE_COMPONENTTYPE_SRC_FIRST + 9);
  {$EXTERNALSYM MIXERLINE_COMPONENTTYPE_SRC_ANALOG}
  MIXERLINE_COMPONENTTYPE_SRC_ANALOG      = (MIXERLINE_COMPONENTTYPE_SRC_FIRST + 10);
  {$EXTERNALSYM MIXERLINE_COMPONENTTYPE_SRC_LAST}
  MIXERLINE_COMPONENTTYPE_SRC_LAST        = (MIXERLINE_COMPONENTTYPE_SRC_FIRST + 10);

{ TMixerLine.Target.dwType }

  {$EXTERNALSYM MIXERLINE_TARGETTYPE_UNDEFINED}
  MIXERLINE_TARGETTYPE_UNDEFINED      = 0;
  {$EXTERNALSYM MIXERLINE_TARGETTYPE_WAVEOUT}
  MIXERLINE_TARGETTYPE_WAVEOUT        = 1;
  {$EXTERNALSYM MIXERLINE_TARGETTYPE_WAVEIN}
  MIXERLINE_TARGETTYPE_WAVEIN         = 2;
  {$EXTERNALSYM MIXERLINE_TARGETTYPE_MIDIOUT}
  MIXERLINE_TARGETTYPE_MIDIOUT        = 3;
  {$EXTERNALSYM MIXERLINE_TARGETTYPE_MIDIIN}
  MIXERLINE_TARGETTYPE_MIDIIN         = 4;
  {$EXTERNALSYM MIXERLINE_TARGETTYPE_AUX}
  MIXERLINE_TARGETTYPE_AUX            = 5;

{$EXTERNALSYM mixerGetLineInfo}
function mixerGetLineInfo(hmxobj: HMIXEROBJ; pmxl: PMixerLine; 
  fdwInfo: DWORD): MMRESULT; stdcall;
{$EXTERNALSYM mixerGetLineInfoA}
function mixerGetLineInfoA(hmxobj: HMIXEROBJ; pmxl: PMixerLineA; 
  fdwInfo: DWORD): MMRESULT; stdcall;
{$EXTERNALSYM mixerGetLineInfoW}
function mixerGetLineInfoW(hmxobj: HMIXEROBJ; pmxl: PMixerLineW; 
  fdwInfo: DWORD): MMRESULT; stdcall;

const
  {$EXTERNALSYM MIXER_GETLINEINFOF_DESTINATION}
  MIXER_GETLINEINFOF_DESTINATION      = $00000000;
  {$EXTERNALSYM MIXER_GETLINEINFOF_SOURCE}
  MIXER_GETLINEINFOF_SOURCE           = $00000001;
  {$EXTERNALSYM MIXER_GETLINEINFOF_LINEID}
  MIXER_GETLINEINFOF_LINEID           = $00000002;
  {$EXTERNALSYM MIXER_GETLINEINFOF_COMPONENTTYPE}
  MIXER_GETLINEINFOF_COMPONENTTYPE    = $00000003;
  {$EXTERNALSYM MIXER_GETLINEINFOF_TARGETTYPE}
  MIXER_GETLINEINFOF_TARGETTYPE       = $00000004;

  {$EXTERNALSYM MIXER_GETLINEINFOF_QUERYMASK}
  MIXER_GETLINEINFOF_QUERYMASK        = $0000000F;

{$EXTERNALSYM mixerGetID}
function mixerGetID(hmxobj: HMIXEROBJ; var puMxId: UINT; fdwId: DWORD): MMRESULT; stdcall;

type
  PMixerControlA = ^TMixerControlA;
  PMixerControlW = ^TMixerControlW;
  PMixerControl = PMixerControlW;
  {$EXTERNALSYM tagMIXERCONTROLA}
  tagMIXERCONTROLA = record
    cbStruct: DWORD;           { size in bytes of MIXERCONTROL }
    dwControlID: DWORD;        { unique control id for mixer device }
    dwControlType: DWORD;      { MIXERCONTROL_CONTROLTYPE_xxx }
    fdwControl: DWORD;         { MIXERCONTROL_CONTROLF_xxx }
    cMultipleItems: DWORD;     { if MIXERCONTROL_CONTROLF_MULTIPLE set }
    szShortName: array[0..MIXER_SHORT_NAME_CHARS - 1] of AnsiChar;
    szName: array[0..MIXER_LONG_NAME_CHARS - 1] of AnsiChar;
    Bounds: record
      case Integer of
        0: (lMinimum, lMaximum: Longint);
        1: (dwMinimum, dwMaximum: DWORD);
        2: (dwReserved: array[0..5] of DWORD);
    end;
    Metrics: record
      case Integer of
        0: (cSteps: DWORD);        { # of steps between min & max }
        1: (cbCustomData: DWORD);  { size in bytes of custom data }
        2: (dwReserved: array[0..5] of DWORD);
    end;
  end;  
  {$EXTERNALSYM tagMIXERCONTROLW}
  tagMIXERCONTROLW = record
    cbStruct: DWORD;           { size in bytes of MIXERCONTROL }
    dwControlID: DWORD;        { unique control id for mixer device }
    dwControlType: DWORD;      { MIXERCONTROL_CONTROLTYPE_xxx }
    fdwControl: DWORD;         { MIXERCONTROL_CONTROLF_xxx }
    cMultipleItems: DWORD;     { if MIXERCONTROL_CONTROLF_MULTIPLE set }
    szShortName: array[0..MIXER_SHORT_NAME_CHARS - 1] of WideChar;
    szName: array[0..MIXER_LONG_NAME_CHARS - 1] of WideChar;
    Bounds: record
      case Integer of
        0: (lMinimum, lMaximum: Longint);
        1: (dwMinimum, dwMaximum: DWORD);
        2: (dwReserved: array[0..5] of DWORD);
    end;
    Metrics: record
      case Integer of
        0: (cSteps: DWORD);        { # of steps between min & max }
        1: (cbCustomData: DWORD);  { size in bytes of custom data }
        2: (dwReserved: array[0..5] of DWORD);
    end;
  end;  
  {$EXTERNALSYM tagMIXERCONTROL}
  tagMIXERCONTROL = tagMIXERCONTROLW;
  TMixerControlA = tagMIXERCONTROLA;
  TMixerControlW = tagMIXERCONTROLW;
  TMixerControl = TMixerControlW;
  {$EXTERNALSYM MIXERCONTROLA}
  MIXERCONTROLA = tagMIXERCONTROLA;
  {$EXTERNALSYM MIXERCONTROLW}
  MIXERCONTROLW = tagMIXERCONTROLW;
  {$EXTERNALSYM MIXERCONTROL}
  MIXERCONTROL = MIXERCONTROLW;

const
{ TMixerControl.fdwControl }

  {$EXTERNALSYM MIXERCONTROL_CONTROLF_UNIFORM}
  MIXERCONTROL_CONTROLF_UNIFORM   = $00000001;
  {$EXTERNALSYM MIXERCONTROL_CONTROLF_MULTIPLE}
  MIXERCONTROL_CONTROLF_MULTIPLE  = $00000002;
  {$EXTERNALSYM MIXERCONTROL_CONTROLF_DISABLED}
  MIXERCONTROL_CONTROLF_DISABLED  = $80000000;

{ MIXERCONTROL_CONTROLTYPE_xxx building block defines }

  {$EXTERNALSYM MIXERCONTROL_CT_CLASS_MASK}
  MIXERCONTROL_CT_CLASS_MASK          = $F0000000;
  {$EXTERNALSYM MIXERCONTROL_CT_CLASS_CUSTOM}
  MIXERCONTROL_CT_CLASS_CUSTOM        = $00000000;
  {$EXTERNALSYM MIXERCONTROL_CT_CLASS_METER}
  MIXERCONTROL_CT_CLASS_METER         = $10000000;
  {$EXTERNALSYM MIXERCONTROL_CT_CLASS_SWITCH}
  MIXERCONTROL_CT_CLASS_SWITCH        = $20000000;
  {$EXTERNALSYM MIXERCONTROL_CT_CLASS_NUMBER}
  MIXERCONTROL_CT_CLASS_NUMBER        = $30000000;
  {$EXTERNALSYM MIXERCONTROL_CT_CLASS_SLIDER}
  MIXERCONTROL_CT_CLASS_SLIDER        = $40000000;
  {$EXTERNALSYM MIXERCONTROL_CT_CLASS_FADER}
  MIXERCONTROL_CT_CLASS_FADER         = $50000000;
  {$EXTERNALSYM MIXERCONTROL_CT_CLASS_TIME}
  MIXERCONTROL_CT_CLASS_TIME          = $60000000;
  {$EXTERNALSYM MIXERCONTROL_CT_CLASS_LIST}
  MIXERCONTROL_CT_CLASS_LIST          = $70000000;

  {$EXTERNALSYM MIXERCONTROL_CT_SUBCLASS_MASK}
  MIXERCONTROL_CT_SUBCLASS_MASK       = $0F000000;

  {$EXTERNALSYM MIXERCONTROL_CT_SC_SWITCH_BOOLEAN}
  MIXERCONTROL_CT_SC_SWITCH_BOOLEAN   = $00000000;
  {$EXTERNALSYM MIXERCONTROL_CT_SC_SWITCH_BUTTON}
  MIXERCONTROL_CT_SC_SWITCH_BUTTON    = $01000000;

  {$EXTERNALSYM MIXERCONTROL_CT_SC_METER_POLLED}
  MIXERCONTROL_CT_SC_METER_POLLED     = $00000000;

  {$EXTERNALSYM MIXERCONTROL_CT_SC_TIME_MICROSECS}
  MIXERCONTROL_CT_SC_TIME_MICROSECS   = $00000000;
  {$EXTERNALSYM MIXERCONTROL_CT_SC_TIME_MILLISECS}
  MIXERCONTROL_CT_SC_TIME_MILLISECS   = $01000000;

  {$EXTERNALSYM MIXERCONTROL_CT_SC_LIST_SINGLE}
  MIXERCONTROL_CT_SC_LIST_SINGLE      = $00000000;
  {$EXTERNALSYM MIXERCONTROL_CT_SC_LIST_MULTIPLE}
  MIXERCONTROL_CT_SC_LIST_MULTIPLE    = $01000000;

  {$EXTERNALSYM MIXERCONTROL_CT_UNITS_MASK}
  MIXERCONTROL_CT_UNITS_MASK          = $00FF0000;
  {$EXTERNALSYM MIXERCONTROL_CT_UNITS_CUSTOM}
  MIXERCONTROL_CT_UNITS_CUSTOM        = $00000000;
  {$EXTERNALSYM MIXERCONTROL_CT_UNITS_BOOLEAN}
  MIXERCONTROL_CT_UNITS_BOOLEAN       = $00010000;
  {$EXTERNALSYM MIXERCONTROL_CT_UNITS_SIGNED}
  MIXERCONTROL_CT_UNITS_SIGNED        = $00020000;
  {$EXTERNALSYM MIXERCONTROL_CT_UNITS_UNSIGNED}
  MIXERCONTROL_CT_UNITS_UNSIGNED      = $00030000;
  {$EXTERNALSYM MIXERCONTROL_CT_UNITS_DECIBELS}
  MIXERCONTROL_CT_UNITS_DECIBELS      = $00040000; { in 10ths }
  {$EXTERNALSYM MIXERCONTROL_CT_UNITS_PERCENT}
  MIXERCONTROL_CT_UNITS_PERCENT       = $00050000; { in 10ths }

{ Commonly used control types for specifying TMixerControl.dwControlType }

  {$EXTERNALSYM MIXERCONTROL_CONTROLTYPE_CUSTOM}
  MIXERCONTROL_CONTROLTYPE_CUSTOM         = (MIXERCONTROL_CT_CLASS_CUSTOM or MIXERCONTROL_CT_UNITS_CUSTOM);
  {$EXTERNALSYM MIXERCONTROL_CONTROLTYPE_BOOLEANMETER}
  MIXERCONTROL_CONTROLTYPE_BOOLEANMETER   = (MIXERCONTROL_CT_CLASS_METER or MIXERCONTROL_CT_SC_METER_POLLED or MIXERCONTROL_CT_UNITS_BOOLEAN);
  {$EXTERNALSYM MIXERCONTROL_CONTROLTYPE_SIGNEDMETER}
  MIXERCONTROL_CONTROLTYPE_SIGNEDMETER    = (MIXERCONTROL_CT_CLASS_METER or MIXERCONTROL_CT_SC_METER_POLLED or MIXERCONTROL_CT_UNITS_SIGNED);
  {$EXTERNALSYM MIXERCONTROL_CONTROLTYPE_PEAKMETER}
  MIXERCONTROL_CONTROLTYPE_PEAKMETER      = (MIXERCONTROL_CONTROLTYPE_SIGNEDMETER + 1);
  {$EXTERNALSYM MIXERCONTROL_CONTROLTYPE_UNSIGNEDMETER}
  MIXERCONTROL_CONTROLTYPE_UNSIGNEDMETER  = (MIXERCONTROL_CT_CLASS_METER or MIXERCONTROL_CT_SC_METER_POLLED or MIXERCONTROL_CT_UNITS_UNSIGNED);
  {$EXTERNALSYM MIXERCONTROL_CONTROLTYPE_BOOLEAN}
  MIXERCONTROL_CONTROLTYPE_BOOLEAN        = (MIXERCONTROL_CT_CLASS_SWITCH or MIXERCONTROL_CT_SC_SWITCH_BOOLEAN or 
    MIXERCONTROL_CT_UNITS_BOOLEAN);
  {$EXTERNALSYM MIXERCONTROL_CONTROLTYPE_ONOFF}
  MIXERCONTROL_CONTROLTYPE_ONOFF          = (MIXERCONTROL_CONTROLTYPE_BOOLEAN + 1);
  {$EXTERNALSYM MIXERCONTROL_CONTROLTYPE_MUTE}
  MIXERCONTROL_CONTROLTYPE_MUTE           = (MIXERCONTROL_CONTROLTYPE_BOOLEAN + 2);
  {$EXTERNALSYM MIXERCONTROL_CONTROLTYPE_MONO}
  MIXERCONTROL_CONTROLTYPE_MONO           = (MIXERCONTROL_CONTROLTYPE_BOOLEAN + 3);
  {$EXTERNALSYM MIXERCONTROL_CONTROLTYPE_LOUDNESS}
  MIXERCONTROL_CONTROLTYPE_LOUDNESS       = (MIXERCONTROL_CONTROLTYPE_BOOLEAN + 4);
  {$EXTERNALSYM MIXERCONTROL_CONTROLTYPE_STEREOENH}
  MIXERCONTROL_CONTROLTYPE_STEREOENH      = (MIXERCONTROL_CONTROLTYPE_BOOLEAN + 5);
  {$EXTERNALSYM MIXERCONTROL_CONTROLTYPE_BUTTON}
  MIXERCONTROL_CONTROLTYPE_BUTTON         = (MIXERCONTROL_CT_CLASS_SWITCH or MIXERCONTROL_CT_SC_SWITCH_BUTTON or 
    MIXERCONTROL_CT_UNITS_BOOLEAN);
  {$EXTERNALSYM MIXERCONTROL_CONTROLTYPE_DECIBELS}
  MIXERCONTROL_CONTROLTYPE_DECIBELS       = (MIXERCONTROL_CT_CLASS_NUMBER or MIXERCONTROL_CT_UNITS_DECIBELS);
  {$EXTERNALSYM MIXERCONTROL_CONTROLTYPE_SIGNED}
  MIXERCONTROL_CONTROLTYPE_SIGNED         = (MIXERCONTROL_CT_CLASS_NUMBER or MIXERCONTROL_CT_UNITS_SIGNED);
  {$EXTERNALSYM MIXERCONTROL_CONTROLTYPE_UNSIGNED}
  MIXERCONTROL_CONTROLTYPE_UNSIGNED       = (MIXERCONTROL_CT_CLASS_NUMBER or MIXERCONTROL_CT_UNITS_UNSIGNED);
  {$EXTERNALSYM MIXERCONTROL_CONTROLTYPE_PERCENT}
  MIXERCONTROL_CONTROLTYPE_PERCENT        = (MIXERCONTROL_CT_CLASS_NUMBER or MIXERCONTROL_CT_UNITS_PERCENT);
  {$EXTERNALSYM MIXERCONTROL_CONTROLTYPE_SLIDER}
  MIXERCONTROL_CONTROLTYPE_SLIDER         = (MIXERCONTROL_CT_CLASS_SLIDER or MIXERCONTROL_CT_UNITS_SIGNED);
  {$EXTERNALSYM MIXERCONTROL_CONTROLTYPE_PAN}
  MIXERCONTROL_CONTROLTYPE_PAN            = (MIXERCONTROL_CONTROLTYPE_SLIDER + 1);
  {$EXTERNALSYM MIXERCONTROL_CONTROLTYPE_QSOUNDPAN}
  MIXERCONTROL_CONTROLTYPE_QSOUNDPAN      = (MIXERCONTROL_CONTROLTYPE_SLIDER + 2);
  {$EXTERNALSYM MIXERCONTROL_CONTROLTYPE_FADER}
  MIXERCONTROL_CONTROLTYPE_FADER          = (MIXERCONTROL_CT_CLASS_FADER or MIXERCONTROL_CT_UNITS_UNSIGNED);
  {$EXTERNALSYM MIXERCONTROL_CONTROLTYPE_VOLUME}
  MIXERCONTROL_CONTROLTYPE_VOLUME         = (MIXERCONTROL_CONTROLTYPE_FADER + 1);
  {$EXTERNALSYM MIXERCONTROL_CONTROLTYPE_BASS}
  MIXERCONTROL_CONTROLTYPE_BASS           = (MIXERCONTROL_CONTROLTYPE_FADER + 2);
  {$EXTERNALSYM MIXERCONTROL_CONTROLTYPE_TREBLE}
  MIXERCONTROL_CONTROLTYPE_TREBLE         = (MIXERCONTROL_CONTROLTYPE_FADER + 3);
  {$EXTERNALSYM MIXERCONTROL_CONTROLTYPE_EQUALIZER}
  MIXERCONTROL_CONTROLTYPE_EQUALIZER      = (MIXERCONTROL_CONTROLTYPE_FADER + 4);
  {$EXTERNALSYM MIXERCONTROL_CONTROLTYPE_SINGLESELECT}
  MIXERCONTROL_CONTROLTYPE_SINGLESELECT   = (MIXERCONTROL_CT_CLASS_LIST or MIXERCONTROL_CT_SC_LIST_SINGLE or MIXERCONTROL_CT_UNITS_BOOLEAN);
  {$EXTERNALSYM MIXERCONTROL_CONTROLTYPE_MUX}
  MIXERCONTROL_CONTROLTYPE_MUX            = (MIXERCONTROL_CONTROLTYPE_SINGLESELECT + 1);
  {$EXTERNALSYM MIXERCONTROL_CONTROLTYPE_MULTIPLESELECT}
  MIXERCONTROL_CONTROLTYPE_MULTIPLESELECT = (MIXERCONTROL_CT_CLASS_LIST or MIXERCONTROL_CT_SC_LIST_MULTIPLE or MIXERCONTROL_CT_UNITS_BOOLEAN);
  {$EXTERNALSYM MIXERCONTROL_CONTROLTYPE_MIXER}
  MIXERCONTROL_CONTROLTYPE_MIXER          = (MIXERCONTROL_CONTROLTYPE_MULTIPLESELECT + 1);
  {$EXTERNALSYM MIXERCONTROL_CONTROLTYPE_MICROTIME}
  MIXERCONTROL_CONTROLTYPE_MICROTIME      = (MIXERCONTROL_CT_CLASS_TIME or MIXERCONTROL_CT_SC_TIME_MICROSECS or 
    MIXERCONTROL_CT_UNITS_UNSIGNED);
  {$EXTERNALSYM MIXERCONTROL_CONTROLTYPE_MILLITIME}
  MIXERCONTROL_CONTROLTYPE_MILLITIME      = (MIXERCONTROL_CT_CLASS_TIME or MIXERCONTROL_CT_SC_TIME_MILLISECS or 
    MIXERCONTROL_CT_UNITS_UNSIGNED);


type
  PMixerLineControlsA = ^TMixerLineControlsA;
  PMixerLineControlsW = ^TMixerLineControlsW;
  PMixerLineControls = PMixerLineControlsW;
  {$EXTERNALSYM tagMIXERLINECONTROLSA}
  tagMIXERLINECONTROLSA = record
    cbStruct: DWORD;               { size in bytes of MIXERLINECONTROLS }
    dwLineID: DWORD;               { line id (from MIXERLINE.dwLineID) }
    case Integer of
      0: (dwControlID: DWORD);     { MIXER_GETLINECONTROLSF_ONEBYID }
      1: (dwControlType: DWORD;    { MIXER_GETLINECONTROLSF_ONEBYTYPE }
          cControls: DWORD;        { count of controls pmxctrl points to }
          cbmxctrl: DWORD;         { size in bytes of _one_ MIXERCONTROL }
          pamxctrl: PMixerControlA);   { pointer to first MIXERCONTROL array }
  end;
  {$EXTERNALSYM tagMIXERLINECONTROLSW}
  tagMIXERLINECONTROLSW = record
    cbStruct: DWORD;               { size in bytes of MIXERLINECONTROLS }
    dwLineID: DWORD;               { line id (from MIXERLINE.dwLineID) }
    case Integer of
      0: (dwControlID: DWORD);     { MIXER_GETLINECONTROLSF_ONEBYID }
      1: (dwControlType: DWORD;    { MIXER_GETLINECONTROLSF_ONEBYTYPE }
          cControls: DWORD;        { count of controls pmxctrl points to }
          cbmxctrl: DWORD;         { size in bytes of _one_ MIXERCONTROL }
          pamxctrl: PMixerControlW);   { pointer to first MIXERCONTROL array }
  end;
  {$EXTERNALSYM tagMIXERLINECONTROLS}
  tagMIXERLINECONTROLS = tagMIXERLINECONTROLSW;
  TMixerLineControlsA = tagMIXERLINECONTROLSA;
  TMixerLineControlsW = tagMIXERLINECONTROLSW;
  TMixerLineControls = TMixerLineControlsW;
  {$EXTERNALSYM MIXERLINECONTROLSA}
  MIXERLINECONTROLSA = tagMIXERLINECONTROLSA;
  {$EXTERNALSYM MIXERLINECONTROLSW}
  MIXERLINECONTROLSW = tagMIXERLINECONTROLSW;
  {$EXTERNALSYM MIXERLINECONTROLS}
  MIXERLINECONTROLS = MIXERLINECONTROLSW;

{$EXTERNALSYM mixerGetLineControls}
function mixerGetLineControls(hmxobj: HMIXEROBJ; pmxlc: PMixerLineControls; fdwControls: DWORD): MMRESULT; stdcall;
{$EXTERNALSYM mixerGetLineControlsA}
function mixerGetLineControlsA(hmxobj: HMIXEROBJ; pmxlc: PMixerLineControlsA; fdwControls: DWORD): MMRESULT; stdcall;
{$EXTERNALSYM mixerGetLineControlsW}
function mixerGetLineControlsW(hmxobj: HMIXEROBJ; pmxlc: PMixerLineControlsW; fdwControls: DWORD): MMRESULT; stdcall;

const
  {$EXTERNALSYM MIXER_GETLINECONTROLSF_ALL}
  MIXER_GETLINECONTROLSF_ALL          = $00000000;
  {$EXTERNALSYM MIXER_GETLINECONTROLSF_ONEBYID}
  MIXER_GETLINECONTROLSF_ONEBYID      = $00000001;
  {$EXTERNALSYM MIXER_GETLINECONTROLSF_ONEBYTYPE}
  MIXER_GETLINECONTROLSF_ONEBYTYPE    = $00000002;

  {$EXTERNALSYM MIXER_GETLINECONTROLSF_QUERYMASK}
  MIXER_GETLINECONTROLSF_QUERYMASK    = $0000000F;

type
  PMixerControlDetails = ^TMixerControlDetails;
  {$EXTERNALSYM tMIXERCONTROLDETAILS}
  tMIXERCONTROLDETAILS = record
    cbStruct: DWORD;               { size in bytes of MIXERCONTROLDETAILS }
    dwControlID: DWORD;            { control id to get/set details on }
    cChannels: DWORD;              { number of channels in paDetails array }
    // NOTE: Only hwndOwner andcMultipleItems are in the actual union.
    case Integer of
      0: (hwndOwner: HWND;         { for MIXER_SETCONTROLDETAILSF_CUSTOM }
          cbDetails: DWORD;        { size of _one_ details_XX struct }
          paDetails: Pointer);     { pointer to array of details_XX structs }
      1: (cMultipleItems: DWORD);  { if _MULTIPLE, the number of items per channel }
  end;

  PMixerControlDetailsListTextA = ^TMixerControlDetailsListTextA;
  PMixerControlDetailsListTextW = ^TMixerControlDetailsListTextW;
  PMixerControlDetailsListText = PMixerControlDetailsListTextW;
  {$EXTERNALSYM tagMIXERCONTROLDETAILS_LISTTEXTA}
  tagMIXERCONTROLDETAILS_LISTTEXTA = record
    dwParam1: DWORD;
    dwParam2: DWORD;
    szName: array[0..MIXER_LONG_NAME_CHARS - 1] of AnsiChar;
  end;
  {$EXTERNALSYM tagMIXERCONTROLDETAILS_LISTTEXTW}
  tagMIXERCONTROLDETAILS_LISTTEXTW = record
    dwParam1: DWORD;
    dwParam2: DWORD;
    szName: array[0..MIXER_LONG_NAME_CHARS - 1] of WideChar;
  end;
  {$EXTERNALSYM tagMIXERCONTROLDETAILS_LISTTEXT}
  tagMIXERCONTROLDETAILS_LISTTEXT = tagMIXERCONTROLDETAILS_LISTTEXTW;
  TMixerControlDetailsListTextA = tagMIXERCONTROLDETAILS_LISTTEXTA;
  TMixerControlDetailsListTextW = tagMIXERCONTROLDETAILS_LISTTEXTW;
  TMixerControlDetailsListText = TMixerControlDetailsListTextW;
  {$EXTERNALSYM MIXERCONTROLDETAILS_LISTTEXTA}
  MIXERCONTROLDETAILS_LISTTEXTA = tagMIXERCONTROLDETAILS_LISTTEXTA;
  {$EXTERNALSYM MIXERCONTROLDETAILS_LISTTEXTW}
  MIXERCONTROLDETAILS_LISTTEXTW = tagMIXERCONTROLDETAILS_LISTTEXTW;
  {$EXTERNALSYM MIXERCONTROLDETAILS_LISTTEXT}
  MIXERCONTROLDETAILS_LISTTEXT = MIXERCONTROLDETAILS_LISTTEXTW;

  PMixerControlDetailsBoolean = ^TMixerControlDetailsBoolean;
  {$EXTERNALSYM tMIXERCONTROLDETAILS_BOOLEAN}
  tMIXERCONTROLDETAILS_BOOLEAN = record
    fValue: Longint;
  end;
  TMixerControlDetailsBoolean = tMIXERCONTROLDETAILS_BOOLEAN;
  {$EXTERNALSYM MIXERCONTROLDETAILS_BOOLEAN}
  MIXERCONTROLDETAILS_BOOLEAN = tMIXERCONTROLDETAILS_BOOLEAN;

  PMixerControlDetailsSigned = ^TMixerControlDetailsSigned;
  {$EXTERNALSYM tMIXERCONTROLDETAILS_SIGNED}
  tMIXERCONTROLDETAILS_SIGNED = record
    lValue: Longint;
  end;
  TMixerControlDetailsSigned = tMIXERCONTROLDETAILS_SIGNED;
  {$EXTERNALSYM MIXERCONTROLDETAILS_SIGNED}
  MIXERCONTROLDETAILS_SIGNED = tMIXERCONTROLDETAILS_SIGNED;

  PMixerControlDetailsUnsigned = ^TMixerControlDetailsUnsigned;
  {$EXTERNALSYM tMIXERCONTROLDETAILS_UNSIGNED}
  tMIXERCONTROLDETAILS_UNSIGNED = record
    dwValue: DWORD;
  end;
  TMixerControlDetailsUnsigned = tMIXERCONTROLDETAILS_UNSIGNED;
  {$EXTERNALSYM MIXERCONTROLDETAILS_UNSIGNED}
  MIXERCONTROLDETAILS_UNSIGNED = tMIXERCONTROLDETAILS_UNSIGNED;

{$EXTERNALSYM mixerGetControlDetails}
function mixerGetControlDetails(hmxobj: HMIXEROBJ; pmxcd: PMixerControlDetails; fdwDetails: DWORD): MMRESULT; stdcall;
{$EXTERNALSYM mixerGetControlDetailsA}
function mixerGetControlDetailsA(hmxobj: HMIXEROBJ; pmxcd: PMixerControlDetails; fdwDetails: DWORD): MMRESULT; stdcall;
{$EXTERNALSYM mixerGetControlDetailsW}
function mixerGetControlDetailsW(hmxobj: HMIXEROBJ; pmxcd: PMixerControlDetails; fdwDetails: DWORD): MMRESULT; stdcall;

const
  {$EXTERNALSYM MIXER_GETCONTROLDETAILSF_VALUE}
  MIXER_GETCONTROLDETAILSF_VALUE      = $00000000;
  {$EXTERNALSYM MIXER_GETCONTROLDETAILSF_LISTTEXT}
  MIXER_GETCONTROLDETAILSF_LISTTEXT   = $00000001;

  {$EXTERNALSYM MIXER_GETCONTROLDETAILSF_QUERYMASK}
  MIXER_GETCONTROLDETAILSF_QUERYMASK  = $0000000F;

{$EXTERNALSYM mixerSetControlDetails}
function mixerSetControlDetails(hmxobj: HMIXEROBJ; pmxcd: PMixerControlDetails; fdwDetails: DWORD): MMRESULT; stdcall;

const
  {$EXTERNALSYM MIXER_SETCONTROLDETAILSF_VALUE}
  MIXER_SETCONTROLDETAILSF_VALUE      = $00000000;
  {$EXTERNALSYM MIXER_SETCONTROLDETAILSF_CUSTOM}
  MIXER_SETCONTROLDETAILSF_CUSTOM     = $00000001;

  {$EXTERNALSYM MIXER_SETCONTROLDETAILSF_QUERYMASK}
  MIXER_SETCONTROLDETAILSF_QUERYMASK  = $0000000F;

{***************************************************************************

                            Timer support

***************************************************************************}

{ timer error return values }
const
  {$EXTERNALSYM TIMERR_NOERROR}
  TIMERR_NOERROR        = 0;                  { no error }
  {$EXTERNALSYM TIMERR_NOCANDO}
  TIMERR_NOCANDO        = TIMERR_BASE+1;      { request not completed }
  {$EXTERNALSYM TIMERR_STRUCT}
  TIMERR_STRUCT         = TIMERR_BASE+33;     { time struct size }

{ timer data types }
type
  TFNTimeCallBack = procedure(uTimerID, uMessage: UINT; 
    dwUser, dw1, dw2: DWORD_PTR) stdcall;


{ flags for wFlags parameter of timeSetEvent() function }
const
  {$EXTERNALSYM TIME_ONESHOT}
  TIME_ONESHOT    = 0;   { program timer for single event }
  {$EXTERNALSYM TIME_PERIODIC}
  TIME_PERIODIC   = 1;   { program for continuous periodic event }
  {$EXTERNALSYM TIME_CALLBACK_FUNCTION}
  TIME_CALLBACK_FUNCTION    = $0000;  { callback is function }
  {$EXTERNALSYM TIME_CALLBACK_EVENT_SET}
  TIME_CALLBACK_EVENT_SET   = $0010;  { callback is event - use SetEvent }
  {$EXTERNALSYM TIME_CALLBACK_EVENT_PULSE}
  TIME_CALLBACK_EVENT_PULSE = $0020;  { callback is event - use PulseEvent }


  {$EXTERNALSYM TIME_KILL_SYNCHRONOUS}
  TIME_KILL_SYNCHRONOUS = $0100;  { This flag prevents the event from occurring }
                                  { after the user calls timeKillEvent() to }
                                  { destroy it. }

{ timer device capabilities data structure }
type
  PTimeCaps = ^TTimeCaps;
  {$EXTERNALSYM timecaps_tag}
  timecaps_tag = record
    wPeriodMin: UINT;     { minimum period supported  }
    wPeriodMax: UINT;     { maximum period supported  }
  end;
  TTimeCaps = timecaps_tag;
  {$EXTERNALSYM TIMECAPS}
  TIMECAPS = timecaps_tag;

{ timer function prototypes }
{$EXTERNALSYM timeGetSystemTime}
function timeGetSystemTime(lpTime: PMMTime; uSize: Word): MMRESULT; stdcall;

{$EXTERNALSYM timeGetTime}
function timeGetTime: DWORD; stdcall;
{$EXTERNALSYM timeSetEvent}
function timeSetEvent(uDelay, uResolution: UINT;
  lpFunction: TFNTimeCallBack; dwUser: DWORD_PTR; uFlags: UINT): MMRESULT; stdcall;
{$EXTERNALSYM timeKillEvent}
function timeKillEvent(uTimerID: UINT): MMRESULT; stdcall;
{$EXTERNALSYM timeGetDevCaps}
function timeGetDevCaps(lpTimeCaps: PTimeCaps; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM timeBeginPeriod}
function timeBeginPeriod(uPeriod: UINT): MMRESULT; stdcall;
{$EXTERNALSYM timeEndPeriod}
function timeEndPeriod(uPeriod: UINT): MMRESULT; stdcall;


{***************************************************************************

                            Joystick support

***************************************************************************}

{ joystick error return values }
const
  {$EXTERNALSYM JOYERR_NOERROR}
  JOYERR_NOERROR        = 0;                  { no error }
  {$EXTERNALSYM JOYERR_PARMS}
  JOYERR_PARMS          = JOYERR_BASE+5;      { bad parameters }
  {$EXTERNALSYM JOYERR_NOCANDO}
  JOYERR_NOCANDO        = JOYERR_BASE+6;      { request not completed }
  {$EXTERNALSYM JOYERR_UNPLUGGED}
  JOYERR_UNPLUGGED      = JOYERR_BASE+7;      { joystick is unplugged }

{ constants used with TJoyInfo and TJoyInfoEx structure and MM_JOY* messages }
const
  {$EXTERNALSYM JOY_BUTTON1}
  JOY_BUTTON1         = $0001;
  {$EXTERNALSYM JOY_BUTTON2}
  JOY_BUTTON2         = $0002;
  {$EXTERNALSYM JOY_BUTTON3}
  JOY_BUTTON3         = $0004;
  {$EXTERNALSYM JOY_BUTTON4}
  JOY_BUTTON4         = $0008;
  {$EXTERNALSYM JOY_BUTTON1CHG}
  JOY_BUTTON1CHG      = $0100;
  {$EXTERNALSYM JOY_BUTTON2CHG}
  JOY_BUTTON2CHG      = $0200;
  {$EXTERNALSYM JOY_BUTTON3CHG}
  JOY_BUTTON3CHG      = $0400;
  {$EXTERNALSYM JOY_BUTTON4CHG}
  JOY_BUTTON4CHG      = $0800;

{ constants used with TJoyInfoEx }
  {$EXTERNALSYM JOY_BUTTON5}
  JOY_BUTTON5         = $00000010;
  {$EXTERNALSYM JOY_BUTTON6}
  JOY_BUTTON6         = $00000020;
  {$EXTERNALSYM JOY_BUTTON7}
  JOY_BUTTON7         = $00000040;
  {$EXTERNALSYM JOY_BUTTON8}
  JOY_BUTTON8         = $00000080;
  {$EXTERNALSYM JOY_BUTTON9}
  JOY_BUTTON9         = $00000100;
  {$EXTERNALSYM JOY_BUTTON10}
  JOY_BUTTON10        = $00000200;
  {$EXTERNALSYM JOY_BUTTON11}
  JOY_BUTTON11        = $00000400;
  {$EXTERNALSYM JOY_BUTTON12}
  JOY_BUTTON12        = $00000800;
  {$EXTERNALSYM JOY_BUTTON13}
  JOY_BUTTON13        = $00001000;
  {$EXTERNALSYM JOY_BUTTON14}
  JOY_BUTTON14        = $00002000;
  {$EXTERNALSYM JOY_BUTTON15}
  JOY_BUTTON15        = $00004000;
  {$EXTERNALSYM JOY_BUTTON16}
  JOY_BUTTON16        = $00008000;
  {$EXTERNALSYM JOY_BUTTON17}
  JOY_BUTTON17        = $00010000;
  {$EXTERNALSYM JOY_BUTTON18}
  JOY_BUTTON18        = $00020000;
  {$EXTERNALSYM JOY_BUTTON19}
  JOY_BUTTON19        = $00040000;
  {$EXTERNALSYM JOY_BUTTON20}
  JOY_BUTTON20        = $00080000;
  {$EXTERNALSYM JOY_BUTTON21}
  JOY_BUTTON21        = $00100000;
  {$EXTERNALSYM JOY_BUTTON22}
  JOY_BUTTON22        = $00200000;
  {$EXTERNALSYM JOY_BUTTON23}
  JOY_BUTTON23        = $00400000;
  {$EXTERNALSYM JOY_BUTTON24}
  JOY_BUTTON24        = $00800000;
  {$EXTERNALSYM JOY_BUTTON25}
  JOY_BUTTON25        = $01000000;
  {$EXTERNALSYM JOY_BUTTON26}
  JOY_BUTTON26        = $02000000;
  {$EXTERNALSYM JOY_BUTTON27}
  JOY_BUTTON27        = $04000000;
  {$EXTERNALSYM JOY_BUTTON28}
  JOY_BUTTON28        = $08000000;
  {$EXTERNALSYM JOY_BUTTON29}
  JOY_BUTTON29        = $10000000;
  {$EXTERNALSYM JOY_BUTTON30}
  JOY_BUTTON30        = $20000000;
  {$EXTERNALSYM JOY_BUTTON31}
  JOY_BUTTON31        = $40000000;
  {$EXTERNALSYM JOY_BUTTON32}
  JOY_BUTTON32        = $80000000;

{ constants used with TJoyInfoEx }
  {$EXTERNALSYM JOY_POVCENTERED}
  JOY_POVCENTERED	= -1;
  {$EXTERNALSYM JOY_POVFORWARD}
  JOY_POVFORWARD	= 0;
  {$EXTERNALSYM JOY_POVRIGHT}
  JOY_POVRIGHT		= 9000;
  {$EXTERNALSYM JOY_POVBACKWARD}
  JOY_POVBACKWARD	= 18000;
  {$EXTERNALSYM JOY_POVLEFT}
  JOY_POVLEFT		= 27000;

  {$EXTERNALSYM JOY_RETURNX}
  JOY_RETURNX		= $00000001;
  {$EXTERNALSYM JOY_RETURNY}
  JOY_RETURNY		= $00000002;
  {$EXTERNALSYM JOY_RETURNZ}
  JOY_RETURNZ		= $00000004;
  {$EXTERNALSYM JOY_RETURNR}
  JOY_RETURNR		= $00000008;
  {$EXTERNALSYM JOY_RETURNU}
  JOY_RETURNU		= $00000010; { axis 5 }
  {$EXTERNALSYM JOY_RETURNV}
  JOY_RETURNV		= $00000020; { axis 6 }
  {$EXTERNALSYM JOY_RETURNPOV}
  JOY_RETURNPOV		= $00000040;
  {$EXTERNALSYM JOY_RETURNBUTTONS}
  JOY_RETURNBUTTONS	= $00000080;
  {$EXTERNALSYM JOY_RETURNRAWDATA}
  JOY_RETURNRAWDATA	= $00000100;
  {$EXTERNALSYM JOY_RETURNPOVCTS}
  JOY_RETURNPOVCTS	= $00000200;
  {$EXTERNALSYM JOY_RETURNCENTERED}
  JOY_RETURNCENTERED	= $00000400;
  {$EXTERNALSYM JOY_USEDEADZONE}
  JOY_USEDEADZONE		= $00000800;
  {$EXTERNALSYM JOY_RETURNALL}
  JOY_RETURNALL  = (JOY_RETURNX or JOY_RETURNY or JOY_RETURNZ or
    JOY_RETURNR or JOY_RETURNU or JOY_RETURNV or
    JOY_RETURNPOV or JOY_RETURNBUTTONS);
  {$EXTERNALSYM JOY_CAL_READALWAYS}
  JOY_CAL_READALWAYS	= $00010000;
  {$EXTERNALSYM JOY_CAL_READXYONLY}
  JOY_CAL_READXYONLY	= $00020000;
  {$EXTERNALSYM JOY_CAL_READ3}
  JOY_CAL_READ3		= $00040000;
  {$EXTERNALSYM JOY_CAL_READ4}
  JOY_CAL_READ4		= $00080000;
  {$EXTERNALSYM JOY_CAL_READXONLY}
  JOY_CAL_READXONLY	= $00100000;
  {$EXTERNALSYM JOY_CAL_READYONLY}
  JOY_CAL_READYONLY	= $00200000;
  {$EXTERNALSYM JOY_CAL_READ5}
  JOY_CAL_READ5		= $00400000;
  {$EXTERNALSYM JOY_CAL_READ6}
  JOY_CAL_READ6		= $00800000;
  {$EXTERNALSYM JOY_CAL_READZONLY}
  JOY_CAL_READZONLY	= $01000000;
  {$EXTERNALSYM JOY_CAL_READRONLY}
  JOY_CAL_READRONLY	= $02000000;
  {$EXTERNALSYM JOY_CAL_READUONLY}
  JOY_CAL_READUONLY	= $04000000;
  {$EXTERNALSYM JOY_CAL_READVONLY}
  JOY_CAL_READVONLY	= $08000000;

{ joystick ID constants }
const
  {$EXTERNALSYM JOYSTICKID1}
  JOYSTICKID1         = 0;
  {$EXTERNALSYM JOYSTICKID2}
  JOYSTICKID2         = 1;

{ joystick driver capabilites }
  {$EXTERNALSYM JOYCAPS_HASZ}
  JOYCAPS_HASZ		= $0001;
  {$EXTERNALSYM JOYCAPS_HASR}
  JOYCAPS_HASR		= $0002;
  {$EXTERNALSYM JOYCAPS_HASU}
  JOYCAPS_HASU		= $0004;
  {$EXTERNALSYM JOYCAPS_HASV}
  JOYCAPS_HASV		= $0008;
  {$EXTERNALSYM JOYCAPS_HASPOV}
  JOYCAPS_HASPOV		= $0010;
  {$EXTERNALSYM JOYCAPS_POV4DIR}
  JOYCAPS_POV4DIR		= $0020;
  {$EXTERNALSYM JOYCAPS_POVCTS}
  JOYCAPS_POVCTS		= $0040;

{ joystick device capabilities data structure }
type
  PJoyCapsA = ^TJoyCapsA;
  PJoyCapsW = ^TJoyCapsW;
  PJoyCaps = PJoyCapsW;
  {$EXTERNALSYM tagJOYCAPSA}
  tagJOYCAPSA = record
    wMid: Word;                  { manufacturer ID }
    wPid: Word;                  { product ID }
    szPname: array[0..MAXPNAMELEN-1] of AnsiChar;  { product name (NULL terminated AnsiString) }
    wXmin: UINT;                 { minimum x position value }
    wXmax: UINT;                 { maximum x position value }
    wYmin: UINT;                 { minimum y position value }
    wYmax: UINT;                 { maximum y position value }
    wZmin: UINT;                 { minimum z position value }
    wZmax: UINT;                 { maximum z position value }
    wNumButtons: UINT;           { number of buttons }
    wPeriodMin: UINT;            { minimum message period when captured }
    wPeriodMax: UINT;            { maximum message period when captured }
    wRmin: UINT;                 { minimum r position value }
    wRmax: UINT;                 { maximum r position value }
    wUmin: UINT;                 { minimum u (5th axis) position value }
    wUmax: UINT;                 { maximum u (5th axis) position value }
    wVmin: UINT;                 { minimum v (6th axis) position value }
    wVmax: UINT;                 { maximum v (6th axis) position value }
    wCaps: UINT;                 { joystick capabilites }
    wMaxAxes: UINT;	 	{ maximum number of axes supported }
    wNumAxes: UINT;	 	{ number of axes in use }
    wMaxButtons: UINT;	 	{ maximum number of buttons supported }
    szRegKey: array[0..MAXPNAMELEN - 1] of AnsiChar; { registry key }
    szOEMVxD: array[0..MAX_JOYSTICKOEMVXDNAME - 1] of AnsiChar; { OEM VxD in use }
  end;
  {$EXTERNALSYM tagJOYCAPSW}
  tagJOYCAPSW = record
    wMid: Word;                  { manufacturer ID }
    wPid: Word;                  { product ID }
    szPname: array[0..MAXPNAMELEN-1] of WideChar;  { product name (NULL terminated UnicodeString) }
    wXmin: UINT;                 { minimum x position value }
    wXmax: UINT;                 { maximum x position value }
    wYmin: UINT;                 { minimum y position value }
    wYmax: UINT;                 { maximum y position value }
    wZmin: UINT;                 { minimum z position value }
    wZmax: UINT;                 { maximum z position value }
    wNumButtons: UINT;           { number of buttons }
    wPeriodMin: UINT;            { minimum message period when captured }
    wPeriodMax: UINT;            { maximum message period when captured }
    wRmin: UINT;                 { minimum r position value }
    wRmax: UINT;                 { maximum r position value }
    wUmin: UINT;                 { minimum u (5th axis) position value }
    wUmax: UINT;                 { maximum u (5th axis) position value }
    wVmin: UINT;                 { minimum v (6th axis) position value }
    wVmax: UINT;                 { maximum v (6th axis) position value }
    wCaps: UINT;                 { joystick capabilites }
    wMaxAxes: UINT;	 	{ maximum number of axes supported }
    wNumAxes: UINT;	 	{ number of axes in use }
    wMaxButtons: UINT;	 	{ maximum number of buttons supported }
    szRegKey: array[0..MAXPNAMELEN - 1] of WideChar; { registry key }
    szOEMVxD: array[0..MAX_JOYSTICKOEMVXDNAME - 1] of WideChar; { OEM VxD in use }
  end;
  {$EXTERNALSYM tagJOYCAPS}
  tagJOYCAPS = tagJOYCAPSW;
  TJoyCapsA = tagJOYCAPSA;
  TJoyCapsW = tagJOYCAPSW;
  TJoyCaps = TJoyCapsW;
  {$EXTERNALSYM JOYCAPSA}
  JOYCAPSA = tagJOYCAPSA;
  {$EXTERNALSYM JOYCAPSW}
  JOYCAPSW = tagJOYCAPSW;
  {$EXTERNALSYM JOYCAPS}
  JOYCAPS = JOYCAPSW;

{ joystick information data structure }
type
  PJoyInfo = ^TJoyInfo;
  {$EXTERNALSYM joyinfo_tag}
  joyinfo_tag = record
    wXpos: UINT;                 { x position }
    wYpos: UINT;                 { y position }
    wZpos: UINT;                 { z position }
    wButtons: UINT;              { button states }
  end;
  TJoyInfo = joyinfo_tag;
  {$EXTERNALSYM JOYINFO}
  JOYINFO = joyinfo_tag;

  PJoyInfoEx = ^TJoyInfoEx;
  {$EXTERNALSYM joyinfoex_tag}
  joyinfoex_tag = record
    dwSize: DWORD;		 { size of structure }
    dwFlags: DWORD;		 { flags to indicate what to return }
    wXpos: UINT;         { x position }
    wYpos: UINT;         { y position }
    wZpos: UINT;         { z position }
    dwRpos: DWORD;		 { rudder/4th axis position }
    dwUpos: DWORD;		 { 5th axis position }
    dwVpos: DWORD;		 { 6th axis position }
    wButtons: UINT;      { button states }
    dwButtonNumber: DWORD;  { current button number pressed }
    dwPOV: DWORD;           { point of view state }
    dwReserved1: DWORD;		 { reserved for communication between winmm & driver }
    dwReserved2: DWORD;		 { reserved for future expansion }
  end;
  TJoyInfoEx = joyinfoex_tag;
  {$EXTERNALSYM JOYINFOEX}
  JOYINFOEX = joyinfoex_tag;

{ joystick function prototypes }
{$EXTERNALSYM joyGetNumDevs}
function joyGetNumDevs: UINT; stdcall;
{$EXTERNALSYM joyGetDevCaps}
function joyGetDevCaps(uJoyID: UIntPtr; lpCaps: PJoyCaps; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM joyGetDevCapsA}
function joyGetDevCapsA(uJoyID: UIntPtr; lpCaps: PJoyCapsA; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM joyGetDevCapsW}
function joyGetDevCapsW(uJoyID: UIntPtr; lpCaps: PJoyCapsW; uSize: UINT): MMRESULT; stdcall;
{$EXTERNALSYM joyGetPos}
function joyGetPos(uJoyID: UINT; lpInfo: PJoyInfo): MMRESULT; stdcall;
{$EXTERNALSYM joyGetPosEx}
function joyGetPosEx(uJoyID: UINT; lpInfo: PJoyInfoEx): MMRESULT; stdcall;
{$EXTERNALSYM joyGetThreshold}
function joyGetThreshold(uJoyID: UINT; lpuThreshold: PUINT): MMRESULT; stdcall;
{$EXTERNALSYM joyReleaseCapture}
function joyReleaseCapture(uJoyID: UINT): MMRESULT; stdcall;
{$EXTERNALSYM joySetCapture}
function joySetCapture(Handle: HWND; uJoyID, uPeriod: UINT; bChanged: BOOL): MMRESULT; stdcall;
{$EXTERNALSYM joySetThreshold}
function joySetThreshold(uJoyID, uThreshold: UINT): MMRESULT; stdcall;

{***************************************************************************

                        Multimedia File I/O support

***************************************************************************}

{ MMIO error return values }
const
  {$EXTERNALSYM MMIOERR_BASE}
  MMIOERR_BASE            = 256;
  {$EXTERNALSYM MMIOERR_FILENOTFOUND}
  MMIOERR_FILENOTFOUND    = MMIOERR_BASE + 1;  { file not found }
  {$EXTERNALSYM MMIOERR_OUTOFMEMORY}
  MMIOERR_OUTOFMEMORY     = MMIOERR_BASE + 2;  { out of memory }
  {$EXTERNALSYM MMIOERR_CANNOTOPEN}
  MMIOERR_CANNOTOPEN      = MMIOERR_BASE + 3;  { cannot open }
  {$EXTERNALSYM MMIOERR_CANNOTCLOSE}
  MMIOERR_CANNOTCLOSE     = MMIOERR_BASE + 4;  { cannot close }
  {$EXTERNALSYM MMIOERR_CANNOTREAD}
  MMIOERR_CANNOTREAD      = MMIOERR_BASE + 5;  { cannot read }
  {$EXTERNALSYM MMIOERR_CANNOTWRITE}
  MMIOERR_CANNOTWRITE     = MMIOERR_BASE + 6;  { cannot write }
  {$EXTERNALSYM MMIOERR_CANNOTSEEK}
  MMIOERR_CANNOTSEEK      = MMIOERR_BASE + 7;  { cannot seek }
  {$EXTERNALSYM MMIOERR_CANNOTEXPAND}
  MMIOERR_CANNOTEXPAND    = MMIOERR_BASE + 8;  { cannot expand file }
  {$EXTERNALSYM MMIOERR_CHUNKNOTFOUND}
  MMIOERR_CHUNKNOTFOUND   = MMIOERR_BASE + 9;  { chunk not found }
  {$EXTERNALSYM MMIOERR_UNBUFFERED}
  MMIOERR_UNBUFFERED      = MMIOERR_BASE + 10; { file is unbuffered }
  {$EXTERNALSYM MMIOERR_PATHNOTFOUND}
  MMIOERR_PATHNOTFOUND        = MMIOERR_BASE + 11;  { path incorrect }
  {$EXTERNALSYM MMIOERR_ACCESSDENIED}
  MMIOERR_ACCESSDENIED        = MMIOERR_BASE + 12;  { file was protected }
  {$EXTERNALSYM MMIOERR_SHARINGVIOLATION}
  MMIOERR_SHARINGVIOLATION    = MMIOERR_BASE + 13;  { file in use }
  {$EXTERNALSYM MMIOERR_NETWORKERROR}
  MMIOERR_NETWORKERROR        = MMIOERR_BASE + 14;  { network not responding }
  {$EXTERNALSYM MMIOERR_TOOMANYOPENFILES}
  MMIOERR_TOOMANYOPENFILES    = MMIOERR_BASE + 15;  { no more file handles  }
  {$EXTERNALSYM MMIOERR_INVALIDFILE}
  MMIOERR_INVALIDFILE         = MMIOERR_BASE + 16;  { default error file error }

{ MMIO constants }
const
  {$EXTERNALSYM CFSEPCHAR}
  CFSEPCHAR       = '+';             { compound file name separator char. }

type
{ MMIO data types }
  {$EXTERNALSYM FOURCC}
  FOURCC = DWORD;                    { a four character code }

  PHMMIO = ^HMMIO;
  {$EXTERNALSYM HMMIO}
  HMMIO = IntPtr;      { a handle to an open file }

  TFNMMIOProc = function(lpmmioinfo: PAnsiChar; uMessage: UINT; lParam1, lParam2: LPARAM): Longint stdcall;

{ general MMIO information data structure }
type
  PMMIOInfo = ^TMMIOInfo;
  {$EXTERNALSYM _MMIOINFO}
  _MMIOINFO = record
    { general fields }
    dwFlags: DWORD;        { general status flags }
    fccIOProc: FOURCC;      { pointer to I/O procedure }
    pIOProc: TFNMMIOProc;        { pointer to I/O procedure }
    wErrorRet: UINT;      { place for error to be returned }
    hTask: HTASK;          { alternate local task }

    { fields maintained by MMIO functions during buffered I/O }
    cchBuffer: Longint;      { size of I/O buffer (or 0L) }
    pchBuffer: PAnsiChar;      { start of I/O buffer (or NULL) }
    pchNext: PAnsiChar;        { pointer to next byte to read/write }
    pchEndRead: PAnsiChar;     { pointer to last valid byte to read }
    pchEndWrite: PAnsiChar;    { pointer to last byte to write }
    lBufOffset: Longint;     { disk offset of start of buffer }

    { fields maintained by I/O procedure }
    lDiskOffset: Longint;    { disk offset of next read or write }
    adwInfo: array[0..2] of DWORD;     { data specific to type of MMIOPROC }

    { other fields maintained by MMIO }
    dwReserved1: DWORD;    { reserved for MMIO use }
    dwReserved2: DWORD;    { reserved for MMIO use }
    hmmio: HMMIO;          { handle to open file }
  end;
  TMMIOInfo = _MMIOINFO;
  {$EXTERNALSYM MMIOINFO}
  MMIOINFO = _MMIOINFO;


{ RIFF chunk information data structure }
type

  PMMCKInfo = ^TMMCKInfo;
  {$EXTERNALSYM _MMCKINFO}
  _MMCKINFO = record
    ckid: FOURCC;           { chunk ID }
    cksize: DWORD;         { chunk size }
    fccType: FOURCC;        { form type or list type }
    dwDataOffset: DWORD;   { offset of data portion of chunk }
    dwFlags: DWORD;        { flags used by MMIO functions }
  end;
  TMMCKInfo = _MMCKINFO;
  {$EXTERNALSYM MMCKINFO}
  MMCKINFO = _MMCKINFO;

{ bit field masks }
const
  {$EXTERNALSYM MMIO_RWMODE}
  MMIO_RWMODE     = $00000003;      { open file for reading/writing/both }
  {$EXTERNALSYM MMIO_SHAREMODE}
  MMIO_SHAREMODE  = $00000070;      { file sharing mode number }

{ constants for dwFlags field of MMIOINFO }
const
  {$EXTERNALSYM MMIO_CREATE}
  MMIO_CREATE    = $00001000;     { create new file (or truncate file) }
  {$EXTERNALSYM MMIO_PARSE}
  MMIO_PARSE     = $00000100;     { parse new file returning path }
  {$EXTERNALSYM MMIO_DELETE}
  MMIO_DELETE    = $00000200;     { create new file (or truncate file) }
  {$EXTERNALSYM MMIO_EXIST}
  MMIO_EXIST     = $00004000;     { checks for existence of file }
  {$EXTERNALSYM MMIO_ALLOCBUF}
  MMIO_ALLOCBUF  = $00010000;     { mmioOpen() should allocate a buffer }
  {$EXTERNALSYM MMIO_GETTEMP}
  MMIO_GETTEMP   = $00020000;     { mmioOpen() should retrieve temp name }

const
  {$EXTERNALSYM MMIO_DIRTY}
  MMIO_DIRTY     = $10000000;     { I/O buffer is dirty }

{ read/write mode numbers (bit field MMIO_RWMODE) }
const
  {$EXTERNALSYM MMIO_READ}
  MMIO_READ       = $00000000;      { open file for reading only }
  {$EXTERNALSYM MMIO_WRITE}
  MMIO_WRITE      = $00000001;      { open file for writing only }
  {$EXTERNALSYM MMIO_READWRITE}
  MMIO_READWRITE  = $00000002;      { open file for reading and writing }

{ share mode numbers (bit field MMIO_SHAREMODE) }
const
  {$EXTERNALSYM MMIO_COMPAT}
  MMIO_COMPAT     = $00000000;      { compatibility mode }
  {$EXTERNALSYM MMIO_EXCLUSIVE}
  MMIO_EXCLUSIVE  = $00000010;      { exclusive-access mode }
  {$EXTERNALSYM MMIO_DENYWRITE}
  MMIO_DENYWRITE  = $00000020;      { deny writing to other processes }
  {$EXTERNALSYM MMIO_DENYREAD}
  MMIO_DENYREAD   = $00000030;      { deny reading to other processes }
  {$EXTERNALSYM MMIO_DENYNONE}
  MMIO_DENYNONE   = $00000040;      { deny nothing to other processes }

{ various MMIO flags }
const
  {$EXTERNALSYM MMIO_FHOPEN}
  MMIO_FHOPEN             = $0010;  { mmioClose: keep file handle open }
  {$EXTERNALSYM MMIO_EMPTYBUF}
  MMIO_EMPTYBUF           = $0010;  { mmioFlush: empty the I/O buffer }
  {$EXTERNALSYM MMIO_TOUPPER}
  MMIO_TOUPPER            = $0010;  { mmioStringToFOURCC: to u-case }
  {$EXTERNALSYM MMIO_INSTALLPROC}
  MMIO_INSTALLPROC    = $00010000;  { mmioInstallIOProc: install MMIOProc }
  {$EXTERNALSYM MMIO_GLOBALPROC}
  MMIO_GLOBALPROC     = $10000000;  { mmioInstallIOProc: install globally }
  {$EXTERNALSYM MMIO_REMOVEPROC}
  MMIO_REMOVEPROC     = $00020000;  { mmioInstallIOProc: remove MMIOProc }
  {$EXTERNALSYM MMIO_UNICODEPROC}
  MMIO_UNICODEPROC    = $01000000;  { mmioInstallIOProc: Unicode MMIOProc }
  {$EXTERNALSYM MMIO_FINDPROC}
  MMIO_FINDPROC       = $00040000;  { mmioInstallIOProc: find an MMIOProc }
  {$EXTERNALSYM MMIO_FINDCHUNK}
  MMIO_FINDCHUNK          = $0010;  { mmioDescend: find a chunk by ID }
  {$EXTERNALSYM MMIO_FINDRIFF}
  MMIO_FINDRIFF           = $0020;  { mmioDescend: find a LIST chunk }
  {$EXTERNALSYM MMIO_FINDLIST}
  MMIO_FINDLIST           = $0040;  { mmioDescend: find a RIFF chunk }
  {$EXTERNALSYM MMIO_CREATERIFF}
  MMIO_CREATERIFF         = $0020;  { mmioCreateChunk: make a LIST chunk }
  {$EXTERNALSYM MMIO_CREATELIST}
  MMIO_CREATELIST         = $0040;  { mmioCreateChunk: make a RIFF chunk }


{ message numbers for MMIOPROC I/O procedure functions }
const
  {$EXTERNALSYM MMIOM_READ}
  MMIOM_READ      = MMIO_READ;       { read }
  {$EXTERNALSYM MMIOM_WRITE}
  MMIOM_WRITE    = MMIO_WRITE;       { write }
  {$EXTERNALSYM MMIOM_SEEK}
  MMIOM_SEEK              = 2;       { seek to a new position in file }
  {$EXTERNALSYM MMIOM_OPEN}
  MMIOM_OPEN              = 3;       { open file }
  {$EXTERNALSYM MMIOM_CLOSE}
  MMIOM_CLOSE             = 4;       { close file }
  {$EXTERNALSYM MMIOM_WRITEFLUSH}
  MMIOM_WRITEFLUSH        = 5;       { write and flush }

const
  {$EXTERNALSYM MMIOM_RENAME}
  MMIOM_RENAME            = 6;       { rename specified file }

  {$EXTERNALSYM MMIOM_USER}
  MMIOM_USER         = $8000;       { beginning of user-defined messages }

{ standard four character codes }
const
  {$EXTERNALSYM FOURCC_RIFF}
  FOURCC_RIFF = $46464952;   { 'RIFF' }
  {$EXTERNALSYM FOURCC_LIST}
  FOURCC_LIST = $5453494C;   { 'LIST' }

{ four character codes used to identify standard built-in I/O procedures }
const
  {$EXTERNALSYM FOURCC_DOS}
  FOURCC_DOS  = $20534F44;   { 'DOS '}
  {$EXTERNALSYM FOURCC_MEM}
  FOURCC_MEM  = $204D454D;   { 'MEM '}

{ flags for mmioSeek() }
const
  {$EXTERNALSYM SEEK_SET}
  SEEK_SET        = 0;               { seek to an absolute position }
  {$EXTERNALSYM SEEK_CUR}
  SEEK_CUR        = 1;               { seek relative to current position }
  {$EXTERNALSYM SEEK_END}
  SEEK_END        = 2;               { seek relative to end of file }

{ other constants }
const
  {$EXTERNALSYM MMIO_DEFAULTBUFFER}
  MMIO_DEFAULTBUFFER      = 8192;    { default buffer size }

{ MMIO function prototypes }
{$EXTERNALSYM mmioStringToFOURCC}
function mmioStringToFOURCC(sz: LPWSTR; uFlags: UINT): FOURCC; stdcall;
{$EXTERNALSYM mmioStringToFOURCCA}
function mmioStringToFOURCCA(sz: LPSTR; uFlags: UINT): FOURCC; stdcall;
{$EXTERNALSYM mmioStringToFOURCCW}
function mmioStringToFOURCCW(sz: LPWSTR; uFlags: UINT): FOURCC; stdcall;
{$EXTERNALSYM mmioInstallIOProc}
function mmioInstallIOProc(fccIOProc: FOURCC; pIOProc: TFNMMIOProc;
  dwFlags: DWORD): TFNMMIOProc; stdcall;
{$EXTERNALSYM mmioInstallIOProcA}
function mmioInstallIOProcA(fccIOProc: FOURCC; pIOProc: TFNMMIOProc;
  dwFlags: DWORD): TFNMMIOProc; stdcall;
{$EXTERNALSYM mmioInstallIOProcW}
function mmioInstallIOProcW(fccIOProc: FOURCC; pIOProc: TFNMMIOProc;
  dwFlags: DWORD): TFNMMIOProc; stdcall;
{$EXTERNALSYM mmioOpen}
function mmioOpen(szFileName: LPWSTR; lpmmioinfo: PMMIOInfo;
  dwOpenFlags: DWORD): HMMIO; stdcall;
{$EXTERNALSYM mmioOpenA}
function mmioOpenA(szFileName: LPSTR; lpmmioinfo: PMMIOInfo;
  dwOpenFlags: DWORD): HMMIO; stdcall;
{$EXTERNALSYM mmioOpenW}
function mmioOpenW(szFileName: LPWSTR; lpmmioinfo: PMMIOInfo;
  dwOpenFlags: DWORD): HMMIO; stdcall;
{$EXTERNALSYM mmioRename}
function mmioRename(szFileName, szNewFileName: LPWSTR;
  lpmmioinfo: PMMIOInfo; dwRenameFlags: DWORD): MMRESULT; stdcall;
{$EXTERNALSYM mmioRenameA}
function mmioRenameA(szFileName, szNewFileName: LPSTR;
  lpmmioinfo: PMMIOInfo; dwRenameFlags: DWORD): MMRESULT; stdcall;
{$EXTERNALSYM mmioRenameW}
function mmioRenameW(szFileName, szNewFileName: LPWSTR;
  lpmmioinfo: PMMIOInfo; dwRenameFlags: DWORD): MMRESULT; stdcall;
{$EXTERNALSYM mmioClose}
function mmioClose(hmmio: HMMIO; uFlags: UINT): MMRESULT; stdcall;
{$EXTERNALSYM mmioRead}
function mmioRead(hmmio: HMMIO; pch: PAnsiChar; cch: Longint): Longint; stdcall;
{$EXTERNALSYM mmioWrite}
function mmioWrite(hmmio: HMMIO; pch: PAnsiChar; cch: Longint): Longint; stdcall;
{$EXTERNALSYM mmioSeek}
function mmioSeek(hmmio: HMMIO; lOffset: Longint; 
  iOrigin: Integer): Longint; stdcall;
{$EXTERNALSYM mmioGetInfo}
function mmioGetInfo(hmmio: HMMIO; lpmmioinfo: PMMIOInfo; uFlags: UINT): MMRESULT; stdcall;
{$EXTERNALSYM mmioSetInfo}
function mmioSetInfo(hmmio: HMMIO; lpmmioinfo: PMMIOInfo; uFlags: UINT): MMRESULT; stdcall;
{$EXTERNALSYM mmioSetBuffer}
function mmioSetBuffer(hmmio: HMMIO; pchBuffer: PAnsiChar; cchBuffer: Longint;
  uFlags: Word): MMRESULT; stdcall;
{$EXTERNALSYM mmioFlush}
function mmioFlush(hmmio: HMMIO; uFlags: UINT): MMRESULT; stdcall;
{$EXTERNALSYM mmioAdvance}
function mmioAdvance(hmmio: HMMIO; lpmmioinfo: PMMIOInfo; uFlags: UINT): MMRESULT; stdcall;
{$EXTERNALSYM mmioSendMessage}
function mmioSendMessage(hmmio: HMMIO; uMessage: UINT;
  lParam1, lParam2: DWORD): Longint; stdcall;
{$EXTERNALSYM mmioDescend}
function mmioDescend(hmmio: HMMIO; lpck: PMMCKInfo;
  lpckParent: PMMCKInfo; uFlags: UINT): MMRESULT; stdcall;
{$EXTERNALSYM mmioAscend}
function mmioAscend(hmmio: HMMIO; lpck: PMMCKInfo; uFlags: UINT): MMRESULT; stdcall;
{$EXTERNALSYM mmioCreateChunk}
function mmioCreateChunk(hmmio: HMMIO; lpck: PMMCKInfo; uFlags: UINT): MMRESULT; stdcall;


{***************************************************************************

                            MCI support

***************************************************************************}

type
  {$EXTERNALSYM MCIERROR}
  MCIERROR = DWORD;     { error return code, 0 means no error }
  {$EXTERNALSYM MCIDEVICEID}
  MCIDEVICEID = UINT;   { MCI device ID type }

  TFNYieldProc = function(mciId: MCIDEVICEID; dwYieldData: DWORD): UINT stdcall;

{ MCI function prototypes }
{$EXTERNALSYM mciSendCommand}
function mciSendCommand(mciId: MCIDEVICEID; uMessage: UINT;
  dwParam1, dwParam2: DWORD_PTR): MCIERROR; stdcall;
{$EXTERNALSYM mciSendCommandA}
function mciSendCommandA(mciId: MCIDEVICEID; uMessage: UINT;
  dwParam1, dwParam2: DWORD_PTR): MCIERROR; stdcall;
{$EXTERNALSYM mciSendCommandW}
function mciSendCommandW(mciId: MCIDEVICEID; uMessage: UINT;
  dwParam1, dwParam2: DWORD_PTR): MCIERROR; stdcall;
{$EXTERNALSYM mciSendString}
function mciSendString(lpstrCommand, lpstrReturnString: LPCWSTR;
  uReturnLength: UINT; hWndCallback: HWND): MCIERROR; stdcall;
{$EXTERNALSYM mciSendStringA}
function mciSendStringA(lpstrCommand, lpstrReturnString: LPCSTR;
  uReturnLength: UINT; hWndCallback: HWND): MCIERROR; stdcall;
{$EXTERNALSYM mciSendStringW}
function mciSendStringW(lpstrCommand, lpstrReturnString: LPCWSTR;
  uReturnLength: UINT; hWndCallback: HWND): MCIERROR; stdcall;
{$EXTERNALSYM mciGetDeviceID}
function mciGetDeviceID(pszDevice: LPCWSTR): MCIDEVICEID; stdcall;
{$EXTERNALSYM mciGetDeviceIDA}
function mciGetDeviceIDA(pszDevice: LPCSTR): MCIDEVICEID; stdcall;
{$EXTERNALSYM mciGetDeviceIDW}
function mciGetDeviceIDW(pszDevice: LPCWSTR): MCIDEVICEID; stdcall;
{$EXTERNALSYM mciGetDeviceIDFromElementID}
function mciGetDeviceIDFromElementID(dwElementID: DWORD; lpstrType: LPCWSTR): MCIDEVICEID; stdcall;
{$EXTERNALSYM mciGetDeviceIDFromElementIDA}
function mciGetDeviceIDFromElementIDA(dwElementID: DWORD; lpstrType: LPCSTR): MCIDEVICEID; stdcall;
{$EXTERNALSYM mciGetDeviceIDFromElementIDW}
function mciGetDeviceIDFromElementIDW(dwElementID: DWORD; lpstrType: LPCWSTR): MCIDEVICEID; stdcall;
{$EXTERNALSYM mciGetErrorString}
function mciGetErrorString(mcierr: MCIERROR; pszText: LPWSTR; uLength: UINT): BOOL; stdcall;
{$EXTERNALSYM mciGetErrorStringA}
function mciGetErrorStringA(mcierr: MCIERROR; pszText: LPSTR; uLength: UINT): BOOL; stdcall;
{$EXTERNALSYM mciGetErrorStringW}
function mciGetErrorStringW(mcierr: MCIERROR; pszText: LPWSTR; uLength: UINT): BOOL; stdcall;
{$EXTERNALSYM mciSetYieldProc}
function mciSetYieldProc(mciId: MCIDEVICEID; fpYieldProc: TFNYieldProc;
  dwYieldData: DWORD): BOOL; stdcall;
{$EXTERNALSYM mciGetCreatorTask}
function mciGetCreatorTask(mciId: MCIDEVICEID): HTASK; stdcall;
{$EXTERNALSYM mciGetYieldProc}
function mciGetYieldProc(mciId: MCIDEVICEID; lpdwYieldData: PDWORD): TFNYieldProc; stdcall;
{$EXTERNALSYM mciExecute}
function mciExecute(pszCommand: LPCSTR): BOOL; stdcall;


{ MCI error return values }
const
  {$EXTERNALSYM MCIERR_INVALID_DEVICE_ID}
  MCIERR_INVALID_DEVICE_ID        = MCIERR_BASE + 1;
  {$EXTERNALSYM MCIERR_UNRECOGNIZED_KEYWORD}
  MCIERR_UNRECOGNIZED_KEYWORD     = MCIERR_BASE + 3;
  {$EXTERNALSYM MCIERR_UNRECOGNIZED_COMMAND}
  MCIERR_UNRECOGNIZED_COMMAND     = MCIERR_BASE + 5;
  {$EXTERNALSYM MCIERR_HARDWARE}
  MCIERR_HARDWARE                 = MCIERR_BASE + 6;
  {$EXTERNALSYM MCIERR_INVALID_DEVICE_NAME}
  MCIERR_INVALID_DEVICE_NAME      = MCIERR_BASE + 7;
  {$EXTERNALSYM MCIERR_OUT_OF_MEMORY}
  MCIERR_OUT_OF_MEMORY            = MCIERR_BASE + 8;
  {$EXTERNALSYM MCIERR_DEVICE_OPEN}
  MCIERR_DEVICE_OPEN              = MCIERR_BASE + 9;
  {$EXTERNALSYM MCIERR_CANNOT_LOAD_DRIVER}
  MCIERR_CANNOT_LOAD_DRIVER       = MCIERR_BASE + 10;
  {$EXTERNALSYM MCIERR_MISSING_COMMAND_STRING}
  MCIERR_MISSING_COMMAND_STRING   = MCIERR_BASE + 11;
  {$EXTERNALSYM MCIERR_PARAM_OVERFLOW}
  MCIERR_PARAM_OVERFLOW           = MCIERR_BASE + 12;
  {$EXTERNALSYM MCIERR_MISSING_STRING_ARGUMENT}
  MCIERR_MISSING_STRING_ARGUMENT  = MCIERR_BASE + 13;
  {$EXTERNALSYM MCIERR_BAD_INTEGER}
  MCIERR_BAD_INTEGER              = MCIERR_BASE + 14;
  {$EXTERNALSYM MCIERR_PARSER_INTERNAL}
  MCIERR_PARSER_INTERNAL          = MCIERR_BASE + 15;
  {$EXTERNALSYM MCIERR_DRIVER_INTERNAL}
  MCIERR_DRIVER_INTERNAL          = MCIERR_BASE + 16;
  {$EXTERNALSYM MCIERR_MISSING_PARAMETER}
  MCIERR_MISSING_PARAMETER        = MCIERR_BASE + 17;
  {$EXTERNALSYM MCIERR_UNSUPPORTED_FUNCTION}
  MCIERR_UNSUPPORTED_FUNCTION     = MCIERR_BASE + 18;
  {$EXTERNALSYM MCIERR_FILE_NOT_FOUND}
  MCIERR_FILE_NOT_FOUND           = MCIERR_BASE + 19;
  {$EXTERNALSYM MCIERR_DEVICE_NOT_READY}
  MCIERR_DEVICE_NOT_READY         = MCIERR_BASE + 20;
  {$EXTERNALSYM MCIERR_INTERNAL}
  MCIERR_INTERNAL                 = MCIERR_BASE + 21;
  {$EXTERNALSYM MCIERR_DRIVER}
  MCIERR_DRIVER                   = MCIERR_BASE + 22;
  {$EXTERNALSYM MCIERR_CANNOT_USE_ALL}
  MCIERR_CANNOT_USE_ALL           = MCIERR_BASE + 23;
  {$EXTERNALSYM MCIERR_MULTIPLE}
  MCIERR_MULTIPLE                 = MCIERR_BASE + 24;
  {$EXTERNALSYM MCIERR_EXTENSION_NOT_FOUND}
  MCIERR_EXTENSION_NOT_FOUND      = MCIERR_BASE + 25;
  {$EXTERNALSYM MCIERR_OUTOFRANGE}
  MCIERR_OUTOFRANGE               = MCIERR_BASE + 26;
  {$EXTERNALSYM MCIERR_FLAGS_NOT_COMPATIBLE}
  MCIERR_FLAGS_NOT_COMPATIBLE     = MCIERR_BASE + 28;
  {$EXTERNALSYM MCIERR_FILE_NOT_SAVED}
  MCIERR_FILE_NOT_SAVED           = MCIERR_BASE + 30;
  {$EXTERNALSYM MCIERR_DEVICE_TYPE_REQUIRED}
  MCIERR_DEVICE_TYPE_REQUIRED     = MCIERR_BASE + 31;
  {$EXTERNALSYM MCIERR_DEVICE_LOCKED}
  MCIERR_DEVICE_LOCKED            = MCIERR_BASE + 32;
  {$EXTERNALSYM MCIERR_DUPLICATE_ALIAS}
  MCIERR_DUPLICATE_ALIAS          = MCIERR_BASE + 33;
  {$EXTERNALSYM MCIERR_BAD_CONSTANT}
  MCIERR_BAD_CONSTANT             = MCIERR_BASE + 34;
  {$EXTERNALSYM MCIERR_MUST_USE_SHAREABLE}
  MCIERR_MUST_USE_SHAREABLE       = MCIERR_BASE + 35;
  {$EXTERNALSYM MCIERR_MISSING_DEVICE_NAME}
  MCIERR_MISSING_DEVICE_NAME      = MCIERR_BASE + 36;
  {$EXTERNALSYM MCIERR_BAD_TIME_FORMAT}
  MCIERR_BAD_TIME_FORMAT          = MCIERR_BASE + 37;
  {$EXTERNALSYM MCIERR_NO_CLOSING_QUOTE}
  MCIERR_NO_CLOSING_QUOTE         = MCIERR_BASE + 38;
  {$EXTERNALSYM MCIERR_DUPLICATE_FLAGS}
  MCIERR_DUPLICATE_FLAGS          = MCIERR_BASE + 39;
  {$EXTERNALSYM MCIERR_INVALID_FILE}
  MCIERR_INVALID_FILE             = MCIERR_BASE + 40;
  {$EXTERNALSYM MCIERR_NULL_PARAMETER_BLOCK}
  MCIERR_NULL_PARAMETER_BLOCK     = MCIERR_BASE + 41;
  {$EXTERNALSYM MCIERR_UNNAMED_RESOURCE}
  MCIERR_UNNAMED_RESOURCE         = MCIERR_BASE + 42;
  {$EXTERNALSYM MCIERR_NEW_REQUIRES_ALIAS}
  MCIERR_NEW_REQUIRES_ALIAS       = MCIERR_BASE + 43;
  {$EXTERNALSYM MCIERR_NOTIFY_ON_AUTO_OPEN}
  MCIERR_NOTIFY_ON_AUTO_OPEN      = MCIERR_BASE + 44;
  {$EXTERNALSYM MCIERR_NO_ELEMENT_ALLOWED}
  MCIERR_NO_ELEMENT_ALLOWED       = MCIERR_BASE + 45;
  {$EXTERNALSYM MCIERR_NONAPPLICABLE_FUNCTION}
  MCIERR_NONAPPLICABLE_FUNCTION   = MCIERR_BASE + 46;
  {$EXTERNALSYM MCIERR_ILLEGAL_FOR_AUTO_OPEN}
  MCIERR_ILLEGAL_FOR_AUTO_OPEN    = MCIERR_BASE + 47;
  {$EXTERNALSYM MCIERR_FILENAME_REQUIRED}
  MCIERR_FILENAME_REQUIRED        = MCIERR_BASE + 48;
  {$EXTERNALSYM MCIERR_EXTRA_CHARACTERS}
  MCIERR_EXTRA_CHARACTERS         = MCIERR_BASE + 49;
  {$EXTERNALSYM MCIERR_DEVICE_NOT_INSTALLED}
  MCIERR_DEVICE_NOT_INSTALLED     = MCIERR_BASE + 50;
  {$EXTERNALSYM MCIERR_GET_CD}
  MCIERR_GET_CD                   = MCIERR_BASE + 51;
  {$EXTERNALSYM MCIERR_SET_CD}
  MCIERR_SET_CD                   = MCIERR_BASE + 52;
  {$EXTERNALSYM MCIERR_SET_DRIVE}
  MCIERR_SET_DRIVE                = MCIERR_BASE + 53;
  {$EXTERNALSYM MCIERR_DEVICE_LENGTH}
  MCIERR_DEVICE_LENGTH            = MCIERR_BASE + 54;
  {$EXTERNALSYM MCIERR_DEVICE_ORD_LENGTH}
  MCIERR_DEVICE_ORD_LENGTH        = MCIERR_BASE + 55;
  {$EXTERNALSYM MCIERR_NO_INTEGER}
  MCIERR_NO_INTEGER               = MCIERR_BASE + 56;

const
  {$EXTERNALSYM MCIERR_WAVE_OUTPUTSINUSE}
  MCIERR_WAVE_OUTPUTSINUSE        = MCIERR_BASE + 64;
  {$EXTERNALSYM MCIERR_WAVE_SETOUTPUTINUSE}
  MCIERR_WAVE_SETOUTPUTINUSE      = MCIERR_BASE + 65;
  {$EXTERNALSYM MCIERR_WAVE_INPUTSINUSE}
  MCIERR_WAVE_INPUTSINUSE         = MCIERR_BASE + 66;
  {$EXTERNALSYM MCIERR_WAVE_SETINPUTINUSE}
  MCIERR_WAVE_SETINPUTINUSE       = MCIERR_BASE + 67;
  {$EXTERNALSYM MCIERR_WAVE_OUTPUTUNSPECIFIED}
  MCIERR_WAVE_OUTPUTUNSPECIFIED   = MCIERR_BASE + 68;
  {$EXTERNALSYM MCIERR_WAVE_INPUTUNSPECIFIED}
  MCIERR_WAVE_INPUTUNSPECIFIED    = MCIERR_BASE + 69;
  {$EXTERNALSYM MCIERR_WAVE_OUTPUTSUNSUITABLE}
  MCIERR_WAVE_OUTPUTSUNSUITABLE   = MCIERR_BASE + 70;
  {$EXTERNALSYM MCIERR_WAVE_SETOUTPUTUNSUITABLE}
  MCIERR_WAVE_SETOUTPUTUNSUITABLE = MCIERR_BASE + 71;
  {$EXTERNALSYM MCIERR_WAVE_INPUTSUNSUITABLE}
  MCIERR_WAVE_INPUTSUNSUITABLE    = MCIERR_BASE + 72;
  {$EXTERNALSYM MCIERR_WAVE_SETINPUTUNSUITABLE}
  MCIERR_WAVE_SETINPUTUNSUITABLE  = MCIERR_BASE + 73;

  {$EXTERNALSYM MCIERR_SEQ_DIV_INCOMPATIBLE}
  MCIERR_SEQ_DIV_INCOMPATIBLE     = MCIERR_BASE + 80;
  {$EXTERNALSYM MCIERR_SEQ_PORT_INUSE}
  MCIERR_SEQ_PORT_INUSE           = MCIERR_BASE + 81;
  {$EXTERNALSYM MCIERR_SEQ_PORT_NONEXISTENT}
  MCIERR_SEQ_PORT_NONEXISTENT     = MCIERR_BASE + 82;
  {$EXTERNALSYM MCIERR_SEQ_PORT_MAPNODEVICE}
  MCIERR_SEQ_PORT_MAPNODEVICE     = MCIERR_BASE + 83;
  {$EXTERNALSYM MCIERR_SEQ_PORT_MISCERROR}
  MCIERR_SEQ_PORT_MISCERROR       = MCIERR_BASE + 84;
  {$EXTERNALSYM MCIERR_SEQ_TIMER}
  MCIERR_SEQ_TIMER                = MCIERR_BASE + 85;
  {$EXTERNALSYM MCIERR_SEQ_PORTUNSPECIFIED}
  MCIERR_SEQ_PORTUNSPECIFIED      = MCIERR_BASE + 86;
  {$EXTERNALSYM MCIERR_SEQ_NOMIDIPRESENT}
  MCIERR_SEQ_NOMIDIPRESENT        = MCIERR_BASE + 87;

  {$EXTERNALSYM MCIERR_NO_WINDOW}
  MCIERR_NO_WINDOW                = MCIERR_BASE + 90;
  {$EXTERNALSYM MCIERR_CREATEWINDOW}
  MCIERR_CREATEWINDOW             = MCIERR_BASE + 91;
  {$EXTERNALSYM MCIERR_FILE_READ}
  MCIERR_FILE_READ                = MCIERR_BASE + 92;
  {$EXTERNALSYM MCIERR_FILE_WRITE}
  MCIERR_FILE_WRITE               = MCIERR_BASE + 93;

  {$EXTERNALSYM MCIERR_NO_IDENTITY}
  MCIERR_NO_IDENTITY              = MCIERR_BASE + 94;

{ all custom device driver errors must be >= this value }
const
  {$EXTERNALSYM MCIERR_CUSTOM_DRIVER_BASE}
  MCIERR_CUSTOM_DRIVER_BASE       = mcierr_Base + 256;

{ MCI command message identifiers }
const
  {$EXTERNALSYM MCI_OPEN}
  MCI_OPEN       = $0803;
  {$EXTERNALSYM MCI_CLOSE}
  MCI_CLOSE      = $0804;
  {$EXTERNALSYM MCI_ESCAPE}
  MCI_ESCAPE     = $0805;
  {$EXTERNALSYM MCI_PLAY}
  MCI_PLAY       = $0806;
  {$EXTERNALSYM MCI_SEEK}
  MCI_SEEK       = $0807;
  {$EXTERNALSYM MCI_STOP}
  MCI_STOP       = $0808;
  {$EXTERNALSYM MCI_PAUSE}
  MCI_PAUSE      = $0809;
  {$EXTERNALSYM MCI_INFO}
  MCI_INFO       = $080A;
  {$EXTERNALSYM MCI_GETDEVCAPS}
  MCI_GETDEVCAPS = $080B;
  {$EXTERNALSYM MCI_SPIN}
  MCI_SPIN       = $080C;
  {$EXTERNALSYM MCI_SET}
  MCI_SET        = $080D;
  {$EXTERNALSYM MCI_STEP}
  MCI_STEP       = $080E;
  {$EXTERNALSYM MCI_RECORD}
  MCI_RECORD     = $080F;
  {$EXTERNALSYM MCI_SYSINFO}
  MCI_SYSINFO    = $0810;
  {$EXTERNALSYM MCI_BREAK}
  MCI_BREAK      = $0811;
  MCI_SOUND      = $0812;
  {$EXTERNALSYM MCI_SAVE}
  MCI_SAVE       = $0813;
  {$EXTERNALSYM MCI_STATUS}
  MCI_STATUS     = $0814;
  {$EXTERNALSYM MCI_CUE}
  MCI_CUE        = $0830;
  {$EXTERNALSYM MCI_REALIZE}
  MCI_REALIZE    = $0840;
  {$EXTERNALSYM MCI_WINDOW}
  MCI_WINDOW     = $0841;
  {$EXTERNALSYM MCI_PUT}
  MCI_PUT        = $0842;
  {$EXTERNALSYM MCI_WHERE}
  MCI_WHERE      = $0843;
  {$EXTERNALSYM MCI_FREEZE}
  MCI_FREEZE     = $0844;
  {$EXTERNALSYM MCI_UNFREEZE}
  MCI_UNFREEZE   = $0845;
  {$EXTERNALSYM MCI_LOAD}
  MCI_LOAD       = $0850;
  {$EXTERNALSYM MCI_CUT}
  MCI_CUT        = $0851;
  {$EXTERNALSYM MCI_COPY}
  MCI_COPY       = $0852;
  {$EXTERNALSYM MCI_PASTE}
  MCI_PASTE      = $0853;
  {$EXTERNALSYM MCI_UPDATE}
  MCI_UPDATE     = $0854;
  {$EXTERNALSYM MCI_RESUME}
  MCI_RESUME     = $0855;
  {$EXTERNALSYM MCI_DELETE}
  MCI_DELETE     = $0856;

{ all custom MCI command messages must be >= this value }
const
  {$EXTERNALSYM MCI_USER_MESSAGES}
  MCI_USER_MESSAGES               = $400 + drv_MCI_First;
  {$EXTERNALSYM MCI_LAST}
  MCI_LAST                        = $0FFF;

{ device ID for "all devices" }
const
  {$EXTERNALSYM MCI_ALL_DEVICE_ID}
  MCI_ALL_DEVICE_ID               = UINT(-1);

{ constants for predefined MCI device types }
const
  {$EXTERNALSYM MCI_DEVTYPE_VCR}
  MCI_DEVTYPE_VCR                 = MCI_STRING_OFFSET + 1;
  {$EXTERNALSYM MCI_DEVTYPE_VIDEODISC}
  MCI_DEVTYPE_VIDEODISC           = MCI_STRING_OFFSET + 2;
  {$EXTERNALSYM MCI_DEVTYPE_OVERLAY}
  MCI_DEVTYPE_OVERLAY             = MCI_STRING_OFFSET + 3;
  {$EXTERNALSYM MCI_DEVTYPE_CD_AUDIO}
  MCI_DEVTYPE_CD_AUDIO            = MCI_STRING_OFFSET + 4;
  {$EXTERNALSYM MCI_DEVTYPE_DAT}
  MCI_DEVTYPE_DAT                 = MCI_STRING_OFFSET + 5;
  {$EXTERNALSYM MCI_DEVTYPE_SCANNER}
  MCI_DEVTYPE_SCANNER             = MCI_STRING_OFFSET + 6;
  {$EXTERNALSYM MCI_DEVTYPE_ANIMATION}
  MCI_DEVTYPE_ANIMATION           = MCI_STRING_OFFSET + 7;
  {$EXTERNALSYM MCI_DEVTYPE_DIGITAL_VIDEO}
  MCI_DEVTYPE_DIGITAL_VIDEO       = MCI_STRING_OFFSET + 8;
  {$EXTERNALSYM MCI_DEVTYPE_OTHER}
  MCI_DEVTYPE_OTHER               = MCI_STRING_OFFSET + 9;
  {$EXTERNALSYM MCI_DEVTYPE_WAVEFORM_AUDIO}
  MCI_DEVTYPE_WAVEFORM_AUDIO      = MCI_STRING_OFFSET + 10;
  {$EXTERNALSYM MCI_DEVTYPE_SEQUENCER}
  MCI_DEVTYPE_SEQUENCER           = MCI_STRING_OFFSET + 11;

  {$EXTERNALSYM MCI_DEVTYPE_FIRST}
  MCI_DEVTYPE_FIRST              = MCI_DEVTYPE_VCR;
  {$EXTERNALSYM MCI_DEVTYPE_LAST}
  MCI_DEVTYPE_LAST               = MCI_DEVTYPE_SEQUENCER;

  {$EXTERNALSYM MCI_DEVTYPE_FIRST_USER}
  MCI_DEVTYPE_FIRST_USER         = $1000;

{ return values for 'status mode' command }
const
  {$EXTERNALSYM MCI_MODE_NOT_READY}
  MCI_MODE_NOT_READY              = MCI_STRING_OFFSET + 12;
  {$EXTERNALSYM MCI_MODE_STOP}
  MCI_MODE_STOP                   = MCI_STRING_OFFSET + 13;
  {$EXTERNALSYM MCI_MODE_PLAY}
  MCI_MODE_PLAY                   = MCI_STRING_OFFSET + 14;
  {$EXTERNALSYM MCI_MODE_RECORD}
  MCI_MODE_RECORD                 = MCI_STRING_OFFSET + 15;
  {$EXTERNALSYM MCI_MODE_SEEK}
  MCI_MODE_SEEK                   = MCI_STRING_OFFSET + 16;
  {$EXTERNALSYM MCI_MODE_PAUSE}
  MCI_MODE_PAUSE                  = MCI_STRING_OFFSET + 17;
  {$EXTERNALSYM MCI_MODE_OPEN}
  MCI_MODE_OPEN                   = MCI_STRING_OFFSET + 18;

{ constants used in 'set time format' and 'status time format' commands }
const
  {$EXTERNALSYM MCI_FORMAT_MILLISECONDS}
  MCI_FORMAT_MILLISECONDS         = 0;
  {$EXTERNALSYM MCI_FORMAT_HMS}
  MCI_FORMAT_HMS                  = 1;
  {$EXTERNALSYM MCI_FORMAT_MSF}
  MCI_FORMAT_MSF                  = 2;
  {$EXTERNALSYM MCI_FORMAT_FRAMES}
  MCI_FORMAT_FRAMES               = 3;
  {$EXTERNALSYM MCI_FORMAT_SMPTE_24}
  MCI_FORMAT_SMPTE_24             = 4;
  {$EXTERNALSYM MCI_FORMAT_SMPTE_25}
  MCI_FORMAT_SMPTE_25             = 5;
  {$EXTERNALSYM MCI_FORMAT_SMPTE_30}
  MCI_FORMAT_SMPTE_30             = 6;
  {$EXTERNALSYM MCI_FORMAT_SMPTE_30DROP}
  MCI_FORMAT_SMPTE_30DROP         = 7;
  {$EXTERNALSYM MCI_FORMAT_BYTES}
  MCI_FORMAT_BYTES                = 8;
  {$EXTERNALSYM MCI_FORMAT_SAMPLES}
  MCI_FORMAT_SAMPLES              = 9;
  {$EXTERNALSYM MCI_FORMAT_TMSF}
  MCI_FORMAT_TMSF                 = 10;

{ MCI time format conversion macros }

function mci_MSF_Minute(msf: Longint): Byte;
{$EXTERNALSYM mci_MSF_Minute}
function mci_MSF_Second(msf: Longint): Byte;
{$EXTERNALSYM mci_MSF_Second}
function mci_MSF_Frame(msf: Longint): Byte;
{$EXTERNALSYM mci_MSF_Frame}
function mci_Make_MSF(m, s, f: Byte): Longint;
{$EXTERNALSYM mci_Make_MSF}
function mci_TMSF_Track(tmsf: Longint): Byte;
{$EXTERNALSYM mci_TMSF_Track}
function mci_TMSF_Minute(tmsf: Longint): Byte;
{$EXTERNALSYM mci_TMSF_Minute}
function mci_TMSF_Second(tmsf: Longint): Byte;
{$EXTERNALSYM mci_TMSF_Second}
function mci_TMSF_Frame(tmsf: Longint): Byte;
{$EXTERNALSYM mci_TMSF_Frame}
function mci_Make_TMSF(t, m, s, f: Byte): Longint;
{$EXTERNALSYM mci_Make_TMSF}
function mci_HMS_Hour(hms: Longint): Byte;
{$EXTERNALSYM mci_HMS_Hour}
function mci_HMS_Minute(hms: Longint): Byte;
{$EXTERNALSYM mci_HMS_Minute}
function mci_HMS_Second(hms: Longint): Byte;
{$EXTERNALSYM mci_HMS_Second}
function mci_Make_HMS(h, m, s: Byte): Longint;
{$EXTERNALSYM mci_Make_HMS}

{ flags for wParam of MM_MCINOTIFY message }
const
  {$EXTERNALSYM MCI_NOTIFY_SUCCESSFUL}
  MCI_NOTIFY_SUCCESSFUL           = $0001;
  {$EXTERNALSYM MCI_NOTIFY_SUPERSEDED}
  MCI_NOTIFY_SUPERSEDED           = $0002;
  {$EXTERNALSYM MCI_NOTIFY_ABORTED}
  MCI_NOTIFY_ABORTED              = $0004;
  {$EXTERNALSYM MCI_NOTIFY_FAILURE}
  MCI_NOTIFY_FAILURE              = $0008;

{ common flags for dwFlags parameter of MCI command messages }
const
  {$EXTERNALSYM MCI_NOTIFY}
  MCI_NOTIFY                      = $00000001;
  {$EXTERNALSYM MCI_WAIT}
  MCI_WAIT                        = $00000002;
  {$EXTERNALSYM MCI_FROM}
  MCI_FROM                        = $00000004;
  {$EXTERNALSYM MCI_TO}
  MCI_TO                          = $00000008;
  {$EXTERNALSYM MCI_TRACK}
  MCI_TRACK                       = $00000010;

{ flags for dwFlags parameter of MCI_OPEN command message }
const
  {$EXTERNALSYM MCI_OPEN_SHAREABLE}
  MCI_OPEN_SHAREABLE              = $00000100;
  {$EXTERNALSYM MCI_OPEN_ELEMENT}
  MCI_OPEN_ELEMENT                = $00000200;
  {$EXTERNALSYM MCI_OPEN_ALIAS}
  MCI_OPEN_ALIAS                  = $00000400;
  {$EXTERNALSYM MCI_OPEN_ELEMENT_ID}
  MCI_OPEN_ELEMENT_ID             = $00000800;
  {$EXTERNALSYM MCI_OPEN_TYPE_ID}
  MCI_OPEN_TYPE_ID                = $00001000;
  {$EXTERNALSYM MCI_OPEN_TYPE}
  MCI_OPEN_TYPE                   = $00002000;

{ flags for dwFlags parameter of MCI_SEEK command message }
const
  {$EXTERNALSYM MCI_SEEK_TO_START}
  MCI_SEEK_TO_START               = $00000100;
  {$EXTERNALSYM MCI_SEEK_TO_END}
  MCI_SEEK_TO_END                 = $00000200;

{ flags for dwFlags parameter of MCI_STATUS command message }
const
  {$EXTERNALSYM MCI_STATUS_ITEM}
  MCI_STATUS_ITEM                 = $00000100;
  {$EXTERNALSYM MCI_STATUS_START}
  MCI_STATUS_START                = $00000200;

{ flags for dwItem field of the MCI_STATUS_PARMS parameter block }
const
  {$EXTERNALSYM MCI_STATUS_LENGTH}
  MCI_STATUS_LENGTH               = $00000001;
  {$EXTERNALSYM MCI_STATUS_POSITION}
  MCI_STATUS_POSITION             = $00000002;
  {$EXTERNALSYM MCI_STATUS_NUMBER_OF_TRACKS}
  MCI_STATUS_NUMBER_OF_TRACKS     = $00000003;
  {$EXTERNALSYM MCI_STATUS_MODE}
  MCI_STATUS_MODE                 = $00000004;
  {$EXTERNALSYM MCI_STATUS_MEDIA_PRESENT}
  MCI_STATUS_MEDIA_PRESENT        = $00000005;
  {$EXTERNALSYM MCI_STATUS_TIME_FORMAT}
  MCI_STATUS_TIME_FORMAT          = $00000006;
  {$EXTERNALSYM MCI_STATUS_READY}
  MCI_STATUS_READY                = $00000007;
  {$EXTERNALSYM MCI_STATUS_CURRENT_TRACK}
  MCI_STATUS_CURRENT_TRACK        = $00000008;

{ flags for dwFlags parameter of MCI_INFO command message }
const
  {$EXTERNALSYM MCI_INFO_PRODUCT}
  MCI_INFO_PRODUCT                = $00000100;
  {$EXTERNALSYM MCI_INFO_FILE}
  MCI_INFO_FILE                   = $00000200;
  {$EXTERNALSYM MCI_INFO_MEDIA_UPC}
  MCI_INFO_MEDIA_UPC              = $00000400;
  {$EXTERNALSYM MCI_INFO_MEDIA_IDENTITY}
  MCI_INFO_MEDIA_IDENTITY         = $00000800;
  {$EXTERNALSYM MCI_INFO_NAME}
  MCI_INFO_NAME                   = $00001000;
  {$EXTERNALSYM MCI_INFO_COPYRIGHT}
  MCI_INFO_COPYRIGHT              = $00002000;

{ flags for dwFlags parameter of MCI_GETDEVCAPS command message }
const
  {$EXTERNALSYM MCI_GETDEVCAPS_ITEM}
  MCI_GETDEVCAPS_ITEM             = $00000100;

{ flags for dwItem field of the MCI_GETDEVCAPS_PARMS parameter block }
const
  {$EXTERNALSYM MCI_GETDEVCAPS_CAN_RECORD}
  MCI_GETDEVCAPS_CAN_RECORD       = $00000001;
  {$EXTERNALSYM MCI_GETDEVCAPS_HAS_AUDIO}
  MCI_GETDEVCAPS_HAS_AUDIO        = $00000002;
  {$EXTERNALSYM MCI_GETDEVCAPS_HAS_VIDEO}
  MCI_GETDEVCAPS_HAS_VIDEO        = $00000003;
  {$EXTERNALSYM MCI_GETDEVCAPS_DEVICE_TYPE}
  MCI_GETDEVCAPS_DEVICE_TYPE      = $00000004;
  {$EXTERNALSYM MCI_GETDEVCAPS_USES_FILES}
  MCI_GETDEVCAPS_USES_FILES       = $00000005;
  {$EXTERNALSYM MCI_GETDEVCAPS_COMPOUND_DEVICE}
  MCI_GETDEVCAPS_COMPOUND_DEVICE  = $00000006;
  {$EXTERNALSYM MCI_GETDEVCAPS_CAN_EJECT}
  MCI_GETDEVCAPS_CAN_EJECT        = $00000007;
  {$EXTERNALSYM MCI_GETDEVCAPS_CAN_PLAY}
  MCI_GETDEVCAPS_CAN_PLAY         = $00000008;
  {$EXTERNALSYM MCI_GETDEVCAPS_CAN_SAVE}
  MCI_GETDEVCAPS_CAN_SAVE         = $00000009;

{ flags for dwFlags parameter of MCI_SYSINFO command message }
const
  {$EXTERNALSYM MCI_SYSINFO_QUANTITY}
  MCI_SYSINFO_QUANTITY            = $00000100;
  {$EXTERNALSYM MCI_SYSINFO_OPEN}
  MCI_SYSINFO_OPEN                = $00000200;
  {$EXTERNALSYM MCI_SYSINFO_NAME}
  MCI_SYSINFO_NAME                = $00000400;
  {$EXTERNALSYM MCI_SYSINFO_INSTALLNAME}
  MCI_SYSINFO_INSTALLNAME         = $00000800;

{ flags for dwFlags parameter of MCI_SET command message }
const
  {$EXTERNALSYM MCI_SET_DOOR_OPEN}
  MCI_SET_DOOR_OPEN               = $00000100;
  {$EXTERNALSYM MCI_SET_DOOR_CLOSED}
  MCI_SET_DOOR_CLOSED             = $00000200;
  {$EXTERNALSYM MCI_SET_TIME_FORMAT}
  MCI_SET_TIME_FORMAT             = $00000400;
  {$EXTERNALSYM MCI_SET_AUDIO}
  MCI_SET_AUDIO                   = $00000800;
  {$EXTERNALSYM MCI_SET_VIDEO}
  MCI_SET_VIDEO                   = $00001000;
  {$EXTERNALSYM MCI_SET_ON}
  MCI_SET_ON                      = $00002000;
  {$EXTERNALSYM MCI_SET_OFF}
  MCI_SET_OFF                     = $00004000;

{ flags for dwAudio field of MCI_SET_PARMS or MCI_SEQ_SET_PARMS }
const
  {$EXTERNALSYM MCI_SET_AUDIO_ALL}
  MCI_SET_AUDIO_ALL               = $00000000;
  {$EXTERNALSYM MCI_SET_AUDIO_LEFT}
  MCI_SET_AUDIO_LEFT              = $00000001;
  {$EXTERNALSYM MCI_SET_AUDIO_RIGHT}
  MCI_SET_AUDIO_RIGHT             = $00000002;

{ flags for dwFlags parameter of MCI_BREAK command message }
const
  {$EXTERNALSYM MCI_BREAK_KEY}
  MCI_BREAK_KEY                   = $00000100;
  {$EXTERNALSYM MCI_BREAK_HWND}
  MCI_BREAK_HWND                  = $00000200;
  {$EXTERNALSYM MCI_BREAK_OFF}
  MCI_BREAK_OFF                   = $00000400;

{ flags for dwFlags parameter of MCI_RECORD command message }
const
  {$EXTERNALSYM MCI_RECORD_INSERT}
  MCI_RECORD_INSERT               = $00000100;
  {$EXTERNALSYM MCI_RECORD_OVERWRITE}
  MCI_RECORD_OVERWRITE            = $00000200;

{ flags for dwFlags parameter of MCI_SOUND command message }
const
  MCI_SOUND_NAME                  = $00000100;

{ flags for dwFlags parameter of MCI_SAVE command message }
const
  {$EXTERNALSYM MCI_SAVE_FILE}
  MCI_SAVE_FILE                   = $00000100;

{ flags for dwFlags parameter of MCI_LOAD command message }
const
  {$EXTERNALSYM MCI_LOAD_FILE}
  MCI_LOAD_FILE                   = $00000100;

{ generic parameter block for MCI command messages with no special parameters }
type
  PMCI_Generic_Parms = ^TMCI_Generic_Parms;
  {$EXTERNALSYM tagMCI_GENERIC_PARMS}
  tagMCI_GENERIC_PARMS = record
    dwCallback: DWORD_PTR;
  end;
  TMCI_Generic_Parms = tagMCI_GENERIC_PARMS;
  {$EXTERNALSYM MCI_GENERIC_PARMS}
  MCI_GENERIC_PARMS = tagMCI_GENERIC_PARMS;

{ parameter block for MCI_OPEN command message }
type
  PMCI_Open_ParmsA = ^TMCI_Open_ParmsA;
  PMCI_Open_ParmsW = ^TMCI_Open_ParmsW;
  PMCI_Open_Parms = PMCI_Open_ParmsW;
  {$EXTERNALSYM tagMCI_OPEN_PARMSA}
  tagMCI_OPEN_PARMSA = record
    dwCallback: DWORD_PTR;
    wDeviceID: MCIDEVICEID;
    lpstrDeviceType: LPSTR;
    lpstrElementName: LPSTR;
    lpstrAlias: LPSTR;
  end;
  {$EXTERNALSYM tagMCI_OPEN_PARMSW}
  tagMCI_OPEN_PARMSW = record
    dwCallback: DWORD_PTR;
    wDeviceID: MCIDEVICEID;
    lpstrDeviceType: LPWSTR;
    lpstrElementName: LPWSTR;
    lpstrAlias: LPWSTR;
  end;
  {$EXTERNALSYM tagMCI_OPEN_PARMS}
  tagMCI_OPEN_PARMS = tagMCI_OPEN_PARMSW;
  TMCI_Open_ParmsA = tagMCI_OPEN_PARMSA;
  TMCI_Open_ParmsW = tagMCI_OPEN_PARMSW;
  TMCI_Open_Parms = TMCI_Open_ParmsW;
  {$EXTERNALSYM MCI_OPEN_PARMSA}
  MCI_OPEN_PARMSA = tagMCI_OPEN_PARMSA;
  {$EXTERNALSYM MCI_OPEN_PARMSW}
  MCI_OPEN_PARMSW = tagMCI_OPEN_PARMSW;
  {$EXTERNALSYM MCI_OPEN_PARMS}
  MCI_OPEN_PARMS = MCI_OPEN_PARMSW;

{ parameter block for MCI_PLAY command message }
type
  PMCI_Play_Parms = ^TMCI_Play_Parms;
  {$EXTERNALSYM tagMCI_PLAY_PARMS}
  tagMCI_PLAY_PARMS = record
    dwCallback: DWORD_PTR;
    dwFrom: DWORD;
    dwTo: DWORD;
  end;
  TMCI_Play_Parms = tagMCI_PLAY_PARMS;
  {$EXTERNALSYM MCI_PLAY_PARMS}
  MCI_PLAY_PARMS = tagMCI_PLAY_PARMS;

{ parameter block for MCI_SEEK command message }
type
  PMCI_Seek_Parms = ^TMCI_Seek_Parms;
  {$EXTERNALSYM tagMCI_SEEK_PARMS}
  tagMCI_SEEK_PARMS = record
    dwCallback: DWORD_PTR;
    dwTo: DWORD;
  end;
  TMCI_Seek_Parms = tagMCI_SEEK_PARMS;
  {$EXTERNALSYM MCI_SEEK_PARMS}
  MCI_SEEK_PARMS = tagMCI_SEEK_PARMS;


{ parameter block for MCI_STATUS command message }
type
  PMCI_Status_Parms = ^TMCI_Status_Parms;
  {$EXTERNALSYM tagMCI_STATUS_PARMS}
  tagMCI_STATUS_PARMS = record
    dwCallback: DWORD_PTR;
    dwReturn: DWORD_PTR;
    dwItem: DWORD;
    dwTrack: DWORD;
  end;
  TMCI_Status_Parms = tagMCI_STATUS_PARMS;
  {$EXTERNALSYM MCI_STATUS_PARMS}
  MCI_STATUS_PARMS = tagMCI_STATUS_PARMS;

{ parameter block for MCI_INFO command message }
type
  PMCI_Info_ParmsA = ^TMCI_Info_ParmsA;
  PMCI_Info_ParmsW = ^TMCI_Info_ParmsW;
  PMCI_Info_Parms = PMCI_Info_ParmsW;
  {$EXTERNALSYM tagMCI_INFO_PARMSA}
  tagMCI_INFO_PARMSA = record
    dwCallback: DWORD_PTR;
    lpstrReturn: LPSTR;
    dwRetSize: DWORD;
  end;
  {$EXTERNALSYM tagMCI_INFO_PARMSW}
  tagMCI_INFO_PARMSW = record
    dwCallback: DWORD_PTR;
    lpstrReturn: LPWSTR;
    dwRetSize: DWORD;
  end;
  {$EXTERNALSYM tagMCI_INFO_PARMS}
  tagMCI_INFO_PARMS = tagMCI_INFO_PARMSW;
  TMCI_Info_ParmsA = tagMCI_INFO_PARMSA;
  TMCI_Info_ParmsW = tagMCI_INFO_PARMSW;
  TMCI_Info_Parms = TMCI_Info_ParmsW;
  {$EXTERNALSYM MCI_INFO_PARMSA}
  MCI_INFO_PARMSA = tagMCI_INFO_PARMSA;
  {$EXTERNALSYM MCI_INFO_PARMSW}
  MCI_INFO_PARMSW = tagMCI_INFO_PARMSW;
  {$EXTERNALSYM MCI_INFO_PARMS}
  MCI_INFO_PARMS = MCI_INFO_PARMSW;

{ parameter block for MCI_GETDEVCAPS command message }
type
  PMCI_GetDevCaps_Parms = ^TMCI_GetDevCaps_Parms;
  {$EXTERNALSYM tagMCI_GETDEVCAPS_PARMS}
  tagMCI_GETDEVCAPS_PARMS = record
    dwCallback: DWORD_PTR;
    dwReturn: DWORD;
    dwItem: DWORD;
  end;
  TMCI_GetDevCaps_Parms = tagMCI_GETDEVCAPS_PARMS;
  {$EXTERNALSYM MCI_GETDEVCAPS_PARMS}
  MCI_GETDEVCAPS_PARMS = tagMCI_GETDEVCAPS_PARMS;

{ parameter block for MCI_SYSINFO command message }
type
  PMCI_SysInfo_ParmsA = ^TMCI_SysInfo_ParmsA;
  PMCI_SysInfo_ParmsW = ^TMCI_SysInfo_ParmsW;
  PMCI_SysInfo_Parms = PMCI_SysInfo_ParmsW;
  {$EXTERNALSYM tagMCI_SYSINFO_PARMSA}
  tagMCI_SYSINFO_PARMSA = record
    dwCallback: DWORD_PTR;
    lpstrReturn: LPSTR;
    dwRetSize: DWORD;
    dwNumber: DWORD;
    wDeviceType: UINT;
  end;
  {$EXTERNALSYM tagMCI_SYSINFO_PARMSW}
  tagMCI_SYSINFO_PARMSW = record
    dwCallback: DWORD_PTR;
    lpstrReturn: LPWSTR;
    dwRetSize: DWORD;
    dwNumber: DWORD;
    wDeviceType: UINT;
  end;
  {$EXTERNALSYM tagMCI_SYSINFO_PARMS}
  tagMCI_SYSINFO_PARMS = tagMCI_SYSINFO_PARMSW;
  TMCI_SysInfo_ParmsA = tagMCI_SYSINFO_PARMSA;
  TMCI_SysInfo_ParmsW = tagMCI_SYSINFO_PARMSW;
  TMCI_SysInfo_Parms = TMCI_SysInfo_ParmsW;
  {$EXTERNALSYM MCI_SYSINFO_PARMSA}
  MCI_SYSINFO_PARMSA = tagMCI_SYSINFO_PARMSA;
  {$EXTERNALSYM MCI_SYSINFO_PARMSW}
  MCI_SYSINFO_PARMSW = tagMCI_SYSINFO_PARMSW;
  {$EXTERNALSYM MCI_SYSINFO_PARMS}
  MCI_SYSINFO_PARMS = MCI_SYSINFO_PARMSW;

{ parameter block for MCI_SET command message }
type
  PMCI_Set_Parms = ^TMCI_Set_Parms;
  {$EXTERNALSYM tagMCI_SET_PARMS}
  tagMCI_SET_PARMS = record
    dwCallback: DWORD_PTR;
    dwTimeFormat: DWORD;
    dwAudio: DWORD;
  end;
  TMCI_Set_Parms = tagMCI_SET_PARMS;
  {$EXTERNALSYM MCI_SET_PARMS}
  MCI_SET_PARMS = tagMCI_SET_PARMS;


{ parameter block for MCI_BREAK command message }
type
  PMCI_Break_Parms = ^TMCI_BReak_Parms;
  {$EXTERNALSYM tagMCI_BREAK_PARMS}
  tagMCI_BREAK_PARMS = record
    dwCallback: DWORD_PTR;
    nVirtKey: Integer;
    hWndBreak: HWND;
  end;
  TMCI_BReak_Parms = tagMCI_BREAK_PARMS;
  {$EXTERNALSYM MCI_BREAK_PARMS}
  MCI_BREAK_PARMS = tagMCI_BREAK_PARMS;

{ parameter block for MCI_SOUND command message }
type
  PMCI_Sound_Parms = ^TMCI_Sound_Parms;
  TMCI_Sound_Parms = record
    dwCallback: Longint;
    lpstrSoundName: PChar;
  end;

{ parameter block for MCI_SAVE command message }
type
  PMCI_Save_ParmsA = ^MCI_SAVE_PARMSA;
  PMCI_Save_ParmsW = ^MCI_SAVE_PARMSW;
  PMCI_Save_Parms = PMCI_Save_ParmsW;
  MCI_SAVE_PARMSA = record
    dwCallback: DWORD_PTR;
    lpfilename: LPCSTR;
  end;
  MCI_SAVE_PARMSW = record
    dwCallback: DWORD_PTR;
    lpfilename: LPCWSTR;
  end;
  MCI_SAVE_PARMS = MCI_SAVE_PARMSW;
  TMCI_SaveParmsA = MCI_SAVE_PARMSA;
  LPMCI_SAVE_PARMSA = PMCI_Save_ParmsA;
  TMCI_SaveParmsW = MCI_SAVE_PARMSW;
  LPMCI_SAVE_PARMSW = PMCI_Save_ParmsW;
  TMCI_SaveParms = TMCI_SaveParmsW;

{ parameter block for MCI_LOAD command message }
type
  PMCI_Load_ParmsA = ^TMCI_Load_ParmsA;
  PMCI_Load_ParmsW = ^TMCI_Load_ParmsW;
  PMCI_Load_Parms = PMCI_Load_ParmsW;
  {$EXTERNALSYM tagMCI_LOAD_PARMSA}
  tagMCI_LOAD_PARMSA = record
    dwCallback: DWORD_PTR;
    lpfilename: LPSTR;
  end;
  {$EXTERNALSYM tagMCI_LOAD_PARMSW}
  tagMCI_LOAD_PARMSW = record
    dwCallback: DWORD_PTR;
    lpfilename: LPWSTR;
  end;
  {$EXTERNALSYM tagMCI_LOAD_PARMS}
  tagMCI_LOAD_PARMS = tagMCI_LOAD_PARMSW;
  TMCI_Load_ParmsA = tagMCI_LOAD_PARMSA;
  TMCI_Load_ParmsW = tagMCI_LOAD_PARMSW;
  TMCI_Load_Parms = TMCI_Load_ParmsW;
  {$EXTERNALSYM MCI_LOAD_PARMSA}
  MCI_LOAD_PARMSA = tagMCI_LOAD_PARMSA;
  {$EXTERNALSYM MCI_LOAD_PARMSW}
  MCI_LOAD_PARMSW = tagMCI_LOAD_PARMSW;
  {$EXTERNALSYM MCI_LOAD_PARMS}
  MCI_LOAD_PARMS = MCI_LOAD_PARMSW;

{ parameter block for MCI_RECORD command message }
type
  PMCI_Record_Parms = ^TMCI_Record_Parms;
  {$EXTERNALSYM tagMCI_RECORD_PARMS}
  tagMCI_RECORD_PARMS = record
    dwCallback: DWORD_PTR;
    dwFrom: DWORD;
    dwTo: DWORD;
  end;
  TMCI_Record_Parms = tagMCI_RECORD_PARMS;
  {$EXTERNALSYM MCI_RECORD_PARMS}
  MCI_RECORD_PARMS = tagMCI_RECORD_PARMS;


{ MCI extensions for videodisc devices }

{ flag for dwReturn field of MCI_STATUS_PARMS }
{ MCI_STATUS command, (dwItem == MCI_STATUS_MODE) }
const
  {$EXTERNALSYM MCI_VD_MODE_PARK}
  MCI_VD_MODE_PARK                = MCI_VD_OFFSET + 1;

{ flag for dwReturn field of MCI_STATUS_PARMS }
{ MCI_STATUS command, (dwItem == MCI_VD_STATUS_MEDIA_TYPE) }
const
  {$EXTERNALSYM MCI_VD_MEDIA_CLV}
  MCI_VD_MEDIA_CLV                = MCI_VD_OFFSET + 2;
  {$EXTERNALSYM MCI_VD_MEDIA_CAV}
  MCI_VD_MEDIA_CAV                = MCI_VD_OFFSET + 3;
  {$EXTERNALSYM MCI_VD_MEDIA_OTHER}
  MCI_VD_MEDIA_OTHER              = MCI_VD_OFFSET + 4;

const
  {$EXTERNALSYM MCI_VD_FORMAT_TRACK}
  MCI_VD_FORMAT_TRACK             = $4001;

{ flags for dwFlags parameter of MCI_PLAY command message }
const
  {$EXTERNALSYM MCI_VD_PLAY_REVERSE}
  MCI_VD_PLAY_REVERSE             = $00010000;
  {$EXTERNALSYM MCI_VD_PLAY_FAST}
  MCI_VD_PLAY_FAST                = $00020000;
  {$EXTERNALSYM MCI_VD_PLAY_SPEED}
  MCI_VD_PLAY_SPEED               = $00040000;
  {$EXTERNALSYM MCI_VD_PLAY_SCAN}
  MCI_VD_PLAY_SCAN                = $00080000;
  {$EXTERNALSYM MCI_VD_PLAY_SLOW}
  MCI_VD_PLAY_SLOW                = $00100000;

{ flag for dwFlags parameter of MCI_SEEK command message }
const
  {$EXTERNALSYM MCI_VD_SEEK_REVERSE}
  MCI_VD_SEEK_REVERSE             = $00010000;

{ flags for dwItem field of MCI_STATUS_PARMS parameter block }
const
  {$EXTERNALSYM MCI_VD_STATUS_SPEED}
  MCI_VD_STATUS_SPEED             = $00004002;
  {$EXTERNALSYM MCI_VD_STATUS_FORWARD}
  MCI_VD_STATUS_FORWARD           = $00004003;
  {$EXTERNALSYM MCI_VD_STATUS_MEDIA_TYPE}
  MCI_VD_STATUS_MEDIA_TYPE        = $00004004;
  {$EXTERNALSYM MCI_VD_STATUS_SIDE}
  MCI_VD_STATUS_SIDE              = $00004005;
  {$EXTERNALSYM MCI_VD_STATUS_DISC_SIZE}
  MCI_VD_STATUS_DISC_SIZE         = $00004006;

{ flags for dwFlags parameter of MCI_GETDEVCAPS command message }
const
  {$EXTERNALSYM MCI_VD_GETDEVCAPS_CLV}
  MCI_VD_GETDEVCAPS_CLV           = $00010000;
  {$EXTERNALSYM MCI_VD_GETDEVCAPS_CAV}
  MCI_VD_GETDEVCAPS_CAV           = $00020000;

  {$EXTERNALSYM MCI_VD_SPIN_UP}
  MCI_VD_SPIN_UP                  = $00010000;
  {$EXTERNALSYM MCI_VD_SPIN_DOWN}
  MCI_VD_SPIN_DOWN                = $00020000;

{ flags for dwItem field of MCI_GETDEVCAPS_PARMS parameter block }
const
  {$EXTERNALSYM MCI_VD_GETDEVCAPS_CAN_REVERSE}
  MCI_VD_GETDEVCAPS_CAN_REVERSE   = $00004002;
  {$EXTERNALSYM MCI_VD_GETDEVCAPS_FAST_RATE}
  MCI_VD_GETDEVCAPS_FAST_RATE     = $00004003;
  {$EXTERNALSYM MCI_VD_GETDEVCAPS_SLOW_RATE}
  MCI_VD_GETDEVCAPS_SLOW_RATE     = $00004004;
  {$EXTERNALSYM MCI_VD_GETDEVCAPS_NORMAL_RATE}
  MCI_VD_GETDEVCAPS_NORMAL_RATE   = $00004005;

{ flags for the dwFlags parameter of MCI_STEP command message }
const
  {$EXTERNALSYM MCI_VD_STEP_FRAMES}
  MCI_VD_STEP_FRAMES              = $00010000;
  {$EXTERNALSYM MCI_VD_STEP_REVERSE}
  MCI_VD_STEP_REVERSE             = $00020000;

{ flag for the MCI_ESCAPE command message }
const
  {$EXTERNALSYM MCI_VD_ESCAPE_STRING}
  MCI_VD_ESCAPE_STRING            = $00000100;

{ parameter block for MCI_PLAY command message }
type
  PMCI_VD_Play_Parms = ^TMCI_VD_Play_Parms;
  {$EXTERNALSYM tagMCI_VD_PLAY_PARMS}
  tagMCI_VD_PLAY_PARMS = record
    dwCallback: DWORD_PTR;
    dwFrom: DWORD;
    dwTo: DWORD;
    dwSpeed: DWORD;
  end;
  TMCI_VD_Play_Parms = tagMCI_VD_PLAY_PARMS;
  {$EXTERNALSYM MCI_VD_PLAY_PARMS}
  MCI_VD_PLAY_PARMS = tagMCI_VD_PLAY_PARMS;

{ parameter block for MCI_STEP command message }
type
  PMCI_VD_Step_Parms = ^TMCI_VD_Step_Parms;
  {$EXTERNALSYM tagMCI_VD_STEP_PARMS}
  tagMCI_VD_STEP_PARMS = record
    dwCallback: DWORD_PTR;
    dwFrames: DWORD;
  end;
  TMCI_VD_Step_Parms = tagMCI_VD_STEP_PARMS;
  {$EXTERNALSYM MCI_VD_STEP_PARMS}
  MCI_VD_STEP_PARMS = tagMCI_VD_STEP_PARMS;

{ parameter block for MCI_ESCAPE command message }
type
  PMCI_VD_Escape_ParmsA = ^TMCI_VD_Escape_ParmsA;
  PMCI_VD_Escape_ParmsW = ^TMCI_VD_Escape_ParmsW;
  PMCI_VD_Escape_Parms = PMCI_VD_Escape_ParmsW;
  {$EXTERNALSYM tagMCI_VD_ESCAPE_PARMSA}
  tagMCI_VD_ESCAPE_PARMSA = record
    dwCallback: DWORD_PTR;
    lpstrCommand: LPCSTR;
  end;
  {$EXTERNALSYM tagMCI_VD_ESCAPE_PARMSW}
  tagMCI_VD_ESCAPE_PARMSW = record
    dwCallback: DWORD_PTR;
    lpstrCommand: LPCWSTR;
  end;
  {$EXTERNALSYM tagMCI_VD_ESCAPE_PARMS}
  tagMCI_VD_ESCAPE_PARMS = tagMCI_VD_ESCAPE_PARMSW;
  TMCI_VD_Escape_ParmsA = tagMCI_VD_ESCAPE_PARMSA;
  TMCI_VD_Escape_ParmsW = tagMCI_VD_ESCAPE_PARMSW;
  TMCI_VD_Escape_Parms = TMCI_VD_Escape_ParmsW;
  {$EXTERNALSYM MCI_VD_ESCAPE_PARMSA}
  MCI_VD_ESCAPE_PARMSA = tagMCI_VD_ESCAPE_PARMSA;
  {$EXTERNALSYM MCI_VD_ESCAPE_PARMSW}
  MCI_VD_ESCAPE_PARMSW = tagMCI_VD_ESCAPE_PARMSW;
  {$EXTERNALSYM MCI_VD_ESCAPE_PARMS}
  MCI_VD_ESCAPE_PARMS = MCI_VD_ESCAPE_PARMSW;

{ MCI extensions for CD audio devices }

{ flags for the dwItem field of the MCI_STATUS_PARMS parameter block }
const
  {$EXTERNALSYM MCI_CDA_STATUS_TYPE_TRACK}
  MCI_CDA_STATUS_TYPE_TRACK       = $00004001;

{ flags for the dwReturn field of MCI_STATUS_PARMS parameter block }
{ MCI_STATUS command, (dwItem == MCI_CDA_STATUS_TYPE_TRACK) }
  {$EXTERNALSYM MCI_CDA_TRACK_AUDIO}
  MCI_CDA_TRACK_AUDIO             = MCI_CD_OFFSET + 0;
  {$EXTERNALSYM MCI_CDA_TRACK_OTHER}
  MCI_CDA_TRACK_OTHER             = MCI_CD_OFFSET + 1;

{ MCI extensions for waveform audio devices }
  {$EXTERNALSYM MCI_WAVE_PCM}
  MCI_WAVE_PCM                    = MCI_WAVE_OFFSET + 0;
  {$EXTERNALSYM MCI_WAVE_MAPPER}
  MCI_WAVE_MAPPER                 = MCI_WAVE_OFFSET + 1;

{ flags for the dwFlags parameter of MCI_OPEN command message }
const
  {$EXTERNALSYM MCI_WAVE_OPEN_BUFFER}
  MCI_WAVE_OPEN_BUFFER            = $00010000;

{ flags for the dwFlags parameter of MCI_SET command message }
const
  {$EXTERNALSYM MCI_WAVE_SET_FORMATTAG}
  MCI_WAVE_SET_FORMATTAG          = $00010000;
  {$EXTERNALSYM MCI_WAVE_SET_CHANNELS}
  MCI_WAVE_SET_CHANNELS           = $00020000;
  {$EXTERNALSYM MCI_WAVE_SET_SAMPLESPERSEC}
  MCI_WAVE_SET_SAMPLESPERSEC      = $00040000;
  {$EXTERNALSYM MCI_WAVE_SET_AVGBYTESPERSEC}
  MCI_WAVE_SET_AVGBYTESPERSEC     = $00080000;
  {$EXTERNALSYM MCI_WAVE_SET_BLOCKALIGN}
  MCI_WAVE_SET_BLOCKALIGN         = $00100000;
  {$EXTERNALSYM MCI_WAVE_SET_BITSPERSAMPLE}
  MCI_WAVE_SET_BITSPERSAMPLE      = $00200000;

{ flags for the dwFlags parameter of MCI_STATUS, MCI_SET command messages }
const
  {$EXTERNALSYM MCI_WAVE_INPUT}
  MCI_WAVE_INPUT                  = $00400000;
  {$EXTERNALSYM MCI_WAVE_OUTPUT}
  MCI_WAVE_OUTPUT                 = $00800000;

{ flags for the dwItem field of MCI_STATUS_PARMS parameter block }
const
  {$EXTERNALSYM MCI_WAVE_STATUS_FORMATTAG}
  MCI_WAVE_STATUS_FORMATTAG       = $00004001;
  {$EXTERNALSYM MCI_WAVE_STATUS_CHANNELS}
  MCI_WAVE_STATUS_CHANNELS        = $00004002;
  {$EXTERNALSYM MCI_WAVE_STATUS_SAMPLESPERSEC}
  MCI_WAVE_STATUS_SAMPLESPERSEC   = $00004003;
  {$EXTERNALSYM MCI_WAVE_STATUS_AVGBYTESPERSEC}
  MCI_WAVE_STATUS_AVGBYTESPERSEC  = $00004004;
  {$EXTERNALSYM MCI_WAVE_STATUS_BLOCKALIGN}
  MCI_WAVE_STATUS_BLOCKALIGN      = $00004005;
  {$EXTERNALSYM MCI_WAVE_STATUS_BITSPERSAMPLE}
  MCI_WAVE_STATUS_BITSPERSAMPLE   = $00004006;
  {$EXTERNALSYM MCI_WAVE_STATUS_LEVEL}
  MCI_WAVE_STATUS_LEVEL           = $00004007;

{ flags for the dwFlags parameter of MCI_SET command message }
const
  {$EXTERNALSYM MCI_WAVE_SET_ANYINPUT}
  MCI_WAVE_SET_ANYINPUT           = $04000000;
  {$EXTERNALSYM MCI_WAVE_SET_ANYOUTPUT}
  MCI_WAVE_SET_ANYOUTPUT          = $08000000;

{ flags for the dwFlags parameter of MCI_GETDEVCAPS command message }
const
  {$EXTERNALSYM MCI_WAVE_GETDEVCAPS_INPUTS}
  MCI_WAVE_GETDEVCAPS_INPUTS      = $00004001;
  {$EXTERNALSYM MCI_WAVE_GETDEVCAPS_OUTPUTS}
  MCI_WAVE_GETDEVCAPS_OUTPUTS     = $00004002;

{ parameter block for MCI_OPEN command message }
type
  PMCI_Wave_Open_ParmsA = ^TMCI_Wave_Open_ParmsA;
  PMCI_Wave_Open_ParmsW = ^TMCI_Wave_Open_ParmsW;
  PMCI_Wave_Open_Parms = PMCI_Wave_Open_ParmsW;
  {$EXTERNALSYM tagMCI_WAVE_OPEN_PARMSA}
  tagMCI_WAVE_OPEN_PARMSA = record
    dwCallback: DWORD_PTR;
    wDeviceID: MCIDEVICEID;
    lpstrDeviceType: LPSTR;
    lpstrElementName: LPSTR;
    lpstrAlias: LPSTR;
    dwBufferSeconds: DWORD;
  end;
  {$EXTERNALSYM tagMCI_WAVE_OPEN_PARMSW}
  tagMCI_WAVE_OPEN_PARMSW = record
    dwCallback: DWORD_PTR;
    wDeviceID: MCIDEVICEID;
    lpstrDeviceType: LPWSTR;
    lpstrElementName: LPWSTR;
    lpstrAlias: LPWSTR;
    dwBufferSeconds: DWORD;
  end;
  {$EXTERNALSYM tagMCI_WAVE_OPEN_PARMS}
  tagMCI_WAVE_OPEN_PARMS = tagMCI_WAVE_OPEN_PARMSW;
  TMCI_Wave_Open_ParmsA = tagMCI_WAVE_OPEN_PARMSA;
  TMCI_Wave_Open_ParmsW = tagMCI_WAVE_OPEN_PARMSW;
  TMCI_Wave_Open_Parms = TMCI_Wave_Open_ParmsW;
  {$EXTERNALSYM MCI_WAVE_OPEN_PARMSA}
  MCI_WAVE_OPEN_PARMSA = tagMCI_WAVE_OPEN_PARMSA;
  {$EXTERNALSYM MCI_WAVE_OPEN_PARMSW}
  MCI_WAVE_OPEN_PARMSW = tagMCI_WAVE_OPEN_PARMSW;
  {$EXTERNALSYM MCI_WAVE_OPEN_PARMS}
  MCI_WAVE_OPEN_PARMS = MCI_WAVE_OPEN_PARMSW;

{ parameter block for MCI_DELETE command message }
type
  PMCI_Wave_Delete_Parms = ^TMCI_Wave_Delete_Parms;
  {$EXTERNALSYM tagMCI_WAVE_DELETE_PARMS}
  tagMCI_WAVE_DELETE_PARMS = record
    dwCallback: DWORD_PTR;
    dwFrom: DWORD;
    dwTo: DWORD;
  end;
  TMCI_Wave_Delete_Parms = tagMCI_WAVE_DELETE_PARMS;
  {$EXTERNALSYM MCI_WAVE_DELETE_PARMS}
  MCI_WAVE_DELETE_PARMS = tagMCI_WAVE_DELETE_PARMS;

{ parameter block for MCI_SET command message }
type
  PMCI_Wave_Set_Parms = ^TMCI_Wave_Set_Parms;
  {$EXTERNALSYM tagMCI_WAVE_SET_PARMS}
  tagMCI_WAVE_SET_PARMS = record
    dwCallback: DWORD_PTR;
    dwTimeFormat: DWORD;
    dwAudio: DWORD;
    wInput: UINT;
    wOutput: UINT;
    wFormatTag: Word;
    wReserved2: Word;
    nChannels: Word;
    wReserved3: Word;
    nSamplesPerSec: DWORD;
    nAvgBytesPerSec: DWORD;
    nBlockAlign: Word;
    wReserved4: Word;
    wBitsPerSample: Word;
    wReserved5: Word;
  end;
  TMCI_Wave_Set_Parms = tagMCI_WAVE_SET_PARMS;
  {$EXTERNALSYM MCI_WAVE_SET_PARMS}
  MCI_WAVE_SET_PARMS = tagMCI_WAVE_SET_PARMS;


{ MCI extensions for MIDI sequencer devices }

{ flags for the dwReturn field of MCI_STATUS_PARMS parameter block }
{ MCI_STATUS command, (dwItem == MCI_SEQ_STATUS_DIVTYPE) }
const
  {$EXTERNALSYM MCI_SEQ_DIV_PPQN}
  MCI_SEQ_DIV_PPQN            = 0 + MCI_SEQ_OFFSET;
  {$EXTERNALSYM MCI_SEQ_DIV_SMPTE_24}
  MCI_SEQ_DIV_SMPTE_24        = 1 + MCI_SEQ_OFFSET;
  {$EXTERNALSYM MCI_SEQ_DIV_SMPTE_25}
  MCI_SEQ_DIV_SMPTE_25        = 2 + MCI_SEQ_OFFSET;
  {$EXTERNALSYM MCI_SEQ_DIV_SMPTE_30DROP}
  MCI_SEQ_DIV_SMPTE_30DROP    = 3 + MCI_SEQ_OFFSET;
  {$EXTERNALSYM MCI_SEQ_DIV_SMPTE_30}
  MCI_SEQ_DIV_SMPTE_30        = 4 + MCI_SEQ_OFFSET;

{ flags for the dwMaster field of MCI_SEQ_SET_PARMS parameter block }
{ MCI_SET command, (dwFlags == MCI_SEQ_SET_MASTER) }
const
  {$EXTERNALSYM MCI_SEQ_FORMAT_SONGPTR}
  MCI_SEQ_FORMAT_SONGPTR      = $4001;
  {$EXTERNALSYM MCI_SEQ_FILE}
  MCI_SEQ_FILE                = $4002;
  {$EXTERNALSYM MCI_SEQ_MIDI}
  MCI_SEQ_MIDI                = $4003;
  {$EXTERNALSYM MCI_SEQ_SMPTE}
  MCI_SEQ_SMPTE               = $4004;
  {$EXTERNALSYM MCI_SEQ_NONE}
  MCI_SEQ_NONE                = 65533;
  {$EXTERNALSYM MCI_SEQ_MAPPER}
  MCI_SEQ_MAPPER              = 65535;

{ flags for the dwItem field of MCI_STATUS_PARMS parameter block }
const
  {$EXTERNALSYM MCI_SEQ_STATUS_TEMPO}
  MCI_SEQ_STATUS_TEMPO            = $00004002;
  {$EXTERNALSYM MCI_SEQ_STATUS_PORT}
  MCI_SEQ_STATUS_PORT             = $00004003;
  {$EXTERNALSYM MCI_SEQ_STATUS_SLAVE}
  MCI_SEQ_STATUS_SLAVE            = $00004007;
  {$EXTERNALSYM MCI_SEQ_STATUS_MASTER}
  MCI_SEQ_STATUS_MASTER           = $00004008;
  {$EXTERNALSYM MCI_SEQ_STATUS_OFFSET}
  MCI_SEQ_STATUS_OFFSET           = $00004009;
  {$EXTERNALSYM MCI_SEQ_STATUS_DIVTYPE}
  MCI_SEQ_STATUS_DIVTYPE          = $0000400A;
  {$EXTERNALSYM MCI_SEQ_STATUS_NAME}
  MCI_SEQ_STATUS_NAME             = $0000400B;
  {$EXTERNALSYM MCI_SEQ_STATUS_COPYRIGHT}
  MCI_SEQ_STATUS_COPYRIGHT        = $0000400C;

{ flags for the dwFlags parameter of MCI_SET command message }
const
  {$EXTERNALSYM MCI_SEQ_SET_TEMPO}
  MCI_SEQ_SET_TEMPO               = $00010000;
  {$EXTERNALSYM MCI_SEQ_SET_PORT}
  MCI_SEQ_SET_PORT                = $00020000;
  {$EXTERNALSYM MCI_SEQ_SET_SLAVE}
  MCI_SEQ_SET_SLAVE               = $00040000;
  {$EXTERNALSYM MCI_SEQ_SET_MASTER}
  MCI_SEQ_SET_MASTER              = $00080000;
  {$EXTERNALSYM MCI_SEQ_SET_OFFSET}
  MCI_SEQ_SET_OFFSET              = $01000000;

{ parameter block for MCI_SET command message }
type
  PMCI_Seq_Set_Parms = ^TMCI_Seq_Set_Parms;
  {$EXTERNALSYM tagMCI_SEQ_SET_PARMS}
  tagMCI_SEQ_SET_PARMS = record
    dwCallback: DWORD_PTR;
    dwTimeFormat: DWORD;
    dwAudio: DWORD;
    dwTempo: DWORD;
    dwPort: DWORD;
    dwSlave: DWORD;
    dwMaster: DWORD;
    dwOffset: DWORD;
  end;
  TMCI_Seq_Set_Parms = tagMCI_SEQ_SET_PARMS;
  {$EXTERNALSYM MCI_SEQ_SET_PARMS}
  MCI_SEQ_SET_PARMS = tagMCI_SEQ_SET_PARMS;

{ MCI extensions for animation devices }

{ flags for dwFlags parameter of MCI_OPEN command message }
const
  {$EXTERNALSYM MCI_ANIM_OPEN_WS}
  MCI_ANIM_OPEN_WS                = $00010000;
  {$EXTERNALSYM MCI_ANIM_OPEN_PARENT}
  MCI_ANIM_OPEN_PARENT            = $00020000;
  {$EXTERNALSYM MCI_ANIM_OPEN_NOSTATIC}
  MCI_ANIM_OPEN_NOSTATIC          = $00040000;

{ flags for dwFlags parameter of MCI_PLAY command message }
const
  {$EXTERNALSYM MCI_ANIM_PLAY_SPEED}
  MCI_ANIM_PLAY_SPEED             = $00010000;
  {$EXTERNALSYM MCI_ANIM_PLAY_REVERSE}
  MCI_ANIM_PLAY_REVERSE           = $00020000;
  {$EXTERNALSYM MCI_ANIM_PLAY_FAST}
  MCI_ANIM_PLAY_FAST              = $00040000;
  {$EXTERNALSYM MCI_ANIM_PLAY_SLOW}
  MCI_ANIM_PLAY_SLOW              = $00080000;
  {$EXTERNALSYM MCI_ANIM_PLAY_SCAN}
  MCI_ANIM_PLAY_SCAN              = $00100000;

{ flags for dwFlags parameter of MCI_STEP command message }
const
  {$EXTERNALSYM MCI_ANIM_STEP_REVERSE}
  MCI_ANIM_STEP_REVERSE           = $00010000;
  {$EXTERNALSYM MCI_ANIM_STEP_FRAMES}
  MCI_ANIM_STEP_FRAMES            = $00020000;

{ flags for dwItem field of MCI_STATUS_PARMS parameter block }
const
  {$EXTERNALSYM MCI_ANIM_STATUS_SPEED}
  MCI_ANIM_STATUS_SPEED           = $00004001;
  {$EXTERNALSYM MCI_ANIM_STATUS_FORWARD}
  MCI_ANIM_STATUS_FORWARD         = $00004002;
  {$EXTERNALSYM MCI_ANIM_STATUS_HWND}
  MCI_ANIM_STATUS_HWND            = $00004003;
  {$EXTERNALSYM MCI_ANIM_STATUS_HPAL}
  MCI_ANIM_STATUS_HPAL            = $00004004;
  {$EXTERNALSYM MCI_ANIM_STATUS_STRETCH}
  MCI_ANIM_STATUS_STRETCH         = $00004005;

{ flags for the dwFlags parameter of MCI_INFO command message }
const
  {$EXTERNALSYM MCI_ANIM_INFO_TEXT}
  MCI_ANIM_INFO_TEXT              = $00010000;

{ flags for dwItem field of MCI_GETDEVCAPS_PARMS parameter block }
const
  {$EXTERNALSYM MCI_ANIM_GETDEVCAPS_CAN_REVERSE}
  MCI_ANIM_GETDEVCAPS_CAN_REVERSE = $00004001;
  {$EXTERNALSYM MCI_ANIM_GETDEVCAPS_FAST_RATE}
  MCI_ANIM_GETDEVCAPS_FAST_RATE   = $00004002;
  {$EXTERNALSYM MCI_ANIM_GETDEVCAPS_SLOW_RATE}
  MCI_ANIM_GETDEVCAPS_SLOW_RATE   = $00004003;
  {$EXTERNALSYM MCI_ANIM_GETDEVCAPS_NORMAL_RATE}
  MCI_ANIM_GETDEVCAPS_NORMAL_RATE = $00004004;
  {$EXTERNALSYM MCI_ANIM_GETDEVCAPS_PALETTES}
  MCI_ANIM_GETDEVCAPS_PALETTES    = $00004006;
  {$EXTERNALSYM MCI_ANIM_GETDEVCAPS_CAN_STRETCH}
  MCI_ANIM_GETDEVCAPS_CAN_STRETCH = $00004007;
  {$EXTERNALSYM MCI_ANIM_GETDEVCAPS_MAX_WINDOWS}
  MCI_ANIM_GETDEVCAPS_MAX_WINDOWS = $00004008;

{ flags for the MCI_REALIZE command message }
const
  {$EXTERNALSYM MCI_ANIM_REALIZE_NORM}
  MCI_ANIM_REALIZE_NORM           = $00010000;
  {$EXTERNALSYM MCI_ANIM_REALIZE_BKGD}
  MCI_ANIM_REALIZE_BKGD           = $00020000;

{ flags for dwFlags parameter of MCI_WINDOW command message }
const
  {$EXTERNALSYM MCI_ANIM_WINDOW_HWND}
  MCI_ANIM_WINDOW_HWND            = $00010000;
  {$EXTERNALSYM MCI_ANIM_WINDOW_STATE}
  MCI_ANIM_WINDOW_STATE           = $00040000;
  {$EXTERNALSYM MCI_ANIM_WINDOW_TEXT}
  MCI_ANIM_WINDOW_TEXT            = $00080000;
  {$EXTERNALSYM MCI_ANIM_WINDOW_ENABLE_STRETCH}
  MCI_ANIM_WINDOW_ENABLE_STRETCH  = $00100000;
  {$EXTERNALSYM MCI_ANIM_WINDOW_DISABLE_STRETCH}
  MCI_ANIM_WINDOW_DISABLE_STRETCH = $00200000;

{ flags for hWnd field of MCI_ANIM_WINDOW_PARMS parameter block }
{ MCI_WINDOW command message, (dwFlags == MCI_ANIM_WINDOW_HWND) }
const
  {$EXTERNALSYM MCI_ANIM_WINDOW_DEFAULT}
  MCI_ANIM_WINDOW_DEFAULT         = $00000000;

{ flags for dwFlags parameter of MCI_PUT command message }
const
  {$EXTERNALSYM MCI_ANIM_RECT}
  MCI_ANIM_RECT                   = $00010000;
  {$EXTERNALSYM MCI_ANIM_PUT_SOURCE}
  MCI_ANIM_PUT_SOURCE             = $00020000;
  {$EXTERNALSYM MCI_ANIM_PUT_DESTINATION}
  MCI_ANIM_PUT_DESTINATION        = $00040000;

{ flags for dwFlags parameter of MCI_WHERE command message }
const
  {$EXTERNALSYM MCI_ANIM_WHERE_SOURCE}
  MCI_ANIM_WHERE_SOURCE           = $00020000;
  {$EXTERNALSYM MCI_ANIM_WHERE_DESTINATION}
  MCI_ANIM_WHERE_DESTINATION      = $00040000;

{ flags for dwFlags parameter of MCI_UPDATE command message }
const
  {$EXTERNALSYM MCI_ANIM_UPDATE_HDC}
  MCI_ANIM_UPDATE_HDC             = $00020000;

{ parameter block for MCI_OPEN command message }
type
  PMCI_Anim_Open_ParmsA = ^TMCI_Anim_Open_ParmsA;
  PMCI_Anim_Open_ParmsW = ^TMCI_Anim_Open_ParmsW;
  PMCI_Anim_Open_Parms = PMCI_Anim_Open_ParmsW;
  {$EXTERNALSYM tagMCI_ANIM_OPEN_PARMSA}
  tagMCI_ANIM_OPEN_PARMSA = record
    dwCallback: DWORD_PTR;
    wDeviceID: MCIDEVICEID;
    lpstrDeviceType: LPCSTR;
    lpstrElementName: LPCSTR;
    lpstrAlias: LPCSTR;
    dwStyle: DWORD;
    hWndParent: HWND;
  end;
  {$EXTERNALSYM tagMCI_ANIM_OPEN_PARMSW}
  tagMCI_ANIM_OPEN_PARMSW = record
    dwCallback: DWORD_PTR;
    wDeviceID: MCIDEVICEID;
    lpstrDeviceType: LPCWSTR;
    lpstrElementName: LPCWSTR;
    lpstrAlias: LPCWSTR;
    dwStyle: DWORD;
    hWndParent: HWND;
  end;
  {$EXTERNALSYM tagMCI_ANIM_OPEN_PARMS}
  tagMCI_ANIM_OPEN_PARMS = tagMCI_ANIM_OPEN_PARMSW;
  TMCI_Anim_Open_ParmsA = tagMCI_ANIM_OPEN_PARMSA;
  TMCI_Anim_Open_ParmsW = tagMCI_ANIM_OPEN_PARMSW;
  TMCI_Anim_Open_Parms = TMCI_Anim_Open_ParmsW;
  {$EXTERNALSYM MCI_ANIM_OPEN_PARMSA}
  MCI_ANIM_OPEN_PARMSA = tagMCI_ANIM_OPEN_PARMSA;
  {$EXTERNALSYM MCI_ANIM_OPEN_PARMSW}
  MCI_ANIM_OPEN_PARMSW = tagMCI_ANIM_OPEN_PARMSW;
  {$EXTERNALSYM MCI_ANIM_OPEN_PARMS}
  MCI_ANIM_OPEN_PARMS = MCI_ANIM_OPEN_PARMSW;

{ parameter block for MCI_PLAY command message }
type
  PMCI_Anim_Play_Parms = ^TMCI_Anim_Play_Parms;
  {$EXTERNALSYM tagMCI_ANIM_PLAY_PARMS}
  tagMCI_ANIM_PLAY_PARMS = record
    dwCallback: DWORD_PTR;
    dwFrom: DWORD;
    dwTo: DWORD;
    dwSpeed: DWORD;
  end;
  TMCI_Anim_Play_Parms = tagMCI_ANIM_PLAY_PARMS;
  {$EXTERNALSYM MCI_ANIM_PLAY_PARMS}
  MCI_ANIM_PLAY_PARMS = tagMCI_ANIM_PLAY_PARMS;

{ parameter block for MCI_STEP command message }
type
  PMCI_Anim_Step_Parms = ^TMCI_Anim_Step_Parms;
  {$EXTERNALSYM tagMCI_ANIM_STEP_PARMS}
  tagMCI_ANIM_STEP_PARMS = record
    dwCallback: DWORD_PTR;
    dwFrames: DWORD;
  end;
  TMCI_Anim_Step_Parms = tagMCI_ANIM_STEP_PARMS;
  {$EXTERNALSYM MCI_ANIM_STEP_PARMS}
  MCI_ANIM_STEP_PARMS = tagMCI_ANIM_STEP_PARMS;

{ parameter block for MCI_WINDOW command message }
type
  PMCI_Anim_Window_ParmsA = ^TMCI_Anim_Window_ParmsA;
  PMCI_Anim_Window_ParmsW = ^TMCI_Anim_Window_ParmsW;
  PMCI_Anim_Window_Parms = PMCI_Anim_Window_ParmsW;
  {$EXTERNALSYM tagMCI_ANIM_WINDOW_PARMSA}
  tagMCI_ANIM_WINDOW_PARMSA = record
    dwCallback: DWORD_PTR;
    Wnd: HWND;  { formerly "hWnd" }
    nCmdShow: UINT;
    lpstrText: LPCSTR;
  end;
  {$EXTERNALSYM tagMCI_ANIM_WINDOW_PARMSW}
  tagMCI_ANIM_WINDOW_PARMSW = record
    dwCallback: DWORD_PTR;
    Wnd: HWND;  { formerly "hWnd" }
    nCmdShow: UINT;
    lpstrText: LPCWSTR;
  end;
  {$EXTERNALSYM tagMCI_ANIM_WINDOW_PARMS}
  tagMCI_ANIM_WINDOW_PARMS = tagMCI_ANIM_WINDOW_PARMSW;
  TMCI_Anim_Window_ParmsA = tagMCI_ANIM_WINDOW_PARMSA;
  TMCI_Anim_Window_ParmsW = tagMCI_ANIM_WINDOW_PARMSW;
  TMCI_Anim_Window_Parms = TMCI_Anim_Window_ParmsW;
  {$EXTERNALSYM MCI_ANIM_WINDOW_PARMSA}
  MCI_ANIM_WINDOW_PARMSA = tagMCI_ANIM_WINDOW_PARMSA;
  {$EXTERNALSYM MCI_ANIM_WINDOW_PARMSW}
  MCI_ANIM_WINDOW_PARMSW = tagMCI_ANIM_WINDOW_PARMSW;
  {$EXTERNALSYM MCI_ANIM_WINDOW_PARMS}
  MCI_ANIM_WINDOW_PARMS = MCI_ANIM_WINDOW_PARMSW;

{ parameter block for MCI_PUT, MCI_UPDATE, MCI_WHERE command messages }
type
  PMCI_Anim_Rect_Parms = ^ TMCI_Anim_Rect_Parms;
  {$EXTERNALSYM tagMCI_ANIM_RECT_PARMS}
  tagMCI_ANIM_RECT_PARMS = record
    dwCallback: DWORD_PTR;
    rc: TRect;
  end;
  TMCI_Anim_Rect_Parms = tagMCI_ANIM_RECT_PARMS;
  {$EXTERNALSYM MCI_ANIM_RECT_PARMS}
  MCI_ANIM_RECT_PARMS = tagMCI_ANIM_RECT_PARMS;

{ parameter block for MCI_UPDATE PARMS }
type
  PMCI_Anim_Update_Parms = ^TMCI_Anim_Update_Parms;
  {$EXTERNALSYM tagMCI_ANIM_UPDATE_PARMS}
  tagMCI_ANIM_UPDATE_PARMS = record
    dwCallback: DWORD_PTR;
    rc: TRect;
    hDC: HDC;
  end;
  TMCI_Anim_Update_Parms = tagMCI_ANIM_UPDATE_PARMS;
  {$EXTERNALSYM MCI_ANIM_UPDATE_PARMS}
  MCI_ANIM_UPDATE_PARMS = tagMCI_ANIM_UPDATE_PARMS;

{ MCI extensions for video overlay devices }

{ flags for dwFlags parameter of MCI_OPEN command message }
const
  {$EXTERNALSYM MCI_OVLY_OPEN_WS}
  MCI_OVLY_OPEN_WS                = $00010000;
  {$EXTERNALSYM MCI_OVLY_OPEN_PARENT}
  MCI_OVLY_OPEN_PARENT            = $00020000;

{ flags for dwFlags parameter of MCI_STATUS command message }
const
  {$EXTERNALSYM MCI_OVLY_STATUS_HWND}
  MCI_OVLY_STATUS_HWND            = $00004001;
  {$EXTERNALSYM MCI_OVLY_STATUS_STRETCH}
  MCI_OVLY_STATUS_STRETCH         = $00004002;

{ flags for dwFlags parameter of MCI_INFO command message }
const
  {$EXTERNALSYM MCI_OVLY_INFO_TEXT}
  MCI_OVLY_INFO_TEXT              = $00010000;

{ flags for dwItem field of MCI_GETDEVCAPS_PARMS parameter block }
const
  {$EXTERNALSYM MCI_OVLY_GETDEVCAPS_CAN_STRETCH}
  MCI_OVLY_GETDEVCAPS_CAN_STRETCH = $00004001;
  {$EXTERNALSYM MCI_OVLY_GETDEVCAPS_CAN_FREEZE}
  MCI_OVLY_GETDEVCAPS_CAN_FREEZE  = $00004002;
  {$EXTERNALSYM MCI_OVLY_GETDEVCAPS_MAX_WINDOWS}
  MCI_OVLY_GETDEVCAPS_MAX_WINDOWS = $00004003;

{ flags for dwFlags parameter of MCI_WINDOW command message }
const
  {$EXTERNALSYM MCI_OVLY_WINDOW_HWND}
  MCI_OVLY_WINDOW_HWND            = $00010000;
  {$EXTERNALSYM MCI_OVLY_WINDOW_STATE}
  MCI_OVLY_WINDOW_STATE           = $00040000;
  {$EXTERNALSYM MCI_OVLY_WINDOW_TEXT}
  MCI_OVLY_WINDOW_TEXT            = $00080000;
  {$EXTERNALSYM MCI_OVLY_WINDOW_ENABLE_STRETCH}
  MCI_OVLY_WINDOW_ENABLE_STRETCH  = $00100000;
  {$EXTERNALSYM MCI_OVLY_WINDOW_DISABLE_STRETCH}
  MCI_OVLY_WINDOW_DISABLE_STRETCH = $00200000;

{ flags for hWnd parameter of MCI_OVLY_WINDOW_PARMS parameter block }
const
  {$EXTERNALSYM MCI_OVLY_WINDOW_DEFAULT}
  MCI_OVLY_WINDOW_DEFAULT         = $00000000;

{ flags for dwFlags parameter of MCI_PUT command message }
const
  {$EXTERNALSYM MCI_OVLY_RECT}
  MCI_OVLY_RECT                   = $00010000;
  {$EXTERNALSYM MCI_OVLY_PUT_SOURCE}
  MCI_OVLY_PUT_SOURCE             = $00020000;
  {$EXTERNALSYM MCI_OVLY_PUT_DESTINATION}
  MCI_OVLY_PUT_DESTINATION        = $00040000;
  {$EXTERNALSYM MCI_OVLY_PUT_FRAME}
  MCI_OVLY_PUT_FRAME              = $00080000;
  {$EXTERNALSYM MCI_OVLY_PUT_VIDEO}
  MCI_OVLY_PUT_VIDEO              = $00100000;

{ flags for dwFlags parameter of MCI_WHERE command message }
const
  {$EXTERNALSYM MCI_OVLY_WHERE_SOURCE}
  MCI_OVLY_WHERE_SOURCE           = $00020000;
  {$EXTERNALSYM MCI_OVLY_WHERE_DESTINATION}
  MCI_OVLY_WHERE_DESTINATION      = $00040000;
  {$EXTERNALSYM MCI_OVLY_WHERE_FRAME}
  MCI_OVLY_WHERE_FRAME            = $00080000;
  {$EXTERNALSYM MCI_OVLY_WHERE_VIDEO}
  MCI_OVLY_WHERE_VIDEO            = $00100000;

{ parameter block for MCI_OPEN command message }
type
  PMCI_Ovly_Open_ParmsA = ^TMCI_Ovly_Open_ParmsA;
  PMCI_Ovly_Open_ParmsW = ^TMCI_Ovly_Open_ParmsW;
  PMCI_Ovly_Open_Parms = PMCI_Ovly_Open_ParmsW;
  {$EXTERNALSYM tagMCI_OVLY_OPEN_PARMSA}
  tagMCI_OVLY_OPEN_PARMSA = record
    dwCallback: DWORD_PTR;
    wDeviceID: MCIDEVICEID;
    lpstrDeviceType: LPCSTR;
    lpstrElementName: LPCSTR;
    lpstrAlias: LPCSTR;
    dwStyle: DWORD;
    hWndParent: HWND;
  end;
  {$EXTERNALSYM tagMCI_OVLY_OPEN_PARMSW}
  tagMCI_OVLY_OPEN_PARMSW = record
    dwCallback: DWORD_PTR;
    wDeviceID: MCIDEVICEID;
    lpstrDeviceType: LPCWSTR;
    lpstrElementName: LPCWSTR;
    lpstrAlias: LPCWSTR;
    dwStyle: DWORD;
    hWndParent: HWND;
  end;
  {$EXTERNALSYM tagMCI_OVLY_OPEN_PARMS}
  tagMCI_OVLY_OPEN_PARMS = tagMCI_OVLY_OPEN_PARMSW;
  TMCI_Ovly_Open_ParmsA = tagMCI_OVLY_OPEN_PARMSA;
  TMCI_Ovly_Open_ParmsW = tagMCI_OVLY_OPEN_PARMSW;
  TMCI_Ovly_Open_Parms = TMCI_Ovly_Open_ParmsW;
  {$EXTERNALSYM MCI_OVLY_OPEN_PARMSA}
  MCI_OVLY_OPEN_PARMSA = tagMCI_OVLY_OPEN_PARMSA;
  {$EXTERNALSYM MCI_OVLY_OPEN_PARMSW}
  MCI_OVLY_OPEN_PARMSW = tagMCI_OVLY_OPEN_PARMSW;
  {$EXTERNALSYM MCI_OVLY_OPEN_PARMS}
  MCI_OVLY_OPEN_PARMS = MCI_OVLY_OPEN_PARMSW;

{ parameter block for MCI_WINDOW command message }
type
  PMCI_Ovly_Window_ParmsA = ^TMCI_Ovly_Window_ParmsA;
  PMCI_Ovly_Window_ParmsW = ^TMCI_Ovly_Window_ParmsW;
  PMCI_Ovly_Window_Parms = PMCI_Ovly_Window_ParmsW;
  {$EXTERNALSYM tagMCI_OVLY_WINDOW_PARMSA}
  tagMCI_OVLY_WINDOW_PARMSA = record
    dwCallback: DWORD_PTR;
    WHandle: HWND; { formerly "hWnd"}
    nCmdShow: UINT;
    lpstrText: LPCSTR;
  end;
  {$EXTERNALSYM tagMCI_OVLY_WINDOW_PARMSW}
  tagMCI_OVLY_WINDOW_PARMSW = record
    dwCallback: DWORD_PTR;
    WHandle: HWND; { formerly "hWnd"}
    nCmdShow: UINT;
    lpstrText: LPCWSTR;
  end;
  {$EXTERNALSYM tagMCI_OVLY_WINDOW_PARMS}
  tagMCI_OVLY_WINDOW_PARMS = tagMCI_OVLY_WINDOW_PARMSW;
  TMCI_Ovly_Window_ParmsA = tagMCI_OVLY_WINDOW_PARMSA;
  TMCI_Ovly_Window_ParmsW = tagMCI_OVLY_WINDOW_PARMSW;
  TMCI_Ovly_Window_Parms = TMCI_Ovly_Window_ParmsW;
  {$EXTERNALSYM MCI_OVLY_WINDOW_PARMSA}
  MCI_OVLY_WINDOW_PARMSA = tagMCI_OVLY_WINDOW_PARMSA;
  {$EXTERNALSYM MCI_OVLY_WINDOW_PARMSW}
  MCI_OVLY_WINDOW_PARMSW = tagMCI_OVLY_WINDOW_PARMSW;
  {$EXTERNALSYM MCI_OVLY_WINDOW_PARMS}
  MCI_OVLY_WINDOW_PARMS = MCI_OVLY_WINDOW_PARMSW;

{ parameter block for MCI_PUT, MCI_UPDATE, and MCI_WHERE command messages }
type
  PMCI_Ovly_Rect_Parms = ^ TMCI_Ovly_Rect_Parms;
  {$EXTERNALSYM tagMCI_OVLY_RECT_PARMS}
  tagMCI_OVLY_RECT_PARMS = record
    dwCallback: DWORD_PTR;
    rc: TRect;
  end;
  TMCI_Ovly_Rect_Parms = tagMCI_OVLY_RECT_PARMS;
  {$EXTERNALSYM MCI_OVLY_RECT_PARMS}
  MCI_OVLY_RECT_PARMS = tagMCI_OVLY_RECT_PARMS;

{ parameter block for MCI_SAVE command message }
type
  PMCI_Ovly_Save_ParmsA = ^TMCI_Ovly_Save_ParmsA;
  PMCI_Ovly_Save_ParmsW = ^TMCI_Ovly_Save_ParmsW;
  PMCI_Ovly_Save_Parms = PMCI_Ovly_Save_ParmsW;
  {$EXTERNALSYM tagMCI_OVLY_SAVE_PARMSA}
  tagMCI_OVLY_SAVE_PARMSA = record
    dwCallback: DWORD_PTR;
    lpfilename: LPCSTR;
    rc: TRect;
  end;
  {$EXTERNALSYM tagMCI_OVLY_SAVE_PARMSW}
  tagMCI_OVLY_SAVE_PARMSW = record
    dwCallback: DWORD_PTR;
    lpfilename: LPCWSTR;
    rc: TRect;
  end;
  {$EXTERNALSYM tagMCI_OVLY_SAVE_PARMS}
  tagMCI_OVLY_SAVE_PARMS = tagMCI_OVLY_SAVE_PARMSW;
  TMCI_Ovly_Save_ParmsA = tagMCI_OVLY_SAVE_PARMSA;
  TMCI_Ovly_Save_ParmsW = tagMCI_OVLY_SAVE_PARMSW;
  TMCI_Ovly_Save_Parms = TMCI_Ovly_Save_ParmsW;
  {$EXTERNALSYM MCI_OVLY_SAVE_PARMSA}
  MCI_OVLY_SAVE_PARMSA = tagMCI_OVLY_SAVE_PARMSA;
  {$EXTERNALSYM MCI_OVLY_SAVE_PARMSW}
  MCI_OVLY_SAVE_PARMSW = tagMCI_OVLY_SAVE_PARMSW;
  {$EXTERNALSYM MCI_OVLY_SAVE_PARMS}
  MCI_OVLY_SAVE_PARMS = MCI_OVLY_SAVE_PARMSW;

{ parameter block for MCI_LOAD command message }
type
  PMCI_Ovly_Load_ParmsA = ^TMCI_Ovly_Load_ParmsA;
  PMCI_Ovly_Load_ParmsW = ^TMCI_Ovly_Load_ParmsW;
  PMCI_Ovly_Load_Parms = PMCI_Ovly_Load_ParmsW;
  {$EXTERNALSYM tagMCI_OVLY_LOAD_PARMSA}
  tagMCI_OVLY_LOAD_PARMSA = record
    dwCallback: DWORD_PTR;
    lpfilename: LPCSTR;
    rc: TRect;
  end;
  {$EXTERNALSYM tagMCI_OVLY_LOAD_PARMSW}
  tagMCI_OVLY_LOAD_PARMSW = record
    dwCallback: DWORD_PTR;
    lpfilename: LPCWSTR;
    rc: TRect;
  end;
  {$EXTERNALSYM tagMCI_OVLY_LOAD_PARMS}
  tagMCI_OVLY_LOAD_PARMS = tagMCI_OVLY_LOAD_PARMSW;
  TMCI_Ovly_Load_ParmsA = tagMCI_OVLY_LOAD_PARMSA;
  TMCI_Ovly_Load_ParmsW = tagMCI_OVLY_LOAD_PARMSW;
  TMCI_Ovly_Load_Parms = TMCI_Ovly_Load_ParmsW;
  {$EXTERNALSYM MCI_OVLY_LOAD_PARMSA}
  MCI_OVLY_LOAD_PARMSA = tagMCI_OVLY_LOAD_PARMSA;
  {$EXTERNALSYM MCI_OVLY_LOAD_PARMSW}
  MCI_OVLY_LOAD_PARMSW = tagMCI_OVLY_LOAD_PARMSW;
  {$EXTERNALSYM MCI_OVLY_LOAD_PARMS}
  MCI_OVLY_LOAD_PARMS = MCI_OVLY_LOAD_PARMSW;


{***************************************************************************

                        DISPLAY Driver extensions

***************************************************************************}

const
  {$EXTERNALSYM NEWTRANSPARENT}
  NEWTRANSPARENT  = 3;           { use with SetBkMode() }
  {$EXTERNALSYM QUERYROPSUPPORT}
  QUERYROPSUPPORT = 40;          { use to determine ROP support }

{***************************************************************************

                        DIB Driver extensions

***************************************************************************}
const
  {$EXTERNALSYM SELECTDIB}
  SELECTDIB       = 41;                      { DIB.DRV select dib escape }

function DIBIndex(N: Integer): Longint;

{***************************************************************************

                        ScreenSaver support

    The current application will receive a syscommand of SC_SCREENSAVE just
    before the screen saver is invoked.  If the app wishes to prevent a
    screen save, return a non-zero value, otherwise call DefWindowProc().

***************************************************************************}

const
  {$EXTERNALSYM SC_SCREENSAVE}
  SC_SCREENSAVE   = $F140;

  mmsyst = 'winmm.dll';

implementation

function auxGetDevCaps; external mmsyst name 'auxGetDevCapsW';
function auxGetDevCapsA; external mmsyst name 'auxGetDevCapsA';
function auxGetDevCapsW; external mmsyst name 'auxGetDevCapsW';
function auxGetNumDevs; external mmsyst name 'auxGetNumDevs';
function auxGetVolume; external mmsyst name 'auxGetVolume';
function auxOutMessage; external mmsyst name 'auxOutMessage';
function auxSetVolume; external mmsyst name 'auxSetVolume';
function CloseDriver; external mmsyst name 'CloseDriver';
function DefDriverProc; external mmsyst name 'DefDriverProc';
function DrvGetModuleHandle; external mmsyst name 'DrvGetModuleHandle';
function GetDriverModuleHandle; external mmsyst name 'GetDriverModuleHandle';
function joyGetDevCaps; external mmsyst name 'joyGetDevCapsW';
function joyGetDevCapsA; external mmsyst name 'joyGetDevCapsA';
function joyGetDevCapsW; external mmsyst name 'joyGetDevCapsW';
function joyGetNumDevs; external mmsyst name 'joyGetNumDevs';
function joyGetPos; external mmsyst name 'joyGetPos';
function joyGetPosEx; external mmsyst name 'joyGetPosEx';
function joyGetThreshold; external mmsyst name 'joyGetThreshold';
function joyReleaseCapture; external mmsyst name 'joyReleaseCapture';
function joySetCapture; external mmsyst name 'joySetCapture';
function joySetThreshold; external mmsyst name 'joySetThreshold';
function mciExecute; external mmsyst name 'mciExecute';
function mciGetCreatorTask; external mmsyst name 'mciGetCreatorTask';
function mciGetDeviceID; external mmsyst name 'mciGetDeviceIDW';
function mciGetDeviceIDA; external mmsyst name 'mciGetDeviceIDA';
function mciGetDeviceIDW; external mmsyst name 'mciGetDeviceIDW';
function mciGetDeviceIDFromElementID; external mmsyst name 'mciGetDeviceIDFromElementIDW';
function mciGetDeviceIDFromElementIDA; external mmsyst name 'mciGetDeviceIDFromElementIDA';
function mciGetDeviceIDFromElementIDW; external mmsyst name 'mciGetDeviceIDFromElementIDW';
function mciGetErrorString; external mmsyst name 'mciGetErrorStringW';
function mciGetErrorStringA; external mmsyst name 'mciGetErrorStringA';
function mciGetErrorStringW; external mmsyst name 'mciGetErrorStringW';
function mciGetYieldProc; external mmsyst name 'mciGetYieldProc';
function mciSendCommand; external mmsyst name 'mciSendCommandW';
function mciSendCommandA; external mmsyst name 'mciSendCommandA';
function mciSendCommandW; external mmsyst name 'mciSendCommandW';
function mciSendString; external mmsyst name 'mciSendStringW';
function mciSendStringA; external mmsyst name 'mciSendStringA';
function mciSendStringW; external mmsyst name 'mciSendStringW';
function mciSetYieldProc; external mmsyst name 'mciSetYieldProc';
function midiConnect; external mmsyst name 'midiConnect';
function midiDisconnect; external mmsyst name 'midiDisconnect';
function midiInAddBuffer; external mmsyst name 'midiInAddBuffer';
function midiInClose; external mmsyst name 'midiInClose';
function midiInGetDevCaps; external mmsyst name 'midiInGetDevCapsW';
function midiInGetDevCapsA; external mmsyst name 'midiInGetDevCapsA';
function midiInGetDevCapsW; external mmsyst name 'midiInGetDevCapsW';
function midiInGetErrorText; external mmsyst name 'midiInGetErrorTextW';
function midiInGetErrorTextA; external mmsyst name 'midiInGetErrorTextA';
function midiInGetErrorTextW; external mmsyst name 'midiInGetErrorTextW';
function midiInGetID; external mmsyst name 'midiInGetID';
function midiInGetNumDevs; external mmsyst name 'midiInGetNumDevs';
function midiInMessage; external mmsyst name 'midiInMessage';
function midiInOpen; external mmsyst name 'midiInOpen';
function midiInPrepareHeader; external mmsyst name 'midiInPrepareHeader';
function midiInReset; external mmsyst name 'midiInReset';
function midiInStart; external mmsyst name 'midiInStart';
function midiInStop; external mmsyst name 'midiInStop';
function midiInUnprepareHeader; external mmsyst name 'midiInUnprepareHeader';
function midiOutCacheDrumPatches; external mmsyst name 'midiOutCacheDrumPatches';
function midiOutCachePatches; external mmsyst name 'midiOutCachePatches';
function midiOutClose; external mmsyst name 'midiOutClose';
function midiOutGetDevCaps; external mmsyst name 'midiOutGetDevCapsW';
function midiOutGetDevCapsA; external mmsyst name 'midiOutGetDevCapsA';
function midiOutGetDevCapsW; external mmsyst name 'midiOutGetDevCapsW';
function midiOutGetErrorText; external mmsyst name 'midiOutGetErrorTextW';
function midiOutGetErrorTextA; external mmsyst name 'midiOutGetErrorTextA';
function midiOutGetErrorTextW; external mmsyst name 'midiOutGetErrorTextW';
function midiOutGetID; external mmsyst name 'midiOutGetID';
function midiOutGetNumDevs; external mmsyst name 'midiOutGetNumDevs';
function midiOutGetVolume; external mmsyst name 'midiOutGetVolume';
function midiOutLongMsg; external mmsyst name 'midiOutLongMsg';
function midiOutMessage; external mmsyst name 'midiOutMessage';
function midiOutOpen; external mmsyst name 'midiOutOpen';
function midiOutPrepareHeader; external mmsyst name 'midiOutPrepareHeader';
function midiOutReset; external mmsyst name 'midiOutReset';
function midiOutSetVolume; external mmsyst name 'midiOutSetVolume';
function midiOutShortMsg; external mmsyst name 'midiOutShortMsg';
function midiOutUnprepareHeader; external mmsyst name 'midiOutUnprepareHeader';
function midiStreamClose; external mmsyst name 'midiStreamClose';
function midiStreamOpen; external mmsyst name 'midiStreamOpen';
function midiStreamOut; external mmsyst name 'midiStreamOut';
function midiStreamPause; external mmsyst name 'midiStreamPause';
function midiStreamPosition; external mmsyst name 'midiStreamPosition';
function midiStreamProperty; external mmsyst name 'midiStreamProperty';
function midiStreamRestart; external mmsyst name 'midiStreamRestart';
function midiStreamStop; external mmsyst name 'midiStreamStop';
function mixerClose; external mmsyst name 'mixerClose';
function mixerGetControlDetails; external mmsyst name 'mixerGetControlDetailsW';
function mixerGetControlDetailsA; external mmsyst name 'mixerGetControlDetailsA';
function mixerGetControlDetailsW; external mmsyst name 'mixerGetControlDetailsW';
function mixerGetDevCaps; external mmsyst name 'mixerGetDevCapsW';
function mixerGetDevCapsA; external mmsyst name 'mixerGetDevCapsA';
function mixerGetDevCapsW; external mmsyst name 'mixerGetDevCapsW';
function mixerGetID; external mmsyst name 'mixerGetID';
function mixerGetLineControls; external mmsyst name 'mixerGetLineControlsW';
function mixerGetLineControlsA; external mmsyst name 'mixerGetLineControlsA';
function mixerGetLineControlsW; external mmsyst name 'mixerGetLineControlsW';
function mixerGetLineInfo; external mmsyst name 'mixerGetLineInfoW';
function mixerGetLineInfoA; external mmsyst name 'mixerGetLineInfoA';
function mixerGetLineInfoW; external mmsyst name 'mixerGetLineInfoW';
function mixerGetNumDevs; external mmsyst name 'mixerGetNumDevs';
function mixerMessage; external mmsyst name 'mixerMessage';
function mixerOpen; external mmsyst name 'mixerOpen';
function mixerSetControlDetails; external mmsyst name 'mixerSetControlDetails';
function mmioAdvance; external mmsyst name 'mmioAdvance';
function mmioAscend; external mmsyst name 'mmioAscend';
function mmioClose; external mmsyst name 'mmioClose';
function mmioCreateChunk; external mmsyst name 'mmioCreateChunk';
function mmioDescend; external mmsyst name 'mmioDescend';
function mmioFlush; external mmsyst name 'mmioFlush';
function mmioGetInfo; external mmsyst name 'mmioGetInfo';
function mmioInstallIOProc; external mmsyst name 'mmioInstallIOProcW';
function mmioInstallIOProcA; external mmsyst name 'mmioInstallIOProcA';
function mmioInstallIOProcW; external mmsyst name 'mmioInstallIOProcW';
function mmioOpen; external mmsyst name 'mmioOpenW';
function mmioOpenA; external mmsyst name 'mmioOpenA';
function mmioOpenW; external mmsyst name 'mmioOpenW';
function mmioRead; external mmsyst name 'mmioRead';
function mmioRename; external mmsyst name 'mmioRenameW';
function mmioRenameA; external mmsyst name 'mmioRenameA';
function mmioRenameW; external mmsyst name 'mmioRenameW';
function mmioSeek; external mmsyst name 'mmioSeek';
function mmioSendMessage; external mmsyst name 'mmioSendMessage';
function mmioSetBuffer; external mmsyst name 'mmioSetBuffer';
function mmioSetInfo; external mmsyst name 'mmioSetInfo';
function mmioStringToFOURCC; external mmsyst name 'mmioStringToFOURCCW';
function mmioStringToFOURCCA; external mmsyst name 'mmioStringToFOURCCA';
function mmioStringToFOURCCW; external mmsyst name 'mmioStringToFOURCCW';
function mmioWrite; external mmsyst name 'mmioWrite';
function mmsystemGetVersion; external mmsyst name 'mmsystemGetVersion';
function OpenDriver; external mmsyst name 'OpenDriver';
function PlaySound; external mmsyst name 'PlaySoundW';
function PlaySoundA; external mmsyst name 'PlaySoundA';
function PlaySoundW; external mmsyst name 'PlaySoundW';
function SendDriverMessage; external mmsyst name 'SendDriverMessage';
function sndPlaySound; external mmsyst name 'sndPlaySoundW';
function sndPlaySoundA; external mmsyst name 'sndPlaySoundA';
function sndPlaySoundW; external mmsyst name 'sndPlaySoundW';
function timeBeginPeriod; external mmsyst name 'timeBeginPeriod';
function timeEndPeriod; external mmsyst name 'timeEndPeriod';
function timeGetDevCaps; external mmsyst name 'timeGetDevCaps';
function timeGetSystemTime; external mmsyst name 'timeGetSystemTime';
function timeGetTime; external mmsyst name 'timeGetTime';
function timeKillEvent; external mmsyst name 'timeKillEvent';
function timeSetEvent; external mmsyst name 'timeSetEvent';
function waveInAddBuffer; external mmsyst name 'waveInAddBuffer';
function waveInClose; external mmsyst name 'waveInClose';
function waveInGetDevCaps; external mmsyst name 'waveInGetDevCapsW';
function waveInGetDevCapsA; external mmsyst name 'waveInGetDevCapsA';
function waveInGetDevCapsW; external mmsyst name 'waveInGetDevCapsW';
function waveInGetErrorText; external mmsyst name 'waveInGetErrorTextW';
function waveInGetErrorTextA; external mmsyst name 'waveInGetErrorTextA';
function waveInGetErrorTextW; external mmsyst name 'waveInGetErrorTextW';
function waveInGetID; external mmsyst name 'waveInGetID';
function waveInGetNumDevs; external mmsyst name 'waveInGetNumDevs';
function waveInGetPosition; external mmsyst name 'waveInGetPosition';
function waveInMessage; external mmsyst name 'waveInMessage';
function waveInOpen; external mmsyst name 'waveInOpen';
function waveInPrepareHeader; external mmsyst name 'waveInPrepareHeader';
function waveInReset; external mmsyst name 'waveInReset';
function waveInStart; external mmsyst name 'waveInStart';
function waveInStop; external mmsyst name 'waveInStop';
function waveInUnprepareHeader; external mmsyst name 'waveInUnprepareHeader';
function waveOutBreakLoop; external mmsyst name 'waveOutBreakLoop';
function waveOutClose; external mmsyst name 'waveOutClose';
function waveOutGetDevCaps; external mmsyst name 'waveOutGetDevCapsW';
function waveOutGetDevCapsA; external mmsyst name 'waveOutGetDevCapsA';
function waveOutGetDevCapsW; external mmsyst name 'waveOutGetDevCapsW';
function waveOutGetErrorText; external mmsyst name 'waveOutGetErrorTextW';
function waveOutGetErrorTextA; external mmsyst name 'waveOutGetErrorTextA';
function waveOutGetErrorTextW; external mmsyst name 'waveOutGetErrorTextW';
function waveOutGetID; external mmsyst name 'waveOutGetID';
function waveOutGetNumDevs; external mmsyst name 'waveOutGetNumDevs';
function waveOutGetPitch; external mmsyst name 'waveOutGetPitch';
function waveOutGetPlaybackRate; external mmsyst name 'waveOutGetPlaybackRate';
function waveOutGetPosition; external mmsyst name 'waveOutGetPosition';
function waveOutGetVolume; external mmsyst name 'waveOutGetVolume';
function waveOutMessage; external mmsyst name 'waveOutMessage';
function waveOutOpen; external mmsyst name 'waveOutOpen';
function waveOutPause; external mmsyst name 'waveOutPause';
function waveOutPrepareHeader; external mmsyst name 'waveOutPrepareHeader';
function waveOutReset; external mmsyst name 'waveOutReset';
function waveOutRestart; external mmsyst name 'waveOutRestart';
function waveOutSetPitch; external mmsyst name 'waveOutSetPitch';
function waveOutSetPlaybackRate; external mmsyst name 'waveOutSetPlaybackRate';
function waveOutSetVolume; external mmsyst name 'waveOutSetVolume';
function waveOutUnprepareHeader; external mmsyst name 'waveOutUnprepareHeader';
function waveOutWrite; external mmsyst name 'waveOutWrite';

function mci_MSF_Minute(msf: Longint): Byte;
begin
  Result := LoByte(LoWord(msf));
end;

function mci_MSF_Second(msf: Longint): Byte;
begin
  Result := HiByte(LoWord(msf));
end;

function mci_MSF_Frame(msf: Longint): Byte;
begin
  Result := LoByte(HiWord(msf));
end;

function mci_Make_MSF(m, s, f: Byte): Longint;
begin
  Result := Longint(m or (s shl 8) or (f shl 16));
end;

function mci_TMSF_Track(tmsf: Longint): Byte;
begin
  Result := LoByte(LoWord(tmsf));
end;

function mci_TMSF_Minute(tmsf: Longint): Byte;
begin
  Result := HiByte(LoWord(tmsf));
end;

function mci_TMSF_Second(tmsf: Longint): Byte;
begin
  Result := LoByte(HiWord(tmsf));
end;

function mci_TMSF_Frame(tmsf: Longint): Byte;
begin
  Result := HiByte(HiWord(tmsf));
end;

function mci_Make_TMSF(t, m, s, f: Byte): Longint;
begin
  Result := Longint(t or (m shl 8) or (s shl 16) or (f shl 24));
end;

function mci_HMS_Hour(hms: Longint): Byte;
begin
  Result := LoByte(LoWord(hms));
end;

function mci_HMS_Minute(hms: Longint): Byte;
begin
  Result := HiByte(LoWord(hms));
end;

function mci_HMS_Second(hms: Longint): Byte;
begin
  Result := LoByte(HiWord(hms));
end;

function mci_Make_HMS(h, m, s: Byte): Longint;
begin
  Result := Longint(h or (m shl 8) or (s shl 16));
end;

function DIBIndex(N: Integer): Longint;
begin
  Result := MakeLong(N, $10FF);
end;

end.
