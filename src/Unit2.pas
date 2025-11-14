unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, DZhTypes, DZhValidator, Unit3;

type
  TUserForm = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    edtPersonalCode: TEdit;
    warningPersonalCode: TLabel;
    Panel2: TPanel;
    Label3: TLabel;
    warningLastName: TLabel;
    edtLastName: TEdit;
    Panel3: TPanel;
    Label2: TLabel;
    warningFirstName: TLabel;
    edtFirstName: TEdit;
    Panel4: TPanel;
    Label9: TLabel;
    warningApartment: TLabel;
    edtApartment: TEdit;
    Panel5: TPanel;
    Label8: TLabel;
    warningHouse: TLabel;
    edtHouse: TEdit;
    Panel6: TPanel;
    Label7: TLabel;
    warningStreet: TLabel;
    edtStreet: TEdit;
    Panel7: TPanel;
    Label6: TLabel;
    warningAdministrativeUnit: TLabel;
    edtAdministrativeUnit: TEdit;
    Panel8: TPanel;
    Label5: TLabel;
    warningCounty: TLabel;
    edtCounty: TEdit;
    Panel9: TPanel;
    Label4: TLabel;
    warningCountry: TLabel;
    edtCountry: TEdit;
    Panel10: TPanel;
    Label11: TLabel;
    warningPhone: TLabel;
    edtPhone: TEdit;
    Panel11: TPanel;
    Label10: TLabel;
    warningPostalCode: TLabel;
    edtPostalCode: TEdit;
    Panel12: TPanel;
    btnConfirm: TButton;
    btnCancel: TButton;
    Panel13: TPanel;
    Label12: TLabel;
    warningSettlementUnit: TLabel;
    edtSettlementUnit: TEdit;
    Button1: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure edtPersonalCodeChange(Sender: TObject);
    procedure edtFirstNameChange(Sender: TObject);
    procedure edtLastNameChange(Sender: TObject);
    procedure edtCountryChange(Sender: TObject);
    procedure btnConfirmClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure edtCountyChange(Sender: TObject);
    procedure edtAdministrativeUnitChange(Sender: TObject);
    procedure edtStreetChange(Sender: TObject);
    procedure edtHouseChange(Sender: TObject);
    procedure edtApartmentChange(Sender: TObject);
    procedure edtPostalCodeChange(Sender: TObject);
    procedure edtPhoneChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure edtSettlementUnitChange(Sender: TObject);
  private
    FValidator: TValidator;
    FValidFields: TArray<Boolean>;
    procedure InitEditField(EditField: TEdit; const NewValue: string);
    { Private declarations }
  public
    User: TUSer;
    { Public declarations }
  end;

var
  UserForm: TUserForm;

implementation

{$R *.dfm}

procedure UpdateEditAppearance(edit: TEdit; isValid: Boolean);
begin
  if isValid then
  begin
    edit.Color := clWindow;
    edit.Font.Color := clWindowText;
  end
  else
  begin
    edit.Color := clRed;
    edit.Font.Color := clWhite;
  end;
end;

function ValidateAndUpdateAppearance(EditControl: TEdit; WarningLabel: TLabel;
  ValidatorFuncs: array of TValidatorFunc): Boolean;
var
  i: Integer;
  errorMessage: string;
begin
  Result := True;
  EditControl.Hint := '';
  WarningLabel.Visible := False;

  for i := 0 to High(ValidatorFuncs) do
    if not ValidatorFuncs[i](EditControl.Text, errorMessage) then
    begin
      Result := False;
      EditControl.Hint := errorMessage;
      WarningLabel.Caption := errorMessage;
      WarningLabel.Visible := True;
      break;
    end;

  UpdateEditAppearance(EditControl, Result);
  EditControl.ShowHint := not Result;
end;

procedure TUserForm.FormCreate(Sender: TObject);
begin
  FValidator := TValidator.Create;
  SetLength(FValidFields, High(ColumnNames) + 1);
end;

procedure TUserForm.FormDestroy(Sender: TObject);
begin
  FValidator.Free;
  FValidator := nil;
end;

procedure TUserForm.InitEditField(EditField: TEdit; const NewValue: string);
begin
  if EditField.Text <> NewValue then
    EditField.Text := NewValue
  else
    EditField.OnChange(EditField);
end;

