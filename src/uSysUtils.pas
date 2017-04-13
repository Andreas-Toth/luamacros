unit uSysUtils;

// Some of this is based on code found at...
//   http://stackoverflow.com/questions/22285024/how-to-get-a-systems-process-path-from-pid-in-a-64-bit-system/22286210

{$mode delphi}

interface

uses
  Windows;

function GetProcessIDFileName(const AProcessID: Cardinal): UnicodeString;
function GetForegroundWindowFileName: UnicodeString;

function GetTempPath: UnicodeString;

function IsWindows2kOrLater: Boolean;
function IsWindowsVistaOrLater: Boolean;

implementation

uses
  SysUtils;

type
  TQueryFullProcessImageNameW = function(AProcess: THANDLE; AFlags: DWORD; AFileName: PWideChar; var ASize: DWORD): BOOL; stdcall;
  TGetModuleFileNameExW = function(AProcess: THANDLE; AModule: HMODULE; AFilename: PWideChar; ASize: DWORD): DWORD; stdcall;

var
  GPsapiLib: THandle;
  GGetModuleFileNameExW: TGetModuleFileNameExW;

function IsWindows2kOrLater: Boolean;
begin
  Result := Win32MajorVersion >= 5;
end;

function IsWindowsVistaOrLater: Boolean;
begin
  Result := Win32MajorVersion >= 6;
end;

function GetForegroundWindowFileName: UnicodeString;
var
  LHandle: THandle;
  LPID: Cardinal;
begin
  LHandle := GetForegroundWindow;

  if LHandle = 0 then
  begin
    RaiseLastOSError;
  end;

  LPID := 0;
  GetWindowThreadProcessId(LHandle, LPID);

  if LPID = 0 then
  begin
    RaiseLastOSError;
  end;

  Result := GetProcessIDFileName(LPID);
end;

function GetTempPath: UnicodeString;
var
  LSize: Cardinal;
begin
  LSize := MAX_PATH;
  SetLength(Result, LSize + 1);

  if Windows.GetTempPathW(LSize, PWideChar(Result)) = 0 then
  begin
    RaiseLastOSError;
  end;

  Result := PWideChar(Result);
end;

procedure DonePsapiLib;
begin
  if GPsapiLib = 0 then
  begin
    Exit; // ==>
  end;

  FreeLibrary(GPsapiLib);
  GPsapiLib := 0;
  @GGetModuleFileNameExW := nil;
end;

procedure InitPsapiLib;
begin
  if GPsapiLib <> 0 then
  begin
    Exit; // ==>
  end;

  GPsapiLib := LoadLibrary('psapi.dll');

  if GPsapiLib = 0 then
  begin
    RaiseLastOSError;
  end;

  @GGetModuleFileNameExW := GetProcAddress(GPsapiLib, 'GetModuleFileNameExW');

  if not Assigned(GGetModuleFileNameExW) then
  try
    RaiseLastOSError;
  except
    DonePsapiLib;
    raise;
  end;
end;

function GetProcessIDFileName(const AProcessID: Cardinal): UnicodeString;
const
  PROCESS_QUERY_LIMITED_INFORMATION = $00001000; // Vista and above
var
  LProcess: THandle;
  LLib: THandle;
  LQueryFullProcessImageNameW: TQueryFullProcessImageNameW;
  LSize: Cardinal;
begin
  if IsWindowsVistaOrLater then
  begin
    LLib := GetModuleHandle('kernel32.dll');

    if LLib = 0 then
    begin
      RaiseLastOSError;
    end;

    @LQueryFullProcessImageNameW := GetProcAddress(LLib, 'QueryFullProcessImageNameW');

    if not Assigned(LQueryFullProcessImageNameW) then
    begin
      RaiseLastOSError;
    end;

    LProcess := OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, False, AProcessID);

    if LProcess = 0 then
    begin
      RaiseLastOSError;
    end;

    try
      LSize := MAX_PATH;
      SetLength(Result, LSize + 1);

      while not LQueryFullProcessImageNameW(LProcess, 0, PWideChar(Result), LSize) and (GetLastError = ERROR_INSUFFICIENT_BUFFER) do
      begin
        LSize := LSize * 2;
        SetLength(Result, LSize + 1);
      end;

      SetLength(Result, LSize);
      Inc(LSize);

      if not LQueryFullProcessImageNameW(LProcess, 0, PWideChar(Result), LSize) then
      begin
        RaiseLastOSError;
      end;
    finally
      CloseHandle(LProcess);
    end;
  end
  else if IsWindows2kOrLater then
  begin
    InitPsapiLib;

    LProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, AProcessID);

    if LProcess = 0 then
    begin
      RaiseLastOSError;
    end;

    try
      LSize := MAX_PATH;
      SetLength(Result, LSize + 1);

      if GGetModuleFileNameExW(LProcess, 0, PWideChar(Result), LSize) = 0 then
      begin
        RaiseLastOSError;
      end;

      Result := PWideChar(Result);
    finally
      CloseHandle(LProcess);
    end;
  end
  else begin
    raise Exception.Create('Unhandled Windows version!');
  end;
end;


initialization
  GPsapiLib := 0;
  @GGetModuleFileNameExW := nil;

finalization
  DonePsapiLib;

end.
