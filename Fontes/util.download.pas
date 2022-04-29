{                                                                      }
{    TIdHTTPProgress - Extendend TIdHTTP to show progress download     }
{                                                                      }
{ Fixed and adapted to Lazarus and Delphi by Giovani Da Cruz           }
{                                                                      }
{ Please visit: https://showdelphi.com.br                              }
{----------------------------------------------------------------------}
unit Util.Download;

interface

uses
  Classes, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,
  IdSSL, IdSSLOpenSSL, IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack;

{$M+}

type
  TIdHTTPProgress = class(TIdHTTP)
  private
    fProgress: Integer;
    fBytesToTransfer: Int64;
    fOnChange: TNotifyEvent;
    IOHndl: TIdSSLIOHandlerSocketOpenSSL;
    procedure HTTPWorkBegin(ASender: TObject; aWorkMode: TWorkMode; aWorkCountMax: Int64);
    procedure HTTPWork(ASender: TObject; aWorkMode: TWorkMode; aWorkCount: Int64);
    procedure HTTPWorkEnd(Sender: TObject; aWorkMode: TWorkMode);
    procedure SetProgress(const Value: Integer);
    procedure SetOnChange(const Value: TNotifyEvent);
  public
    constructor Create(AOwner: TComponent);
    procedure DownloadFile(const aFileUrl: string; const aDestinationFile: String);
  published
    property Progress: Integer read fProgress write SetProgress;
    property BytesToTransfer: Int64 read fBytesToTransfer;
    property OnChange: TNotifyEvent read fOnChange write SetOnChange;
  end;

implementation

uses
  Sysutils;

constructor TIdHTTPProgress.Create(AOwner: TComponent);
begin
  inherited;

  Request.Accept := 'text/html, image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, */*';
  Request.AcceptEncoding := 'gzip, deflate';
  Request.UserAgent := 'Mozilla/4.0';
  HandleRedirects := True;

  IOHndl := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  IOHndl.SSLOptions.SSLVersions := [sslvSSLv2, sslvSSLv23, sslvSSLv3, sslvTLSv1,sslvTLSv1_1,sslvTLSv1_2];

  Request.BasicAuthentication := True;
  HandleRedirects := True;
  IOHandler := IOHndl;
  ReadTimeout := 30000;

  //Self.Request.Username := 'JEAN.FUCHS';
  //Self.Request.Password := 'Jff_53557782';

  OnWork      := HTTPWork;
  OnWorkBegin := HTTPWorkBegin;
  OnWorkEnd   := HTTPWorkEnd;
end;

procedure TIdHTTPProgress.DownloadFile(const aFileUrl: string; const aDestinationFile: string);
var
  aPath: string;
  LDestStream: TFileStream;
begin
  Progress := 0;
  fBytesToTransfer := 0;
  aPath := ExtractFilePath(aDestinationFile);
  if aPath <> '' then
    ForceDirectories(aPath);

  LDestStream := TFileStream.Create(aDestinationFile, fmCreate);
  try
    Get(aFileUrl, LDestStream);
  finally
    FreeAndNil(LDestStream);
  end;
end;

procedure TIdHTTPProgress.HTTPWork(ASender: TObject; aWorkMode: TWorkMode; aWorkCount: Int64);
begin
  if BytesToTransfer = 0 then // No Update File
    Exit;

  Progress := Round((aWorkCount / BytesToTransfer) * 100);
end;

procedure TIdHTTPProgress.HTTPWorkBegin(ASender: TObject; aWorkMode: TWorkMode; aWorkCountMax: Int64);
begin
  fBytesToTransfer := aWorkCountMax;
end;

procedure TIdHTTPProgress.HTTPWorkEnd(Sender: TObject; aWorkMode: TWorkMode);
begin
  Progress := 100;
  fBytesToTransfer := 0;
end;

procedure TIdHTTPProgress.SetOnChange(const Value: TNotifyEvent);
begin
  fOnChange := Value;
end;

procedure TIdHTTPProgress.SetProgress(const Value: Integer);
begin
  fProgress := Value;
  if Assigned(fOnChange) then
    fOnChange(Self);
end;

end.

