unit PhoneNumbers;

interface

uses System.SysUtils, System.StrUtils, WinApi.Windows, Vcl.Dialogs, System.UITypes;

type
  TIsValidNumberFunction = function(phonenumber: WideString; country: WideString): Boolean; stdcall;

function IsValidPhoneNumber(const phonenumber, country: String): Boolean;

implementation

const
  DLLNAME = 'PhoneNumbersUnmanaged.dll';

var
  dll: HMODULE;
  isValidNumberFunction: TIsValidNumberFunction;

function LoadFunctions: Boolean;
begin
  Result := Assigned(isValidNumberFunction);
  if Result then
    Exit;

  if not FileExists(ExtractFilePath(ParamStr(0)) + DLLNAME) then
  begin
    MessageDlg(Format('"%s" not found.', [DLLNAME]) + #10 + ExtractFilePath(ParamStr(0)), mtError, [mbOK], 0);
    Exit(False);
  end;

  dll := LoadLibrary(PChar(ExtractFilePath(ParamStr(0)) + DLLNAME));
  if dll <> 0 then
  begin
    isValidNumberFunction := GetProcAddress(dll, 'isValidNumber');
    Result := Assigned(isValidNumberFunction);
    if not Result then
      MessageDlg(Format('Error loading functions from "%s".', [DLLNAME]) + #10 + ExtractFilePath(ParamStr(0)), mtError,
        [mbOK], 0);
  end
  else
    MessageDlg(Format('Error loading "%s".', [DLLNAME]) + #10 + ExtractFilePath(ParamStr(0)), mtError, [mbOK], 0);
end;

function IsValidPhoneNumber(const phonenumber, country: String): Boolean;
begin
  Result := False;
  if not LoadFunctions then
    Exit;
  Result := isValidNumberFunction(phonenumber, country);
end;

initialization

dll := 0;
isValidNumberFunction := nil;
LoadFunctions;

finalization

if dll <> 0 then
  FreeLibrary(dll);

end.
