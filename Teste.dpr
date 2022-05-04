program Teste;

uses
  Vcl.Forms,
  uTeste in 'uTeste.pas' {FrmLogDownloads},
  uCustomThread in 'Fontes\uCustomThread.pas',
  uIdHTTPThread in 'Fontes\uIdHTTPThread.pas',
  uDM in 'Fontes\uDM.pas' {DM: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmLogDownloads, FrmLogDownloads);
  Application.Run;
end.
