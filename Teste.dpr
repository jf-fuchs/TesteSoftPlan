program Teste;

uses
  Vcl.Forms,
  uTeste in 'uTeste.pas' {FrmLogDownloads};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmLogDownloads, FrmLogDownloads);
  Application.Run;
end.
