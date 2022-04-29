unit uISubject;

interface

uses
  uIObserver;

type
  ISubject = interface
    procedure AdicionarObserver(Observer: IObserver);
    procedure RemoverObserver(Observer: IObserver);
    procedure Notificar;
  end;

implementation

end.
