unit uTeste;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat,
  FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client, Vcl.Grids, Vcl.DBGrids,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.ComCtrls,
  IdComponent, uLogDownload, Datasnap.DBClient, Datasnap.Provider;

type
  TFrmLogDownloads = class(TForm)
    Conexao: TFDConnection;
    gdLog: TDBGrid;
    dsLog: TDataSource;
    qLog: TFDQuery;
    Transacao: TFDTransaction;
    btnIniciar: TBitBtn;
    pgProgresso: TProgressBar;
    btnAdicionar: TBitBtn;
    btnRemoverURL: TBitBtn;
    DSP: TDataSetProvider;
    CDS: TClientDataSet;
    CDSCODIGO: TAutoIncField;
    CDSURL: TWideStringField;
    CDSDATAINICIO: TDateTimeField;
    CDSDATAFIM: TDateTimeField;
    CDSPERC: TLargeintField;
    qLogPERC: TLargeintField;
    qLogCODIGO: TFDAutoIncField;
    qLogURL: TWideStringField;
    qLogDATAINICIO: TDateTimeField;
    qLogDATAFIM: TDateTimeField;
    procedure FormCreate(Sender: TObject);
    procedure btnIniciarClick(Sender: TObject);
    procedure ProgressOnChange(Sender: TObject);
    procedure WorkEnd(Sender: TObject; aWorkMode: TWorkMode);
    procedure btnAdicionarClick(Sender: TObject);
    procedure btnRemoverURLClick(Sender: TObject);
    procedure gdLogDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure FormResize(Sender: TObject);
    procedure CDSDATAFIMGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
  private
    Codigo: Integer;
    PastaDownloads: string;
    LogDownload: TLogDownloadDAO;
  public
    { Public declarations }
  end;

var
  FrmLogDownloads: TFrmLogDownloads;

implementation

{$R *.dfm}

uses
  uUtils, Util.Download;

procedure TFrmLogDownloads.FormCreate(Sender: TObject);
begin
  PastaDownloads := ExtractFileDir(ParamStr(0)) + '\Downloads\';
  if not DirectoryExists(PastaDownloads) then
    ForceDirectories(PastaDownloads);

  try
    Conexao.Params.Database := ExtractFilePath(ParamStr(0)) + 'DB\downloads.db';
    Conexao.Connected := True;
  except
    on e: exception do
    begin
      ShowMessage('Erro ao conectar no banco de dados: '+Conexao.Params.Database +#13+
                  'Mensagem: '+e.Message);
      Application.Terminate;
    end;
  end;

  LogDownload := TLogDownloadDAO.Create;
  LogDownload.Conexao := Conexao;

  gdLog.Columns[0].Width := 104;

  CDS.Open;
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

procedure TFrmLogDownloads.btnAdicionarClick(Sender: TObject);
var
  LogDownloadDTO: TLogDownloadDTO;
begin
  LogDownloadDTO := TLogDownloadDTO.Create;
  try
    LogDownloadDTO.Limpar;
    LogDownloadDTO.URL := InputBox('Novo Download', 'Informe a URL', LogDownloadDTO.URL);
    if LogDownloadDTO.URL <> '' then
    begin
      LogDownload.AdicionarURL(LogDownloadDTO);
      CDS.Refresh;
    end;
  finally
    FreeAndNil(LogDownloadDTO);
  end;
end;

procedure TFrmLogDownloads.btnIniciarClick(Sender: TObject);
var
  IdHTTPProgress: TIdHTTPProgress;
  LogDownloadDTO: TLogDownloadDTO;
begin
  Codigo := CDS.FieldByName('CODIGO').AsInteger;

  LogDownloadDTO := TLogDownloadDTO.Create;
  LogDownloadDTO.Codigo := Codigo;
  LogDownload.CarregarLogDownload(LogDownloadDTO);

  IdHTTPProgress := TIdHTTPProgress.Create(Self);
  try
    IdHTTPProgress.OnChange  := ProgressOnChange;
    IdHTTPProgress.OnWorkEnd := WorkEnd;
    IdHTTPProgress.DownloadFile(LogDownloadDTO.URL, PastaDownloads + LogDownloadDTO.Arquivo);
  finally
    FreeAndNil(IdHTTPProgress);
    FreeAndNil(LogDownloadDTO);
  end;
end;

procedure TFrmLogDownloads.btnRemoverURLClick(Sender: TObject);
var
  LogDownloadDTO: TLogDownloadDTO;
begin
  if MessageDlg('Confirma excluir a URL?', mtConfirmation, [mbNo,mbYes], 0) <> mrYes then
    Exit;

  LogDownloadDTO := TLogDownloadDTO.Create;
  try
      LogDownloadDTO.Codigo := CDS.FieldByName(cLogDownload_CODIGO).AsInteger;
    if LogDownload.RemoverURL(LogDownloadDTO) then
      CDS.Refresh;
  finally
    FreeAndNil(LogDownloadDTO);
  end;
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
    if CDS.FieldByName(cLogDownload_DATAFIM).AsDateTime > 0 then
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

procedure TFrmLogDownloads.ProgressOnChange(Sender: TObject);
begin
  pgProgresso.Position := TIdHTTPProgress(Sender).Progress;

  if CDS.Locate(cLogDownload_CODIGO, Codigo, []) then
  begin
    CDS.Edit;
    CDS.FieldByName(cLogDownload_CalcPERC).Value := pgProgresso.Position;
    CDS.Post;
  end;

  Application.ProcessMessages;
end;

procedure TFrmLogDownloads.WorkEnd(Sender: TObject; aWorkMode: TWorkMode);
var
  LogDownloadDTO: TLogDownloadDTO;
begin
  pgProgresso.Position := 100;
  LogDownloadDTO := TLogDownloadDTO.Create;
  try
    LogDownloadDTO.Codigo := Codigo;
    LogDownloadDTO.DataFim := Now;
    LogDownload.Finalizar(LogDownloadDTO);
  finally
    FreeAndNil(LogDownloadDTO);
  end;
end;

end.
