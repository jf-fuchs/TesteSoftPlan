unit uObserver;

interface

uses
  uLogDownload;

type
  IObserver = interface
    procedure Atualizar(aLogDownloadDTO: TLogDownloadDTO);
  end;

implementation

end.
