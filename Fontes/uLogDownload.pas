unit uLogDownload;

interface

uses
  System.SysUtils, Data.DB, FireDAC.UI.Intf, FireDAC.Comp.Client, FireDAC.Stan.Param;

const
  cLogDownload_CalcPERC   = 'PERC';
  cLogDownload_CODIGO     = 'CODIGO';
  cLogDownload_URL        = 'URL';
  cLogDownload_DATAINICIO = 'DATAINICIO';
  cLogDownload_DATAFIM    = 'DATAFIM';

type
  TLogDownloadDTO = class
  private
    fCodigo: Integer;
    fURL: string;
    fDataInicio: TDateTime;
    fDataFim: TDateTime;
    function GetArquivo: string;
  public
    property Codigo: Integer read fCodigo write fCodigo;
    property URL: string read fURL write fURL;
    property DataInicio: TDateTime read fDataInicio write fDataInicio;
    property DataFim: TDateTime read fDataFim write fDataFim;
    property Arquivo: string read GetArquivo;
  public
    procedure Limpar;
  end;

type
  TLogDownloadDAO = class
  private
    qLog: TFDQuery;
    fConexao: TFDConnection;
    procedure SetConexao(const Value: TFDConnection);
  public
    constructor Create(aConexao: TFDConnection);
    function    AdicionarURL(aLogDownloadDTO: TLogDownloadDTO): Boolean;
    function    ZerarDownload(aLogDownloadDTO: TLogDownloadDTO): Boolean;
    function    RemoverURL(aLogDownloadDTO: TLogDownloadDTO): Boolean;
    function    Inicializar(aLogDownloadDTO: TLogDownloadDTO): Boolean;
    function    Finalizar(aLogDownloadDTO: TLogDownloadDTO): Boolean;
    procedure   CarregarLogDownload(aLogDownloadDTO: TLogDownloadDTO);
    procedure   ValidarResetar(aPasta: string);
    destructor  Destroy; override;
  public
    property Conexao: TFDConnection read fConexao write SetConexao;
  end;

implementation

uses
  uUtils;

function TLogDownloadDTO.GetArquivo: string;
begin
  Result := TUtils.ExtractFileFromURL(fURL);
end;

procedure TLogDownloadDTO.Limpar;
begin
  fCodigo     := 0;
  fURL        := '';
  fDataInicio := 0;
  fDataFim    := 0;
end;

{ TLogDownloadDAO }

constructor TLogDownloadDAO.Create(aConexao: TFDConnection);
begin
  fConexao := aConexao;
  qLog := TFDQuery.Create(nil);
  qLog.Connection := aConexao;
end;

destructor TLogDownloadDAO.Destroy;
begin
  qLog.Close;
  FreeAndNil(qLog);
  inherited;
end;

procedure TLogDownloadDAO.SetConexao(const Value: TFDConnection);
begin
  fConexao := Value;
  qLog.Connection := Value;
end;

procedure TLogDownloadDAO.ValidarResetar(aPasta: string);
var
  LogDownloadDTO: TLogDownloadDTO;
begin
  LogDownloadDTO := TLogDownloadDTO.Create;

  with TFDQuery.Create(nil) do
  try
    Connection := fConexao;
    SQL.Text := 'SELECT * FROM LOGDOWNLOAD';
    Open;
    while not Eof do
    begin
      LogDownloadDTO.Codigo := FieldByName(cLogDownload_CODIGO).AsInteger;

      CarregarLogDownload(LogDownloadDTO);

      if not FileExists(aPasta + LogDownloadDTO.Arquivo) then
        ZerarDownload(LogDownloadDTO);

      Next;
    end;
  finally
    Free;
    FreeAndNil(LogDownloadDTO);
  end;
end;

