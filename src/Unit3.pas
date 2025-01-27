unit Unit3;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  IdURI, IdSSLOpenSSL, System.JSON, IdHTTP, Vcl.Grids, Vcl.ExtCtrls, DZhTypes;

type
  TForm3 = class(TForm)
    StringGrid1: TStringGrid;
    Panel1: TPanel;
    ButtonSearch: TButton;
    EditAddress: TEdit;
    Label1: TLabel;
    Button1: TButton;
    procedure ButtonSearchClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; ACol, ARow: LongInt; Rect: TRect; State: TGridDrawState);
    procedure Button1Click(Sender: TObject);
    procedure EditAddressKeyPress(Sender: TObject; var Key: Char);

  const
    cColorForEvenRows = clWhite;
    cColorForOddRows = $00F2F2F2;
  private
    procedure FetchAddresses(const Address: string);
    procedure AdjustColumnWidths;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

procedure TForm3.AdjustColumnWidths;
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

procedure TForm3.FetchAddresses(const Address: string);
var
  http: TIdHTTP;
  sslHandler: TIdSSLIOHandlerSocketOpenSSL;
  response: TMemoryStream;
  responseString: string;
  JSON: TJSONObject;
  sddresses: TJSONArray;
  appartments: TJSONArray;
  i, j, row: Integer;
  bytes: TBytes;
begin
  if Address = '' then
    Exit;

  http := TIdHTTP.Create(nil);
  sslHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  response := TMemoryStream.Create;
  try
    sslHandler.SSLOptions.Method := sslvTLSv1_2;
    http.IOHandler := sslHandler;
    http.Request.UserAgent :=
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36 Edg/132.0.0.0';
    http.Request.ContentType := 'application/json';
    http.Get('https://inaadress.maaamet.ee/inaadress/gazetteer?results=10&features=EHITISHOONE&ihist=1993&address=' +
      TIdURI.ParamsEncode(Address) + '&appartments=1&unik=1&tech=1&iTappAsendus=0&ky=0&poi=0&knr=0&help=1', response);
    response.Position := 0;

    SetLength(bytes, response.Size);
    response.ReadBuffer(bytes, response.Size);
    responseString := TEncoding.UTF8.GetString(bytes);

    JSON := TJSONObject.ParseJSONValue(responseString) as TJSONObject;
    try
      if JSON.TryGetValue<TJSONArray>('addresses', sddresses) then
      begin
        StringGrid1.RowCount := 1;

        row := 1;
        for i := 0 to sddresses.Count - 1 do
        begin
          if sddresses.Items[i].TryGetValue<TJSONArray>('appartments', appartments) then
          begin
            for j := 0 to appartments.Count - 1 do
            begin
              StringGrid1.RowCount := row + 1;
              StringGrid1.Cells[0, row] := sddresses.Items[i].GetValue<string>('maakond');
              StringGrid1.Cells[1, row] := sddresses.Items[i].GetValue<string>('omavalitsus');
              StringGrid1.Cells[2, row] := sddresses.Items[i].GetValue<string>('asustusyksus');
              StringGrid1.Cells[3, row] := sddresses.Items[i].GetValue<string>('liikluspind');
              StringGrid1.Cells[4, row] := sddresses.Items[i].GetValue<string>('aadress_nr');
              StringGrid1.Cells[5, row] := appartments.Items[j].GetValue<string>('tahis');
              StringGrid1.Cells[6, row] := sddresses.Items[i].GetValue<string>('sihtnumber');
              StringGrid1.Objects[0, row] := sddresses.Items[i];
              Inc(row);
            end;
          end
          else
          begin
            StringGrid1.RowCount := row + 1;
            StringGrid1.Cells[0, row] := sddresses.Items[i].GetValue<string>('maakond');
            StringGrid1.Cells[1, row] := sddresses.Items[i].GetValue<string>('omavalitsus');
            StringGrid1.Cells[2, row] := sddresses.Items[i].GetValue<string>('asustusyksus');
            StringGrid1.Cells[3, row] := sddresses.Items[i].GetValue<string>('liikluspind');
            StringGrid1.Cells[4, row] := sddresses.Items[i].GetValue<string>('aadress_nr');
            StringGrid1.Cells[5, row] := '';
            StringGrid1.Cells[6, row] := sddresses.Items[i].GetValue<string>('sihtnumber');

            StringGrid1.Objects[0, row] := sddresses.Items[i];
            Inc(row);
          end;
        end;
      end
      else
      begin
        StringGrid1.RowCount := 1;
      end;
    finally
      JSON.Free;
    end;
  finally
    http.Free;
    sslHandler.Free;
    response.Free;
  end;
end;

procedure TForm3.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  AdjustColumnWidths;
  for i := 4 to High(ColumnNames) do
    StringGrid1.Cells[i - 4, 0] := ColumnNames[i];
end;

procedure TForm3.FormResize(Sender: TObject);
begin
  AdjustColumnWidths;
end;

procedure TForm3.Button1Click(Sender: TObject);
begin
  if StringGrid1.row > 0 then
    self.ModalResult := mrOk;
end;

procedure TForm3.ButtonSearchClick(Sender: TObject);
begin
  FetchAddresses(EditAddress.Text);
end;

procedure TForm3.EditAddressKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    ButtonSearchClick(Sender);

end;

procedure TForm3.StringGrid1DrawCell(Sender: TObject; ACol, ARow: LongInt; Rect: TRect; State: TGridDrawState);
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

end.
