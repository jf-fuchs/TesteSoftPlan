program Teste;

uses
  Vcl.Forms,
  uTeste in 'uTeste.pas' {FrmLogDownloads},
  uIdHTTPThread in 'Fontes\uIdHTTPThread.pas',
  uDM in 'Fontes\uDM.pas' {DM: TDataModule},
  uThreadManager in 'Fontes\uThreadManager.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmLogDownloads, FrmLogDownloads);
  Application.Run;
end.
