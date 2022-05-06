unit uIObserver;

interface

type
  IObserver = interface
    procedure Iniciar(aID: Integer);
    procedure Atualizar(aID, aProgress: Integer);
    procedure Finalizar(aID: Integer);
  end;

implementation

end.
