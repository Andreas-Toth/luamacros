unit uWHookInt;

// TODO: Replace hardcoded log file name with configurable string

{$mode delphi}

interface

uses
  Windows, SysUtils, uHookCommon;

function MsgFilterFuncKbd(Code: longint; wParam: WPARAM; lParam: LPARAM): LRESULT stdcall; export;

implementation

uses
  MemMap,
  uSysUtils;

//const
//  WH_KEYBOARD_LL = 13;

//type
// PKBDLLHookStruct = ^TKBDLLHookStruct;
// {$EXTERNALSYM tagKBDLLHOOKSTRUCT}
// tagKBDLLHOOKSTRUCT = packed record
//   vkCode: DWORD;
//   scanCode: DWORD;
//   flags: DWORD;
//   time: DWORD;
//   dwExtraInfo: PULONG;
// end;
// TKBDLLHookStruct = tagKBDLLHOOKSTRUCT;
// {$EXTERNALSYM KBDLLHOOKSTRUCT}
// KBDLLHOOKSTRUCT = tagKBDLLHOOKSTRUCT;

// ULONG_PTR = ^DWORD;

// Actual hook stuff

//type
//  TPMsg = ^TMsg;

//const
//  VK_D = $44;
//  VK_E = $45;
//  VK_F = $46;
//  VK_M = $4D;
//  VK_R = $52;

var
  // Global variables only valid in the process which installs the hook
  gMemMap: TMemMap;
  gSharedPtr: PMMFData;
  gPid: DWORD;

{
  The SetWindowsHookEx function installs an application-defined
  hook procedure into a hook chain.

  WH_GETMESSAGE Installs a hook procedure that monitors messages
  posted to a message queue.
  For more information, see the GetMsgProc hook procedure.
}

procedure DebugLog(Value: String);
const
  CFileName: UnicodeString = 'LmcDll.log';
var
  LLogFile: UnicodeString;
  lFile: TextFile;
  lDebug: Boolean;
begin
  lDebug:= false and ((gSharedPtr <> nil) and (gSharedPtr^.Debug > 0));

  if lDebug then
  begin
    LLogFile := USysUtils.GetTempPath + CFileName;

    AssignFile(lFile, LLogFile);

    if FileExists(LLogFile) then
      Append(lFile)
    else
      Rewrite(lFile);

    Write(lFile, Format('%s [DLL]: %s', [FormatDateTime('yyyy-mm-dd hh:nn:ss:zzz', Now), Value]));
    WriteLn(lFile);
    CloseFile(lFile);
  end;
end;

(*
    GetMsgProc(
    nCode: Integer;  {the hook code}
    wParam: WPARAM;  {message removal flag}
    lParam: LPARAM  {a pointer to a TMsg structure}
    ): LRESULT;  {this function should always return zero}

    { See help on ==> GetMsgProc}
*)

function MsgFilterFuncKbd(Code: longint; wParam: WPARAM; lParam: LPARAM): LRESULT stdcall;
var
  Kill: boolean;
  what2do : Integer;
begin
  DebugLog(Format('Code %d, lpar (vk_code) %d, flag %d', [Code, wParam, lParam]));
  if (Code < 0) or (Code <> HC_ACTION) or (gSharedPtr = nil) then
  begin
    Result := CallNextHookEx(gSharedPtr^.HookKbd, Code, wParam, lParam);
    exit;
  end;
  Result := 0;
  Kill := False;
  what2do := SendMessage(gSharedPtr^.MainWinHandle, WM_ASKLMCFORM, wParam , lParam);
  if (what2do = -1) then
    Kill := True;
  if Kill then
    Result := 1
  else
    Result := CallNextHookEx(gSharedPtr^.HookKbd, Code, wParam, lParam);
end;


initialization
  gMemMap := nil;
  gPid := GetCurrentProcessId;
  gSharedPtr := nil;
  try
    gMemMap := TMemMap.Create(MMFName, SizeOf(TMMFData), False);
  except
    on E: Exception do
    begin
      DebugLog(IntToStr(gPid)+': Error creating MMF (' + E.Message + ').');
      raise;
    end;
  end;

  gSharedPtr := gMemMap.Memory;


finalization
  if Assigned(gMemMap) then
  try
    FreeAndNil(gMemMap);
  except
    on E: Exception do
    begin
      DebugLog(IntToStr(gPid)+': Error destroying MMF (' + E.Message + ').');
      raise;
    end;
  end;

end.
