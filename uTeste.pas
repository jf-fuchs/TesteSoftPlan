{Falta:
 - Parar a thread e o download
 - Incluir download no meio dos processos
 - Ajustar CDS.Refresh
 - Refatorar
}
unit uTeste;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids, Vcl.DBGrids,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.ComCtrls, System.UITypes, IdComponent, Datasnap.DBClient,
  Datasnap.Provider, Vcl.ExtCtrls, uLogDownload;

type
  TFrmLogDownloads = class(TForm)
    gdLog: TDBGrid;
    dsLog: TDataSource;
    Panel1: TPanel;
    btnAdicionar: TBitBtn;
    btnRemoverURL: TBitBtn;
    btnIniciar: TBitBtn;
    btnIniciarTodos: TBitBtn;
    btnInterromper: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure btnAdicionarClick(Sender: TObject);
    procedure btnRemoverURLClick(Sender: TObject);
    procedure gdLogDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure FormResize(Sender: TObject);
    procedure CDSDATAFIMGetText(Sender: TField; var Text: string; DisplayText: Boolean);
    procedure btnIniciarTodosClick(Sender: TObject);
    procedure IniciarDownload(aID: Integer);
    procedure btnIniciarClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure WorkBegin(Sender: TObject; aID: Integer);
    procedure ProgressOnChange(Sender: TObject; aID: Integer; aProgress: Int64);
    procedure WorkEnd(Sender: TObject; aID: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    PastaDownloads: string;
    LogDownloadDAO: TLogDownloadDAO;
  public
    { Public declarations }
  end;

var
  FrmLogDownloads: TFrmLogDownloads;

implementation

{$R *.dfm}

uses
  uDM, uUtils, uIdHTTPThread;

procedure TFrmLogDownloads.FormCreate(Sender: TObject);
begin
  PastaDownloads := ExtractFileDir(ParamStr(0)) + '\Downloads\';
  if not DirectoryExists(PastaDownloads) then
    ForceDirectories(PastaDownloads);

  DM := TDM.Create(nil);

  LogDownloadDAO := TLogDownloadDAO.Create;
  LogDownloadDAO.Conexao := DM.Conexao;
  LogDownloadDAO.ValidarResetar(PastaDownloads);

  gdLog.Columns[0].Width := 104;

  DM.CDS.Open;
end;

procedure TFrmLogDownloads.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FreeAndNil(LogDownloadDAO);
  FreeAndNil(DM);
end;

procedure TFrmLogDownloads.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F5 then
    DM.CDS.Refresh;
end;

procedure TFrmLogDownloads.FormResize(Sender: TObject);
var
  i,Tot: Integer;
begin
  Tot := 0;
  for i := 0 to Pred(gdLog.Columns.Count) do
    if gdLog.Columns[i].Visible then
      if gdLog.Columns[i].FieldName <> cLogDownload_URL then
        Tot := Tot + (gdLog.Columns[i].Width - 5);

  gdLog.Columns[1].Width := gdLog.Width - Tot - 52;
end;

procedure TFrmLogDownloads.CDSDATAFIMGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.AsDateTime <= 0 then
    Text := ''
  else
    Text := Sender.AsString;
end;

procedure TFrmLogDownloads.gdLogDrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  Aux: string;
  Valor, p: Integer;
begin
  if Column.FieldName = cLogDownload_CalcPERC then
  begin
    if DM.CDS.FieldByName(cLogDownload_DATAFIM).AsDateTime > 0 then
      Valor := 100
    else
      Valor := Column.Field.AsInteger;

    Aux := IntToStr(Valor)+'%';
    with gdLog.Canvas do
    begin
      Brush.Color := clWindow;
      FillRect(Rect);

      p := ((Rect.Right - Rect.Left) div 2) - (TextWidth(Aux) div 2);

      Brush.Color := clLime;
      Rectangle(Rect.Left+1, Rect.Top+1, Rect.Left+Valor, Rect.Bottom-1);

      Brush.Style := bsClear;
      TextOut(Rect.Left+p, Rect.Top+2, Aux);
    end;
  end;
end;

procedure TFrmLogDownloads.btnAdicionarClick(Sender: TObject);
var
  LogDTO: TLogDownloadDTO;
begin
  LogDTO := TLogDownloadDTO.Create;
  try
    LogDTO.Limpar;
    LogDTO.URL := InputBox('Novo Download', 'Informe a URL', LogDTO.URL);
    if LogDTO.URL <> '' then
    begin
      LogDownloadDAO.AdicionarURL(LogDTO);
      DM.CDS.Refresh;
    end;
  finally
    FreeAndNil(LogDTO);
  end;
end;

procedure TFrmLogDownloads.btnRemoverURLClick(Sender: TObject);
var
  LogDTO: TLogDownloadDTO;
begin
  if MessageDlg('Confirma excluir a URL?', mtConfirmation, [mbNo,mbYes], 0) <> mrYes then
    Exit;

  LogDTO := TLogDownloadDTO.Create;
  try
    LogDTO.Codigo := DM.CDS.FieldByName(cLogDownload_CODIGO).AsInteger;
    if LogDownloadDAO.RemoverURL(LogDTO) then
      DM.CDS.Refresh;
  finally
    FreeAndNil(LogDTO);
  end;
end;

procedure TFrmLogDownloads.IniciarDownload(aID: Integer);
var
  LogDTO: TLogDownloadDTO;
  HTTPThread: TIdHTTPThread;
begin
  LogDTO := TLogDownloadDTO.Create;
  try
    LogDTO.Codigo := aID;
    LogDownloadDAO.CarregarLogDownload(LogDTO);

    HTTPThread := TIdHTTPThread.Create(aID, True);
    HTTPThread.Url := LogDTO.URL;
    HTTPThread.FileName := PastaDownloads + LogDTO.Arquivo;

    HTTPThread.OnStart := WorkBegin;
    HTTPThread.OnProgress := ProgressOnChange;
    HTTPThread.OnEnd := WorkEnd;

    HTTPThread.FreeOnTerminate := True;
    HTTPThread.Resume;
  finally
    FreeAndNil(LogDTO);
  end;
end;

procedure TFrmLogDownloads.btnIniciarClick(Sender: TObject);
begin
  IniciarDownload(DM.CDS.FieldByName('CODIGO').AsInteger);
end;

procedure TFrmLogDownloads.btnIniciarTodosClick(Sender: TObject);
var
  i: Integer;
begin
  DM.CDS.First;
  while not DM.CDS.Eof do
  begin
    IniciarDownload(DM.CDS.FieldByName('CODIGO').AsInteger);
    DM.CDS.Next;
  end;
end;

procedure TFrmLogDownloads.ProgressOnChange(Sender: TObject; aID: Integer; aProgress: Int64);
var
  IDAtual: Integer;
begin
  IDAtual := DM.CDS.FieldByName('CODIGO').AsInteger;
  try
    if DM.CDS.Locate(cLogDownload_CODIGO, aID, []) then
    begin
      DM.CDS.Edit;
      DM.CDS.FieldByName(cLogDownload_CalcPERC).Value := aProgress;
      DM.CDS.Post;
    end;
  finally
    DM.CDS.Locate(cLogDownload_CODIGO, IDAtual, []);
  end;
end;

procedure TFrmLogDownloads.WorkBegin(Sender: TObject; aID: Integer);
var
  LogDTO: TLogDownloadDTO;
begin
  LogDTO := TLogDownloadDTO.Create;
  try
    LogDTO.Codigo := aID;
    LogDTO.DataInicio := Now;
    LogDownloadDAO.Inicializar(LogDTO);
  finally
    FreeAndNil(LogDTO);
  end;
  ProgressOnChange(Self, aID, 0);
end;

procedure TFrmLogDownloads.WorkEnd(Sender: TObject; aID: Integer);
var
  LogDTO: TLogDownloadDTO;
begin
  LogDTO := TLogDownloadDTO.Create;
  try
    LogDTO.Codigo := aID;
    LogDTO.DataFim := Now;
    LogDownloadDAO.Finalizar(LogDTO);
  finally
    FreeAndNil(LogDTO);
  end;
end;

end.
