unit uCustomThread;

interface

uses
  System.Classes, System.SysUtils;

type
  TProcedureExcept = reference to procedure(const aMsgException: string);

type
  TCustomThread = class(TThread)
  private
    fThread: TThread;
  public
    constructor Create(aOnBegin, aOnProcess, aOnEnd: TProc; onError: TProcedureExcept;
      const aDoCompleteWithError: Boolean);
    destructor  Destroy; override;
  end;


implementation

{ TCustomThread }

constructor TCustomThread.Create(aOnBegin, aOnProcess, aOnEnd: TProc; onError: TProcedureExcept;
  const aDoCompleteWithError: Boolean);
begin
  inherited Create;

  fThread := TThread.CreateAnonymousThread(
    procedure ()
    var
      DoComplete: Boolean;
    begin
      try
        try
          DoComplete := True;

          if Assigned(aOnBegin) then
          begin
            TThread.Synchronize(TThread.CurrentThread,
              procedure ()
              begin
                aOnBegin;
              end)
          end;

          if Assigned(aOnProcess) then
            aOnProcess;
        except
          on e: Exception do
          begin
            DoComplete := aDoCompleteWithError;

            if Assigned(onError) then
            begin
              TThread.Synchronize(TThread.CurrentThread,
                procedure ()
                begin
                  onError(e.Message);
                end)
            end;
          end;
        end;
      finally
        if Assigned(aOnEnd) then
        begin
          TThread.Synchronize(TThread.CurrentThread,
            procedure ()
            begin
              aOnEnd;
            end)
        end;
      end;
    end
  );

  fThread.FreeOnTerminate := True;
  //fThread.Start;
end;

destructor TCustomThread.Destroy;
begin
  FreeAndNil(fThread);
  inherited;
end;

end.
