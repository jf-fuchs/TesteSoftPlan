unit uObserverDownloads;

interface

uses
  System.Classes, System.SysUtils, uIObserver;

type
  TObserverDownloads = class(TInterfacedObject, IObserver)
  public
    procedure Iniciar(aID: Integer);
    procedure Atualizar(aID, aProgress: Integer);
    procedure Finalizar(aID: Integer);
  end;

implementation

uses
  uDM, uLogDownload;

procedure TObserverDownloads.Iniciar(aID: Integer);
var
  LogDTO: TLogDownloadDTO;
  LogDownloadDAO: TLogDownloadDAO;
begin
  LogDTO := TLogDownloadDTO.Create;
  LogDownloadDAO := TLogDownloadDAO.Create(DM.Conexao);
  try
    LogDTO.Codigo := aID;
    LogDTO.DataInicio := Now;
    LogDownloadDAO.Inicializar(LogDTO);
  finally
    FreeAndNil(LogDTO);
    FreeAndNil(LogDownloadDAO);
  end;
  DM.AtualizarCDS;
end;

procedure TObserverDownloads.Atualizar(aID, aProgress: Integer);
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

procedure TObserverDownloads.Finalizar(aID: Integer);
var
  LogDTO: TLogDownloadDTO;
  LogDownloadDAO: TLogDownloadDAO;
begin
  LogDTO := TLogDownloadDTO.Create;
  LogDownloadDAO := TLogDownloadDAO.Create(DM.Conexao);
  try
    LogDTO.Codigo := aID;
    LogDTO.DataFim := Now;
    LogDownloadDAO.Finalizar(LogDTO);
  finally
    FreeAndNil(LogDTO);
    FreeAndNil(LogDownloadDAO);
  end;
  DM.AtualizarCDS;
end;

end.