procedure TUserForm.FormShow(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to High(ColumnNames) do
    FValidFields[i] := False;

  InitEditField(edtPersonalCode, User.PersonalCode);

  InitEditField(edtFirstName, User.FirstName);
  InitEditField(edtLastName, User.LastName);

  InitEditField(edtCountry, 'Estonia'); // User.Country;
  InitEditField(edtCounty, User.County);
  InitEditField(edtAdministrativeUnit, User.AdministrativeUnit);
  InitEditField(edtSettlementUnit, User.SettlementUnit);
  InitEditField(edtStreet, User.Street);
  InitEditField(edtHouse, User.House);
  InitEditField(edtApartment, User.Apartment);
  InitEditField(edtPostalCode, User.PostalCode);

  InitEditField(edtPhone, User.Phone);
end;

procedure TUserForm.edtPersonalCodeChange(Sender: TObject);
begin
  FValidFields[0] := ValidateAndUpdateAppearance(edtPersonalCode, warningPersonalCode,
    [FValidator.NotEmpty, FValidator.PersonalCode]);
end;

procedure TUserForm.edtFirstNameChange(Sender: TObject);
begin
  FValidFields[1] := ValidateAndUpdateAppearance(edtFirstName, warningFirstName,
    [FValidator.NotEmpty, FValidator.AlphaCharsHyphensSpaces]);
end;

procedure TUserForm.edtLastNameChange(Sender: TObject);
begin
  FValidFields[2] := ValidateAndUpdateAppearance(edtLastName, warningLastName,
    [FValidator.NotEmpty, FValidator.AlphaCharsHyphensSpaces]);
end;

procedure TUserForm.edtCountryChange(Sender: TObject);
begin
  FValidFields[3] := ValidateAndUpdateAppearance(edtCountry, warningCountry, [FValidator.NotEmpty]);
end;

procedure TUserForm.edtCountyChange(Sender: TObject);
begin
  FValidFields[4] := ValidateAndUpdateAppearance(edtCounty, warningCounty,
    [FValidator.NotEmpty, FValidator.AlphaCharsHyphensSpaces]);
end;

procedure TUserForm.edtAdministrativeUnitChange(Sender: TObject);
begin
  FValidFields[5] := ValidateAndUpdateAppearance(edtAdministrativeUnit, warningAdministrativeUnit,
    [FValidator.NotEmpty, FValidator.AlphaCharsHyphensSpaces]);
end;

procedure TUserForm.edtSettlementUnitChange(Sender: TObject);
begin
  FValidFields[6] := ValidateAndUpdateAppearance(edtSettlementUnit, warningSettlementUnit,
    [FValidator.AlphaCharsHyphensSpaces]);
end;

procedure TUserForm.edtStreetChange(Sender: TObject);
begin
  FValidFields[7] := ValidateAndUpdateAppearance(edtStreet, warningStreet,
    [FValidator.NotEmpty, FValidator.AlphaCharsDotsHyphensSpaces]);
end;

procedure TUserForm.edtHouseChange(Sender: TObject);
begin
  FValidFields[8] := ValidateAndUpdateAppearance(edtHouse, warningHouse,
    [FValidator.NotEmpty, FValidator.AlphaAnsiNumCharsHyphensSlashes]);
end;

procedure TUserForm.edtApartmentChange(Sender: TObject);
begin
  FValidFields[9] := ValidateAndUpdateAppearance(edtApartment, warningApartment, [FValidator.AlphaAnsiNumChars]);
end;

procedure TUserForm.edtPostalCodeChange(Sender: TObject);
begin
  FValidFields[10] := ValidateAndUpdateAppearance(edtPostalCode, warningPostalCode,
    [FValidator.NotEmpty, FValidator.PostalCode]);
end;

procedure TUserForm.edtPhoneChange(Sender: TObject);
begin
  FValidFields[11] := ValidateAndUpdateAppearance(edtPhone, warningPhone, [FValidator.PhoneEstonia]);
end;

procedure TUserForm.btnConfirmClick(Sender: TObject);
var
  i: Integer;
  isCorrect: Boolean;
begin
  isCorrect := True;
  for i := 0 to High(FValidFields) do
    isCorrect := isCorrect and FValidFields[i];
  if isCorrect then
  begin
    User.PersonalCode := edtPersonalCode.Text;
    User.FirstName := edtFirstName.Text;
    User.LastName := edtLastName.Text;

    User.Country := edtCountry.Text;
    User.County := edtCounty.Text;
    User.AdministrativeUnit := edtAdministrativeUnit.Text;
    User.SettlementUnit := edtSettlementUnit.Text;
    User.Street := edtStreet.Text;
    User.House := edtHouse.Text;
    User.Apartment := edtApartment.Text;
    User.PostalCode := edtPostalCode.Text;

    User.Phone := edtPhone.Text;
    self.ModalResult := mrOk;
  end
  else
    ShowMessage('Please check your data and confirm again.');
end;

procedure TUserForm.Button1Click(Sender: TObject);
begin
  if Form3.ShowModal = mrOk then
  begin
    edtCounty.Text:= Form3.StringGrid1.Cells[0, Form3.StringGrid1.Row];
    edtAdministrativeUnit.Text:= Form3.StringGrid1.Cells[1, Form3.StringGrid1.Row];
    edtSettlementUnit.Text := Form3.StringGrid1.Cells[2, Form3.StringGrid1.Row];
    edtStreet.Text:= Form3.StringGrid1.Cells[3, Form3.StringGrid1.Row];
    edtHouse.Text:= Form3.StringGrid1.Cells[4, Form3.StringGrid1.Row];
    edtApartment.Text:= Form3.StringGrid1.Cells[5, Form3.StringGrid1.Row];
    edtPostalCode.Text:= Form3.StringGrid1.Cells[6, Form3.StringGrid1.Row];
  end;
end;

procedure TUserForm.btnCancelClick(Sender: TObject);
begin
  self.ModalResult := mrCancel;
end;

end.