function TLogDownloadDAO.ZerarDownload(aLogDownloadDTO: TLogDownloadDTO): Boolean;
begin
  try
    with qLog do
    begin
      Close;
      SQL.Text := 'UPDATE LOGDOWNLOAD '+
                  '   SET DATAINICIO = :DATAINICIO, '+
                  '       DATAFIM = :DATAFIM '+
                  ' WHERE CODIGO = :CODIGO';
      ParamByName(cLogDownload_CODIGO).Value     := aLogDownloadDTO.Codigo;
      ParamByName(cLogDownload_DATAINICIO).Value := 0;
      ParamByName(cLogDownload_DATAFIM).Value    := 0;
      ExecSQL;
    end;
    Result := True;
  except
    Result := False;
  end;
end;

function TLogDownloadDAO.AdicionarURL(aLogDownloadDTO: TLogDownloadDTO): Boolean;
begin
  try
    with qLog do
    begin
      Close;
      SQL.Text := 'INSERT INTO LOGDOWNLOAD '+
                  '  (URL, DATAINICIO, DATAFIM) '+
                  'VALUES '+
                     '(:URL, :DATAINICIO, :DATAFIM)';
      ParamByName(cLogDownload_URL).Value        := aLogDownloadDTO.URL;
      ParamByName(cLogDownload_DATAINICIO).Value := aLogDownloadDTO.DataInicio;
      ParamByName(cLogDownload_DATAFIM).Value    := aLogDownloadDTO.DataFim;
      ExecSQL;
    end;
    Result := True;
  except
    Result := False;
  end;
end;

function TLogDownloadDAO.Inicializar(aLogDownloadDTO: TLogDownloadDTO): Boolean;
begin
  try
    with qLog do
    begin
      Close;
      SQL.Text := 'UPDATE LOGDOWNLOAD '+
                  '   SET DATAINICIO = :DATAINICIO '+
                  ' WHERE CODIGO = :CODIGO';
      ParamByName(cLogDownload_CODIGO).Value  := aLogDownloadDTO.Codigo;
      ParamByName(cLogDownload_DATAINICIO).Value := aLogDownloadDTO.DataInicio;
      ExecSQL;
    end;
    Result := True;
  except
    Result := False;
  end;
end;

function TLogDownloadDAO.Finalizar(aLogDownloadDTO: TLogDownloadDTO): Boolean;
begin
  try
    with qLog do
    begin
      Close;
      SQL.Text := 'UPDATE LOGDOWNLOAD '+
                  '   SET DATAFIM = :DATAFIM '+
                  ' WHERE CODIGO = :CODIGO';
      ParamByName(cLogDownload_CODIGO).Value  := aLogDownloadDTO.Codigo;
      ParamByName(cLogDownload_DATAFIM).Value := aLogDownloadDTO.DataFim;
      ExecSQL;
    end;
    Result := True;
  except
    Result := False;
  end;
end;

function TLogDownloadDAO.RemoverURL(aLogDownloadDTO: TLogDownloadDTO): Boolean;
begin
  try
    with qLog do
    begin
      Close;
      SQL.Text := 'DELETE FROM LOGDOWNLOAD '+
                  ' WHERE CODIGO = :CODIGO';
      ParamByName(cLogDownload_CODIGO).Value := aLogDownloadDTO.Codigo;
      ExecSQL;
    end;
    Result := True;
  except
    Result := False;
  end;
end;

procedure TLogDownloadDAO.CarregarLogDownload(aLogDownloadDTO: TLogDownloadDTO);
begin
  try
    with qLog do
    begin
      Close;
      SQL.Text := 'SELECT CODIGO, URL, DATAINICIO, DATAFIM '+
                  '  FROM LOGDOWNLOAD '+
                  ' WHERE (CODIGO = :CODIGO)';
      ParamByName(cLogDownload_CODIGO).AsInteger := aLogDownloadDTO.Codigo;
      Open;
      if not IsEmpty then
      begin
        aLogDownloadDTO.URL        := FieldByName(cLogDownload_URL).AsString;
        aLogDownloadDTO.DataInicio := FieldByName(cLogDownload_DATAINICIO).AsDateTime;
        aLogDownloadDTO.DataFim    := FieldByName(cLogDownload_DATAFIM).AsDateTime;
      end;
    end;
  except
    aLogDownloadDTO.Limpar;
  end;
end;

end.
