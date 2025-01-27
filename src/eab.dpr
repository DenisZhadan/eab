program eab;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {MainForm},
  Unit2 in 'Unit2.pas' {UserForm},
  DZhTypes in 'DZhTypes.pas',
  DZhValidator in 'DZhValidator.pas',
  PhoneNumbers in 'PhoneNumbers.pas',
  Unit3 in 'Unit3.pas' {Form3};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Estonian address book';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TUserForm, UserForm);
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.
