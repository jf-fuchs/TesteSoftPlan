unit uISubject;

interface

uses
  uIObserver;

type
  ISubject = interface
    procedure AdicionarObserver(aObserver: IObserver);
    procedure RemoverObserver(aObserver: IObserver);
  end;

implementation

end.
