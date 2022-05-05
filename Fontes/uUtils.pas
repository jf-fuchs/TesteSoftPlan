unit uUtils;

interface

uses
  System.SysUtils, System.UITypes, Data.DB, VCL.Forms, Dialogs;

type
  TModeCopyDataSetToVirtualTable = (mcvtAppend, mcvtUpdate, mcvtAppendUpdate, mcvtDelete);

type
  TUtils = class
  public
    class function ExtractFileFromURL(aURL: string): string;
    class Procedure MsgErro(aMsg: string);
  end;

implementation


class function TUtils.ExtractFileFromURL(aURL: string): string;
var
  Aux: Integer;
begin
  Aux := LastDelimiter('/', aUrl);
  Result := Copy(aUrl, Aux + 1, Length(aUrl) - (Aux));
end;


class procedure TUtils.MsgErro(aMsg: string);
begin
  MessageDlg(aMsg, TMsgDlgType.mtError, [mbOk], 0);
end;

end.
