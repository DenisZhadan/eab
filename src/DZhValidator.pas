unit DZhValidator;

interface

uses
  SysUtils, System.Character, PhoneNumbers;

type

  TValidator = class
  private
    function CalculateChecksum(const PersonalCode: string): Integer;
  public
    function PersonalCode(const PersonalCode: string; out ErrorMessage: string): Boolean;
    function PostalCode(const PostalCode: string; out ErrorMessage: string): Boolean;
    function NotEmpty(const Value: string; out ErrorMessage: string): Boolean;
    function OnlyDigits(const Value: string; out ErrorMessage: string): Boolean;
    function AlphaChars(const Value: string; out ErrorMessage: string): Boolean;
    function AlphaCharsHyphens(const Value: string; out ErrorMessage: string): Boolean;
    function AlphaCharsHyphensSpaces(const Value: string; out ErrorMessage: string): Boolean;
    function AlphaCharsDotsHyphensSpaces(const Value: string; out ErrorMessage: string): Boolean;
    function AlphaAnsiNumChars(const Value: string; out ErrorMessage: string): Boolean;
    function AlphaAnsiNumCharsHyphensSlashes(const Value: string; out ErrorMessage: string): Boolean;
    function PhoneEstonia(const Value: string; out ErrorMessage: string): Boolean;
  end;

implementation

// The "Isikukood" is the personal identification code used in Estonia. It is also commonly known as the "ID code" or "Estonian personal identification number."
// The Isikukood is a unique 11-digit identifier assigned to individuals in Estonia, including citizens and residents.
// The Isikukood includes information about the person's birthdate and gender, and it is widely used for identification purposes in both public and private sectors.
//
// Format
//
// An Estonian personal identification code comprises 11 digits, typically presented without any spaces or delimiters.
// The format is GYYMMDDSSSC, where G indicates the individual's sex and century of birth
// (odd number for male, even number for female; 1-2 for the 19th century, 3-4 for the 20th century, and 5-6 for the 21st century).
// YY represents the year of birth, MM is the month of birth, DD is the date of birth, SSS is a serial number differentiating individuals born on the same date,
// and C is a checksum.

function TValidator.CalculateChecksum(const PersonalCode: string): Integer;
var
  i, sum, checksum: Integer;
  weights: TArray<Integer>;
  weights2: TArray<Integer>;
begin
  weights := [1, 2, 3, 4, 5, 6, 7, 8, 9, 1];
  weights2 := [3, 4, 5, 6, 7, 8, 9, 1, 2, 3];

  sum := 0;
  for i := 1 to 10 do
    sum := sum + StrToInt(PersonalCode[i]) * weights[i - 1];

  checksum := sum mod 11;

  if checksum = 10 then
  begin
    sum := 0;
    for i := 1 to 10 do
      sum := sum + StrToInt(PersonalCode[i]) * weights2[i - 1];

    checksum := sum mod 11;

    if checksum = 10 then
      checksum := 0;
  end;

  Result := checksum;
end;

function TValidator.PersonalCode(const PersonalCode: string; out ErrorMessage: string): Boolean;
var
  i, century, year, month, day: Integer;
  daysInMonth: TArray<Integer>;
