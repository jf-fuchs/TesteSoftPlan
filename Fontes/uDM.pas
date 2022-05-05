unit uDM;

interface

uses
  Forms,
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.UI.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.VCLUI.Wait, FireDAC.Comp.Client,
  Data.DB, Datasnap.DBClient, Datasnap.Provider, FireDAC.Comp.DataSet;

type
  TDM = class(TDataModule)
    qLog: TFDQuery;
    qLogPERC: TLargeintField;
    qLogCODIGO: TFDAutoIncField;
    qLogURL: TWideStringField;
    qLogDATAINICIO: TDateTimeField;
    qLogDATAFIM: TDateTimeField;
    DSP: TDataSetProvider;
    CDS: TClientDataSet;
    CDSPERC: TLargeintField;
    CDSURL: TWideStringField;
    CDSDATAINICIO: TDateTimeField;
    CDSDATAFIM: TDateTimeField;
    CDSCODIGO: TAutoIncField;
    Conexao: TFDConnection;
    Transacao: TFDTransaction;
    procedure DataModuleCreate(Sender: TObject);
    procedure CDSDATAINICIOGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses
  uUtils;

procedure TDM.CDSDATAINICIOGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.AsDateTime <= 0 then
    Text := ''
  else
    Text := Sender.AsString;
end;

procedure TDM.DataModuleCreate(Sender: TObject);
begin
  try
    Conexao.Params.Database := ExtractFilePath(ParamStr(0)) + 'DB\downloads.db';
    Conexao.Connected := True;
  except
    on e: exception do
    begin
      TUtils.MsgErro('Erro ao conectar no banco de dados: '+Conexao.Params.Database +#13+
                     'Mensagem: '+e.Message);
      Application.Terminate;
    end;
  end;
end;

end.
