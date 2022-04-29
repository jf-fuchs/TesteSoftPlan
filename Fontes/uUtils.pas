unit uUtils;

interface

uses
  System.SysUtils, Data.DB, VCL.Forms;

type
  TModeCopyDataSetToVirtualTable = (mcvtAppend, mcvtUpdate, mcvtAppendUpdate, mcvtDelete);

type
  TUtils = class
  public
    class function ExtractFileFromURL(aURL: string): string;
  end;

implementation


class function TUtils.ExtractFileFromURL(aURL: string): string;
var
  Aux: Integer;
begin
  Aux := LastDelimiter('/', aUrl);
  Result := Copy(aUrl, Aux + 1, Length(aUrl) - (Aux));
end;


end.
