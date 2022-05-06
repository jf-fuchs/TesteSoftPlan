unit uIdHTTPThread;

interface

uses
  Classes, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,
  SysUtils, IdSSLOpenSSL, IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack;

type
  TOnStartEvent = procedure(aSender: TObject; aID: Integer) of object;
  TOnProgressEvent = procedure(aSender: TObject; aID: Integer; aProgress: Int64) of object;
  TOnEndEvent = procedure(aSender: TObject; aID: Integer; aCancel: Boolean) of object;

type
  TIdHTTPThread = class(TThread)
  private
    fID: Integer;
    fURL: AnsiString;
    fFileName: AnsiString;
    fProgress, fWorkCountMax: Int64;
    IdHTTP: TIdHTTP;
    IOHndl: TIdSSLIOHandlerSocketOpenSSL;
    //
    fOnEnd: TOnEndEvent;
    fOnStart: TOnStartEvent;
    fOnProgress: TOnProgressEvent;
    fCancel: Boolean;
    procedure OnWork(ASender: TObject; aWorkMode: TWorkMode; aWorkCount: Int64);
    procedure OnWorkBegin(ASender: TObject; aWorkMode: TWorkMode; aWorkCountMax: Int64);
    procedure OnWorkEnd(ASender: TObject; aWorkMode: TWorkMode);
  public
    constructor Create(aID: Integer; CreateSuspended: Boolean);
    destructor Destroy; override;
  public
    property ID: Integer read fID write fID;
    property URL: AnsiString read fURL write fURL;
    property FileName: AnsiString read fFileName write fFileName;
    property OnStart: TOnStartEvent read fOnStart write fOnStart;
    property OnProgress: TOnProgressEvent read fOnProgress write fOnProgress;
    property OnEnd: TOnEndEvent read fOnEnd write fOnEnd;
    property Cancel: Boolean read fCancel write fCancel;
  protected
    procedure Execute; override;
  end;

implementation

constructor TIdHTTPThread.Create(aID: Integer; CreateSuspended: Boolean);
begin
  inherited Create(Suspended);

  IdHTTP := TIdHTTP.Create;

  IdHTTP.Request.Accept := 'text/html, image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, */*';
  IdHTTP.Request.AcceptEncoding := 'gzip, deflate';
  IdHTTP.Request.UserAgent := 'Mozilla/4.0';
  IdHTTP.Request.BasicAuthentication := True;
  IdHTTP.HTTPOptions := IdHTTP.HTTPOptions + [hoNoProtocolErrorException, hoWantProtocolErrorContent];

  IOHndl := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  IOHndl.SSLOptions.SSLVersions := [sslvSSLv2, sslvSSLv23, sslvSSLv3, sslvTLSv1,sslvTLSv1_1,sslvTLSv1_2];
  IdHTTP.IOHandler := IOHndl;

  IdHTTP.HandleRedirects := True;
  IdHTTP.ReadTimeout := 30000;

  IdHTTP.OnWorkBegin := OnWorkBegin;
  IdHTTP.OnWork := OnWork;
  IdHTTP.OnWorkEnd := OnWorkEnd;

  fID := aID;
  fCancel := False;
end;

destructor TIdHTTPThread.Destroy;
begin
  FreeAndNil(IOHndl);
  FreeAndNil(IdHTTP);
  inherited;
end;

procedure TIdHTTPThread.Execute;
var
  DestStream: TFileStream;
begin
  DestStream := TFileStream.Create(Filename, fmCreate);
  try
    try
      IdHTTP.Get(Url, DestStream);
    finally
      DestStream.Free;
    end;
  except
    fCancel := True;
  end;
end;

procedure TIdHTTPThread.OnWorkBegin(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin
  fCancel := False;
  fWorkCountMax := aWorkCountMax;

  Synchronize(
    procedure ()
    begin
      if Assigned(fOnStart) then
        fOnStart(Self, fID);
    end
  );
end;

procedure TIdHTTPThread.OnWork(ASender: TObject; aWorkMode: TWorkMode; aWorkCount: Int64);
begin
  if fWorkCountMax > 0 then
    fProgress := Round((aWorkCount / fWorkCountMax) * 100);

  if fCancel then
  begin
    IdHTTP.Disconnect;
    Terminate;
    Abort;
  end;

  Synchronize(
    procedure ()
    begin
      if Assigned(fOnProgress) then
        fOnProgress(Self, fID, fProgress);
    end
  );
end;

procedure TIdHTTPThread.OnWorkEnd(ASender: TObject; AWorkMode: TWorkMode);
begin
  IdHTTP.Disconnect;
  Terminate;

  Synchronize(
    procedure ()
    begin
      if Assigned(fOnEnd) then
        fOnEnd(Self, fID, fCancel);
    end
  );
end;

end.