begin
  Result := True;
  if PersonalCode = '' then
    Exit;

  // Check if all characters are digits
  for i := 1 to Length(PersonalCode) do
    if not TCharacter.IsDigit(PersonalCode[i]) then
    begin
      ErrorMessage := 'Must contain only digits.';
      Exit(False);
    end;

  // Check if the length is 11 digits
  if Length(PersonalCode) <> 11 then
  begin
    ErrorMessage := 'Must be 11 digits long.';
    Exit(False);
  end;

  if not(PersonalCode[1] in ['1', '2', '3', '4', '5', '6']) then
  begin
    ErrorMessage := 'Invalid first digit.';
    Exit(False);
  end;

  case PersonalCode[1] of
    '1', '2':
      century := 1800;
    '3', '4':
      century := 1900;
    '5', '6':
      century := 2000;
  else
    century := 0;
  end;

  year := century + StrToInt(Copy(PersonalCode, 2, 2));
  month := StrToInt(Copy(PersonalCode, 4, 2));
  day := StrToInt(Copy(PersonalCode, 6, 2));

  if (month < 1) or (month > 12) then
  begin
    ErrorMessage := 'Incorrect values in positions 4 or 5 (or both).';
    Exit(False);
  end;

  daysInMonth := [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

  if ((year mod 4 = 0) and (year mod 100 <> 0)) or (year mod 400 = 0) then // IsLeapYear
    daysInMonth[2] := 29;

  if (day < 1) or (day > daysInMonth[month - 1]) then
  begin
    ErrorMessage := 'Incorrect values in positions 6 or 7 (or both).';
    Exit(False);
  end;

  Result := CalculateChecksum(PersonalCode) = StrToInt(PersonalCode[11]);

  if not Result then
    ErrorMessage := 'Invalid checksum.';
end;

function TValidator.PostalCode(const PostalCode: string; out ErrorMessage: string): Boolean;
var
  i: Integer;
begin
  Result := True;
  if PostalCode = '' then
    Exit;

  // Check if all characters are digits
  for i := 1 to Length(PostalCode) do
    if not TCharacter.IsDigit(PostalCode[i]) then
    begin
      ErrorMessage := 'Postal code must contain only digits.';
      Exit(False);
    end;

  // Check if the length is 5 digits
  if Length(PostalCode) <> 5 then
  begin
    ErrorMessage := 'Postal code must be 5 digits long.';
    Exit(False);
  end;

  Result := True;
end;

function TValidator.NotEmpty(const Value: string; out ErrorMessage: string): Boolean;
begin
  Result := True;

  if Value = '' then
  begin
    ErrorMessage := 'Can not be empty.';
    Exit(False);
  end;
end;

function TValidator.OnlyDigits(const Value: string; out ErrorMessage: string): Boolean;
var
  i: Integer;
begin
  Result := True;
  if Value = '' then
    Exit;

  for i := 1 to Length(Value) do
    if not TCharacter.IsDigit(Value[i]) then
    begin
      ErrorMessage := 'Must contain only digits.';
      Exit(False);
    end;
end;

function TValidator.AlphaChars(const Value: string; out ErrorMessage: string): Boolean;
var
  i: Integer;
begin
  Result := True;
  if Value = '' then
    Exit;

  for i := 1 to Length(Value) do
    if not TCharacter.IsLetter(Value[i]) then
    begin
      ErrorMessage := 'Can only contain letters.';
      Exit(False);
    end;

end;

function TValidator.AlphaCharsHyphens(const Value: string; out ErrorMessage: string): Boolean;
var
  i: Integer;
begin
  Result := True;
  if Value = '' then
    Exit;

  for i := 1 to Length(Value) do
    if not TCharacter.IsLetter(Value[i]) and not CharInSet(Value[i], ['-']) then
    begin
      ErrorMessage := 'Can only contain letters and hyphens.';
      Exit(False);
    end;
end;

function TValidator.AlphaCharsHyphensSpaces(const Value: string; out ErrorMessage: string): Boolean;
var
  i: Integer;
begin
  Result := True;
  if Value = '' then
    Exit;

  for i := 1 to Length(Value) do
    if not TCharacter.IsLetter(Value[i]) and not CharInSet(Value[i], ['-', ' ']) then
    begin
      ErrorMessage := 'Can only contain letters, hyphens, and spaces.';
      Exit(False);
    end;
end;

function TValidator.AlphaCharsDotsHyphensSpaces(const Value: string; out ErrorMessage: string): Boolean;
var
  i: Integer;
begin
  Result := True;
  if Value = '' then
    Exit;

  for i := 1 to Length(Value) do
    if not TCharacter.IsLetter(Value[i]) and not CharInSet(Value[i], ['.', '-', ' ']) then
    begin
      ErrorMessage := 'Can only contain letters, dots, hyphens, and spaces.';
      Exit(False);
    end;
end;

function TValidator.AlphaAnsiNumChars(const Value: string; out ErrorMessage: string): Boolean;
var
  i: Integer;
begin
  Result := True;
  if Value = '' then
    Exit;

  for i := 1 to Length(Value) do
    if not CharInSet(Value[i], ['0' .. '9', 'A' .. 'Z', 'a' .. 'z']) then
    begin
      ErrorMessage := 'Can only contain letters and numbers.';
      Exit(False);
    end;
end;

function TValidator.AlphaAnsiNumCharsHyphensSlashes(const Value: string; out ErrorMessage: string): Boolean;
var
  i: Integer;
begin
  Result := True;
  if Value = '' then
    Exit;

  for i := 1 to Length(Value) do
    if not CharInSet(Value[i], ['0' .. '9', 'A' .. 'Z', 'a' .. 'z', '-', '/']) then
    begin
      ErrorMessage := 'Can only contain letters, numbers, hyphens, and slashes.';
      Exit(False);
    end;
end;

function TValidator.PhoneEstonia(const Value: string; out ErrorMessage: string): Boolean;
var
  i: Integer;
begin
  Result := True;
  if Value = '' then
    Exit;

  Result := IsValidPhoneNumber(Value, 'EE');

  if not Result then
    ErrorMessage := 'Invalid phone number.';
end;

end.
