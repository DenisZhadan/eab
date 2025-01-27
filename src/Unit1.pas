unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.ExtCtrls, Vcl.StdCtrls, System.JSON,
  Vcl.Menus, TypInfo, System.ImageList, Vcl.ImgList, Vcl.Buttons, RegularExpressions,
  unit2, DZhTypes, Vcl.ComCtrls;

type
  TMainForm = class(TForm)
    Panel1: TPanel;
    StringGrid1: TStringGrid;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    New1: TMenuItem;
    Open1: TMenuItem;
    Save1: TMenuItem;
    SaveAs1: TMenuItem;
    Exit1: TMenuItem;
    N1: TMenuItem;
    Panel2: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Image1: TImage;
    ImageList1: TImageList;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton7: TSpeedButton;
    StatusBar1: TStatusBar;
    GroupBox1: TGroupBox;
    btnApplyFilter: TButton;
    Label1: TLabel;
    edtFilterPersonalCode: TEdit;
    Label2: TLabel;
    edtFilterFirstName: TEdit;
    edtFilterLastName: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    edtFilterCountry: TEdit;
    Label5: TLabel;
    edtFilterCounty: TEdit;
    Label6: TLabel;
    edtFilterAdministrativeUnit: TEdit;
    Label7: TLabel;
    edtFilterStreet: TEdit;
    Label8: TLabel;
    edtFilterHouse: TEdit;
    Label9: TLabel;
    edtFilterApartment: TEdit;
    Label10: TLabel;
    edtFilterPostalCode: TEdit;
    Label11: TLabel;
    edtFilterPhone: TEdit;
    btnClearFilter: TButton;
    edtFilterSettlementUnit: TEdit;
    Label12: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnApplyFilterClick(Sender: TObject);
    procedure StringGrid1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure StringGrid1SelectCell(Sender: TObject; ACol, ARow: LongInt; var CanSelect: Boolean);
    procedure FormResize(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; ACol, ARow: LongInt; Rect: TRect; State: TGridDrawState);
    procedure Exit1Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure New1Click(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure SaveAs1Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure SpeedButton7Click(Sender: TObject);
    procedure btnClearFilterClick(Sender: TObject);

  const
    cColorForEvenRows = clWhite;
    cColorForOddRows = $00F2F2F2;
  private
    FFileName: string;
    FUsers: array of TUser;
    FFilter: TUser;
    FEdtFilters: array of TEdit;
    procedure LoadDataFromFile(FileName: string);
    procedure SaveDataToFile(FileName: string);
    procedure LoadTestData;
    function MatchesFilter(const Name, Filter: string): Boolean;
    procedure DisplayData;
    procedure SetFilter();
    procedure ClearFilter();

    procedure SortGrid(Column: Integer);
    procedure AdjustColumnWidths;
    function GetActiveRecordId(): Integer;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.AdjustColumnWidths;
var
  i, totalWidth, columnWidth: Integer;
begin
  totalWidth := StringGrid1.ClientWidth;
  columnWidth := totalWidth div StringGrid1.ColCount;

  for i := 0 to StringGrid1.ColCount - 1 do
  begin
    StringGrid1.ColWidths[i] := columnWidth;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  FFileName := 'users.json';

  FEdtFilters := [edtFilterPersonalCode, edtFilterFirstName, edtFilterLastName, edtFilterCountry, edtFilterCounty,
    edtFilterAdministrativeUnit, edtFilterSettlementUnit, edtFilterStreet, edtFilterHouse, edtFilterApartment,
    edtFilterPostalCode, edtFilterPhone];
  ClearFilter();

  for i := 0 to High(ColumnNames) do
  begin
    StringGrid1.Cells[i, 0] := ColumnNames[i];
  end;

  if not FileExists(FFileName) then
    LoadTestData
  else
    LoadDataFromFile(FFileName);

  AdjustColumnWidths;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  AdjustColumnWidths;
end;

procedure TMainForm.LoadTestData;
begin
  SetLength(FUsers, 4);
  FUsers[0].PersonalCode := '45002159997';
  FUsers[0].FirstName := 'Cinderella';
  FUsers[0].LastName := 'Ella Tremaine';
  FUsers[0].Country := 'Estonia';
  FUsers[0].County := 'Harju maakond';
  FUsers[0].AdministrativeUnit := 'Tallinn';
  FUsers[0].SettlementUnit := 'Kesklinna linnaosa';
  FUsers[0].Street := 'Pikk tn';
  FUsers[0].House := '70';
  FUsers[0].Apartment := '';
  FUsers[0].PostalCode := '10133';
  FUsers[0].Phone := '';

  FUsers[1].PersonalCode := '43712219996';
  FUsers[1].FirstName := 'Snow';
  FUsers[1].LastName := 'White';
  FUsers[1].Country := 'Estonia';
  FUsers[1].County := 'Harju maakond';
  FUsers[1].AdministrativeUnit := 'Tallinn';
  FUsers[1].SettlementUnit := 'Haabersti linnaosa';
  FUsers[1].Street := 'Vabaõhumuuseumi tee';
  FUsers[1].House := '12/1';
  FUsers[1].Apartment := '';
  FUsers[1].PostalCode := '13521';
  FUsers[1].Phone := '';

  FUsers[2].PersonalCode := '30212279994';
  FUsers[2].FirstName := 'Peter';
  FUsers[2].LastName := 'Pan';
  FUsers[2].Country := 'Estonia';
  FUsers[2].County := 'Harju maakond';
  FUsers[2].AdministrativeUnit := 'Tallinn';
  FUsers[2].SettlementUnit := 'Kesklinna linnaosa';
  FUsers[2].Street := 'A. Weizenbergi tn';
  FUsers[2].House := '34';
  FUsers[2].Apartment := '';
  FUsers[2].PostalCode := '10127';
  FUsers[2].Phone := '';

  FUsers[3].PersonalCode := '25205049992';
  FUsers[3].FirstName := 'Alice';
  FUsers[3].LastName := 'Pleasance Liddell';
  FUsers[3].Country := 'Estonia';
  FUsers[3].County := 'Harju maakond';
  FUsers[3].AdministrativeUnit := 'Tallinn';
  FUsers[3].SettlementUnit := 'Põhja-Tallinna linnaosa';
  FUsers[3].Street := 'Vesilennuki tn';
  FUsers[3].House := '1';
  FUsers[3].Apartment := '';
  FUsers[3].PostalCode := '10415';
  FUsers[3].Phone := '';

  DisplayData;
end;

function TMainForm.MatchesFilter(const Name, Filter: string): Boolean;
var
  Pattern: string;
begin
  if (Filter = '') or (Filter = '*') then
    Result := True
  else
  begin
    Pattern := '^' + StringReplace(Filter, '*', '.*', [rfReplaceAll]) + '$';
    Result := TRegEx.IsMatch(Name, Pattern, [roIgnoreCase]);
  end;
end;

procedure TMainForm.DisplayData;
var
  i, Row: Integer;
begin
  Row := 1;

  for i := 0 to High(FUsers) do
    if MatchesFilter(FUsers[i].PersonalCode, FFilter.PersonalCode) and
      MatchesFilter(FUsers[i].FirstName, FFilter.FirstName) and MatchesFilter(FUsers[i].LastName, FFilter.LastName) and
      MatchesFilter(FUsers[i].Country, FFilter.Country) and MatchesFilter(FUsers[i].County, FFilter.County) and
      MatchesFilter(FUsers[i].AdministrativeUnit, FFilter.AdministrativeUnit) and
      MatchesFilter(FUsers[i].SettlementUnit, FFilter.SettlementUnit) and
      MatchesFilter(FUsers[i].Street, FFilter.Street) and MatchesFilter(FUsers[i].House, FFilter.House) and
      MatchesFilter(FUsers[i].Apartment, FFilter.Apartment) and MatchesFilter(FUsers[i].PostalCode, FFilter.PostalCode)
      and MatchesFilter(FUsers[i].Phone, FFilter.Phone) then
    begin
      StringGrid1.Cells[0, Row] := FUsers[i].PersonalCode;
      StringGrid1.Cells[1, Row] := FUsers[i].FirstName;
      StringGrid1.Cells[2, Row] := FUsers[i].LastName;
      StringGrid1.Cells[3, Row] := FUsers[i].Country;
      StringGrid1.Cells[4, Row] := FUsers[i].County;
      StringGrid1.Cells[5, Row] := FUsers[i].AdministrativeUnit;
      StringGrid1.Cells[6, Row] := FUsers[i].SettlementUnit;
      StringGrid1.Cells[7, Row] := FUsers[i].Street;
      StringGrid1.Cells[8, Row] := FUsers[i].House;
      StringGrid1.Cells[9, Row] := FUsers[i].Apartment;
      StringGrid1.Cells[10, Row] := FUsers[i].PostalCode;
      StringGrid1.Cells[11, Row] := FUsers[i].Phone;
      StringGrid1.Objects[0, Row] := TObject(i);
      Inc(Row);
    end;

  StringGrid1.RowCount := Row;
  StatusBar1.Panels[0].Text := 'Total: ' + IntToStr(High(FUsers) + 1);
  StatusBar1.Panels[1].Text := 'Matched: ' + IntToStr(Row - 1);
  StatusBar1.Panels[2].Text := 'Not Matched: ' + IntToStr(High(FUsers) + 2 - Row);

  if StringGrid1.RowCount = 1 then
    StringGrid1.Row := 0
  else if (StringGrid1.Row = 0) and (StringGrid1.RowCount > 1) then
    StringGrid1.Row := 1
  else if StringGrid1.RowCount < StringGrid1.Row then
    StringGrid1.Row := 1
  else if StringGrid1.RowCount = StringGrid1.Row then
    StringGrid1.Row := StringGrid1.Row - 1;
end;

procedure TMainForm.StringGrid1DrawCell(Sender: TObject; ACol, ARow: LongInt; Rect: TRect; State: TGridDrawState);
begin
  if ARow = 0 then
  begin
    StringGrid1.Canvas.Brush.Color := clBlack;
    StringGrid1.Canvas.Font.Color := clWhite;
  end
  else if gdSelected in State then
  begin
    StringGrid1.Canvas.Brush.Color := clMaroon;
    StringGrid1.Canvas.Font.Color := clHighlightText;
  end
  else
  begin
    if ARow mod 2 = 0 then
      StringGrid1.Canvas.Brush.Color := cColorForEvenRows
    else
      StringGrid1.Canvas.Brush.Color := cColorForOddRows;
    StringGrid1.Canvas.Font.Color := clWindowText;
  end;
  StringGrid1.Canvas.FillRect(Rect);
  StringGrid1.Canvas.TextOut(Rect.Left + 2, Rect.Top + 2, StringGrid1.Cells[ACol, ARow]);
end;

procedure TMainForm.SortGrid(Column: Integer);
begin
  // Implement sorting logic
end;

procedure TMainForm.StringGrid1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  col, Row: Integer;
begin
  StringGrid1.MouseToCell(X, Y, col, Row);
  if Row = 0 then
  begin
    SortGrid(col);
  end;
end;

procedure TMainForm.StringGrid1SelectCell(Sender: TObject; ACol, ARow: LongInt; var CanSelect: Boolean);
begin
  //
end;

procedure TMainForm.SpeedButton1Click(Sender: TObject);
begin
  if StringGrid1.RowCount > 1 then
    StringGrid1.Row := 1
  else
    StringGrid1.Row := 0;
end;

procedure TMainForm.SpeedButton2Click(Sender: TObject);
begin
  if StringGrid1.Row > 1 then
    StringGrid1.Row := StringGrid1.Row - 1;
end;

procedure TMainForm.SpeedButton3Click(Sender: TObject);
begin
  if StringGrid1.Row < StringGrid1.RowCount - 1 then
    StringGrid1.Row := StringGrid1.Row + 1;
end;

procedure TMainForm.SpeedButton4Click(Sender: TObject);
begin
  StringGrid1.Row := StringGrid1.RowCount - 1;
end;

procedure TMainForm.SpeedButton5Click(Sender: TObject);
var
  newUser: TUser;
begin
  UserForm.User := newUser;
  if UserForm.ShowModal = mrOk then
  begin
    SetLength(FUsers, Length(FUsers) + 1);
    FUsers[High(FUsers)] := UserForm.User;
    DisplayData;
  end;
end;

function TMainForm.GetActiveRecordId(): Integer;
begin
  Result := Integer(StringGrid1.Objects[0, StringGrid1.Row]);
end;

procedure TMainForm.SpeedButton6Click(Sender: TObject);
var
  i, n: Integer;
begin
  n := GetActiveRecordId();
  if Length(FUsers) < n then
    exit;

  for i := n to High(FUsers) - 1 do
    FUsers[i] := FUsers[i + 1];

  SetLength(FUsers, Length(FUsers) - 1);
  DisplayData;
end;

procedure TMainForm.SpeedButton7Click(Sender: TObject);
begin
  UserForm.User := FUsers[GetActiveRecordId()];
  if UserForm.ShowModal = mrOk then
  begin
    FUsers[GetActiveRecordId()] := UserForm.User;
    DisplayData;
  end;
end;

procedure TMainForm.btnApplyFilterClick(Sender: TObject);
begin
  SetFilter();
  DisplayData;
end;

procedure TMainForm.New1Click(Sender: TObject);
begin
  SetLength(FUsers, 0);
  DisplayData;
end;

procedure TMainForm.Open1Click(Sender: TObject);
begin
  if OpenDialog1.InitialDir = '' then
    OpenDialog1.InitialDir := ExtractFileDir(paramstr(0));
  if OpenDialog1.Execute then
    LoadDataFromFile(OpenDialog1.FileName);
end;

procedure TMainForm.LoadDataFromFile(FileName: string);
var
  fileStream: TFileStream;
  jsonString: string;
  jsonArray: TJSONArray;
  jsonObject: TJSONObject;
  i: Integer;
begin

  fileStream := TFileStream.Create(FileName, fmOpenRead);
  try
    SetLength(jsonString, fileStream.Size div SizeOf(Char));
    fileStream.ReadBuffer(Pointer(jsonString)^, Length(jsonString) * SizeOf(Char));
  finally
    fileStream.Free;
  end;

  try
    jsonArray := TJSONObject.ParseJSONValue(jsonString) as TJSONArray;
    if jsonArray = nil then
      raise Exception.Create('Invalid JSON format');

    try
      SetLength(FUsers, jsonArray.Count);
      for i := 0 to jsonArray.Count - 1 do
      begin
        jsonObject := jsonArray.Items[i] as TJSONObject;
        FUsers[i].PersonalCode := jsonObject.GetValue<string>('PersonalCode');
        FUsers[i].FirstName := jsonObject.GetValue<string>('FirstName');
        FUsers[i].LastName := jsonObject.GetValue<string>('LastName');
        FUsers[i].Country := jsonObject.GetValue<string>('Country');
        FUsers[i].County := jsonObject.GetValue<string>('County');
        FUsers[i].AdministrativeUnit := jsonObject.GetValue<string>('AdministrativeUnit');
        FUsers[i].SettlementUnit := jsonObject.GetValue<string>('SettlementUnit');
        FUsers[i].Street := jsonObject.GetValue<string>('Street');
        FUsers[i].House := jsonObject.GetValue<string>('House');
        FUsers[i].Apartment := jsonObject.GetValue<string>('Apartment');
        FUsers[i].PostalCode := jsonObject.GetValue<string>('PostalCode');
        FUsers[i].Phone := jsonObject.GetValue<string>('Phone');
      end;
      if FFileName <> FileName then
        FFileName := FileName;
    finally
      jsonArray.Free;
    end;
  except
    on E: Exception do
    begin
      ShowMessage('Error loading data: ' + E.Message);
      exit;
    end;
  end;

  DisplayData;
end;

procedure TMainForm.Save1Click(Sender: TObject);
begin
  SaveDataToFile(FFileName);
end;

procedure TMainForm.SaveAs1Click(Sender: TObject);
begin
  if SaveDialog1.InitialDir = '' then
    SaveDialog1.InitialDir := ExtractFileDir(paramstr(0));

  if SaveDialog1.Execute then
    SaveDataToFile(SaveDialog1.FileName);
end;

procedure TMainForm.SaveDataToFile(FileName: string);
var
  fileStream: TFileStream;
  jsonArray: TJSONArray;
  jsonObject: TJSONObject;
  i: Integer;
  jsonString: string;
begin
  jsonArray := TJSONArray.Create;
  try
    for i := 0 to High(FUsers) do
    begin
      jsonObject := TJSONObject.Create;
      jsonObject.AddPair('PersonalCode', FUsers[i].PersonalCode);
      jsonObject.AddPair('FirstName', FUsers[i].FirstName);
      jsonObject.AddPair('LastName', FUsers[i].LastName);
      jsonObject.AddPair('Country', FUsers[i].Country);
      jsonObject.AddPair('County', FUsers[i].County);
      jsonObject.AddPair('AdministrativeUnit', FUsers[i].AdministrativeUnit);
      jsonObject.AddPair('SettlementUnit', FUsers[i].SettlementUnit);
      jsonObject.AddPair('Street', FUsers[i].Street);
      jsonObject.AddPair('House', FUsers[i].House);
      jsonObject.AddPair('Apartment', FUsers[i].Apartment);
      jsonObject.AddPair('PostalCode', FUsers[i].PostalCode);
      jsonObject.AddPair('Phone', FUsers[i].Phone);
      jsonArray.AddElement(jsonObject);
    end;

    jsonString := jsonArray.Format(2);
    fileStream := TFileStream.Create(FileName, fmCreate);
    try
      fileStream.WriteBuffer(Pointer(jsonString)^, Length(jsonString) * SizeOf(Char));
      if FFileName <> FileName then
        FFileName := FileName;
    finally
      fileStream.Free;
    end;
  finally
    jsonArray.Free;
  end;
end;

procedure TMainForm.Exit1Click(Sender: TObject);
begin
  self.close;
end;

procedure TMainForm.SetFilter();
begin
  FFilter.PersonalCode := edtFilterPersonalCode.Text;
  FFilter.FirstName := edtFilterFirstName.Text;
  FFilter.LastName := edtFilterLastName.Text;

  FFilter.Country := edtFilterCountry.Text;
  FFilter.County := edtFilterCounty.Text;
  FFilter.AdministrativeUnit := edtFilterAdministrativeUnit.Text;
  FFilter.SettlementUnit := edtFilterSettlementUnit.Text;
  FFilter.Street := edtFilterStreet.Text;
  FFilter.House := edtFilterHouse.Text;
  FFilter.Apartment := edtFilterApartment.Text;
  FFilter.PostalCode := edtFilterPostalCode.Text;

  FFilter.Phone := edtFilterPhone.Text;
end;

procedure TMainForm.ClearFilter();
var
  i: Integer;
begin
  for i := 0 to High(FEdtFilters) do
  begin
    FEdtFilters[i].Text := '*';
  end;
end;

procedure TMainForm.btnClearFilterClick(Sender: TObject);
begin
  ClearFilter();
  SetFilter();
  DisplayData;
end;

end.
