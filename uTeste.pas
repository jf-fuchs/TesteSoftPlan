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
  Datasnap.Provider, Vcl.ExtCtrls, uLogDownload, uIdHTTPThread, uThreadManager,
  System.Generics.Collections, uISubject, uIObserver, uObserverDownloads;

type
  TFrmLogDownloads = class(TForm, ISubject)
    dsLog: TDataSource;
    pnFundoBotoes: TPanel;
    pnBotoes: TPanel;
    btnAdicionar: TBitBtn;
    btnRemoverURL: TBitBtn;
    btnIniciar: TBitBtn;
    btnIniciarTodos: TBitBtn;
    btnInterromper: TBitBtn;
    pnFundo: TPanel;
    gdLog: TDBGrid;
    pnErro: TPanel;
    TimerErro: TTimer;
    pnMsgErro: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure btnAdicionarClick(Sender: TObject);
    procedure btnRemoverURLClick(Sender: TObject);
    procedure gdLogDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure FormResize(Sender: TObject);
    procedure btnIniciarTodosClick(Sender: TObject);
    procedure IniciarDownload(aID: Integer);
    procedure btnIniciarClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure WorkBegin(Sender: TObject; aID: Integer);
    procedure ProgressOnChange(Sender: TObject; aID: Integer; aProgress: Int64);
    procedure WorkEnd(Sender: TObject; aID: Integer; aCancel: Boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure btnInterromperClick(Sender: TObject);
    procedure TimerErroTimer(Sender: TObject);
  private
    ListaObservers: TList<IObserver>;
    ThreadManager: TThreadManager;
    PastaDownloads: string;
    LogDownloadDAO: TLogDownloadDAO;
    ObserverDownloads: TObserverDownloads;
    procedure MsgErro(aMsg: string);
  public
    procedure AdicionarObserver(aObserver: IObserver);
    procedure RemoverObserver(aObserver: IObserver);
  end;

var
  FrmLogDownloads: TFrmLogDownloads;

implementation

{$R *.dfm}

uses
  uDM, uUtils;

procedure TFrmLogDownloads.FormCreate(Sender: TObject);
begin
  PastaDownloads := ExtractFileDir(ParamStr(0)) + '\Downloads\';
  if not DirectoryExists(PastaDownloads) then
    ForceDirectories(PastaDownloads);

  DM := TDM.Create(nil);

  ThreadManager := TThreadManager.Create;

  LogDownloadDAO := TLogDownloadDAO.Create(DM.Conexao);
  LogDownloadDAO.ValidarResetar(PastaDownloads);

  gdLog.Columns[0].Width := 104;

  DM.CDS.Open;

  ObserverDownloads := TObserverDownloads.Create;

  ListaObservers := TList<IObserver>.Create;
  ListaObservers.Add(ObserverDownloads);
end;

procedure TFrmLogDownloads.FormDestroy(Sender: TObject);
begin
  FreeAndNil(ListaObservers);
  FreeAndNil(ThreadManager);
  FreeAndNil(LogDownloadDAO);
  FreeAndNil(DM);
end;

procedure TFrmLogDownloads.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := not ThreadManager.ExisteThreadEmAndamento;
  if not CanClose then
    MsgErro('AGUARDE. Existem downloads em andamento!');
end;

procedure TFrmLogDownloads.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F5 then
    DM.AtualizarCDS;
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

//------------------------------------------------------------------------------
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

//------------------------------------------------------------------------------
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
      DM.AtualizarCDS;
    end;
  finally
    FreeAndNil(LogDTO);
  end;
end;

procedure TFrmLogDownloads.btnRemoverURLClick(Sender: TObject);
var
  LogDTO: TLogDownloadDTO;
begin
  LogDTO := TLogDownloadDTO.Create;
  try
    LogDTO.Codigo := DM.CDS.FieldByName(cLogDownload_CODIGO).AsInteger;

    if ThreadManager.ExisteThread(LogDTO.Codigo, True) then
      MsgErro('Este Download ainda está em execução!')
    else
    begin
      if MessageDlg('Confirma excluir a URL?', mtConfirmation, [mbNo,mbYes], 0) <> mrYes then
        Exit;

      if LogDownloadDAO.RemoverURL(LogDTO) then
        DM.AtualizarCDS;
    end;
  finally
    FreeAndNil(LogDTO);
  end;
end;

procedure TFrmLogDownloads.btnIniciarClick(Sender: TObject);
begin
  IniciarDownload(DM.CDS.FieldByName('CODIGO').AsInteger);
end;

procedure TFrmLogDownloads.btnIniciarTodosClick(Sender: TObject);
begin
  DM.CDS.First;
  while not DM.CDS.Eof do
  begin
    IniciarDownload(DM.CDS.FieldByName('CODIGO').AsInteger);
    DM.CDS.Next;
  end;
end;

procedure TFrmLogDownloads.btnInterromperClick(Sender: TObject);
begin
  ThreadManager.PararThread(DM.CDS.FieldByName('CODIGO').AsInteger);
end;

procedure TFrmLogDownloads.IniciarDownload(aID: Integer);
var
  LogDTO: TLogDownloadDTO;
  HTTPThread: TIdHTTPThread;
begin
  if ThreadManager.ExisteThread(aID) then
  begin
    MsgErro('O Download deste arquivo já está em execução!');
    Exit;
  end;

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

    ThreadManager.AdicionarThread(HTTPThread);
  finally
    FreeAndNil(LogDTO);
  end;
end;

//------------------------------------------------------------------------------
procedure TFrmLogDownloads.TimerErroTimer(Sender: TObject);
begin
  pnErro.Visible := False;
  TimerErro.Enabled := False;
end;

procedure TFrmLogDownloads.MsgErro(aMsg: string);
begin
  pnMsgErro.Caption := aMsg;
  pnErro.Visible := True;
  TimerErro.Enabled := True;
end;

//------------------------------------------------------------------------------
procedure TFrmLogDownloads.WorkBegin(Sender: TObject; aID: Integer);
var
  Observer: IObserver;
begin
  for Observer in ListaObservers do
  begin
    Observer.Iniciar(aID);
    Observer.Atualizar(aID, 0);
  end;
  Application.ProcessMessages;
end;

procedure TFrmLogDownloads.WorkEnd(Sender: TObject; aID: Integer; aCancel: Boolean);
var
  Observer: IObserver;
begin
  ThreadManager.ExcluirThread(aID);
  if not aCancel then
    for Observer in ListaObservers do
      Observer.Finalizar(aID);
end;

procedure TFrmLogDownloads.ProgressOnChange(Sender: TObject; aID: Integer; aProgress: Int64);
var
  Observer: IObserver;
begin
  for Observer in ListaObservers do
    Observer.Atualizar(aID, aProgress);
  Application.ProcessMessages;
end;

//------------------------------------------------------------------------------
procedure TFrmLogDownloads.AdicionarObserver(aObserver: IObserver);
begin
  ListaObservers.Add(aObserver);
end;

procedure TFrmLogDownloads.RemoverObserver(aObserver: IObserver);
begin
  ListaObservers.Delete(ListaObservers.IndexOf(aObserver));
end;

end.
