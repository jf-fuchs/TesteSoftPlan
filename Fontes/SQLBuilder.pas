unit SQLBuilder;

interface

uses
  SysUtils, DB, Uni, StrUtils, Variants, System.Classes;

const
  cEOL = #13;

type
  TSQLBuilder = class
  private
    FTableName: string;
    FLstColumns: TStringList;
    FLstWhere: TStringList;
    FLstOrder: TStringList;
    FLstValues: TStringList;
  public
    Query: TUniQuery;
    constructor Create(pDatabase: TUniConnection; pTableName: string);
    function    Select(pTabela: string): TSQLBuilder;
    function    AddColumn(pColumn: string): TSQLBuilder;
    function    From(Value: string): TSQLBuilder;
    function    AddWhere(pCondition: string): TSQLBuilder;
    function    WhereIsEmpty: Boolean;
    function    AddOrder(pOrder: string; const pDesc: Boolean = False): TSQLBuilder;
    function    AddParameter(pParam: string; pValue: Variant): TSQLBuilder;
    function    AddValue(pCampo: string; pValue: Variant): TSQLBuilder;
    function    Execute: Boolean;
    function    FBN(pColumn: string): TField;
    function    SetSQL: string;
    function    Prepare: TSQLBuilder;
    destructor  Destroy; override;
  public
    property TableName: string read FTableName write FTableName;
  end;

implementation

constructor TSQLBuilder.Create(pDatabase: TUniConnection; pTableName: string);
begin
  inherited Create;

  Query := TUniQuery.Create(nil);
  Query.Connection := pDatabase;

  FTableName := pTableName;

  FLstWhere := TStringList.Create;
  FLstOrder := TStringList.Create;
  FLstColumns := TStringList.Create;
  FLstValues := TStringList.Create;
end;

destructor TSQLBuilder.Destroy;
begin
  Query.Close;
  FreeAndNil(Query);
  FreeAndNil(FLstWhere);
  FreeAndNil(FLstOrder);
  FreeAndNil(FLstValues);
  FreeAndNil(FLstColumns);
  inherited;
end;

function TSQLBuilder.AddColumn(pColumn: string): TSQLBuilder;
begin
  FLstColumns.Add(pColumn);
  Result := Self;
end;

function TSQLBuilder.AddOrder(pOrder: string; const pDesc: Boolean = False): TSQLBuilder;
begin
  if pDesc then
    FLstOrder.Add(pOrder + ' DESC ')
  else
    FLstOrder.Add(pOrder);
  Result := Self;
end;

function TSQLBuilder.AddParameter(pParam: string; pValue: Variant): TSQLBuilder;
begin
  if Query.Params.FindParam(pParam) <> nil then
    Query.ParamByName(pParam).Value := pValue;
  Result := Self;
end;

function TSQLBuilder.AddValue(pCampo: string; pValue: Variant): TSQLBuilder;
begin
  FLstValues.Add(pCampo);
end;

function TSQLBuilder.AddWhere(pCondition: string): TSQLBuilder;
begin
  FLstWhere.Add(pCondition);
  Result := Self;
end;

function TSQLBuilder.WhereIsEmpty: Boolean;
begin
  Result := FLstWhere.Count <= 0;
end;

function TSQLBuilder.Execute: Boolean;
begin
  try
    if Query.SQL.Text = '' then
      Query.SQL.Text := SetSQL;
    Query.Open;
    Result := not Query.IsEmpty;
  except
    on e: exception do
    begin
      Result := False;
      ShowMessage(e.Message +kEOL+ 'Erro ao executar o comando SQL na tabela: '+FTableName);
    end;
  end;
end;

function TSQLBuilder.FBN(pColumn: string): TField;
begin
  Result := Query.FieldByName(pColumn);
end;

function TSQLBuilder.From(Value: string): TSQLBuilder;
begin
  if Value <> FTableName then
    FTableName := Value;
  Result := Self;
end;

function TSQLBuilder.Prepare: TSQLBuilder;
begin
  Query.SQL.Text := SetSQL;
  Result := Self;
end;

function TSQLBuilder.Select(pTabela: string): TSQLBuilder;
begin
  FTableName := pTabela;
end;

function TSQLBuilder.SetSQL: string;
var
  vAux: string;
  vInd: Integer;
begin
  if FLstColumns.Count <= 0 then
    vAux := '*'
  else
  begin
    vAux := '';
    for vInd := 0 to FLstColumns.Count-1 do
      vAux := vAux + IfThen((vAux <> ''), ', ','') + FLstColumns[vInd];
  end;
  Result := 'select ' + vAux + ' from ' + FTableName;

  if FLstWhere.Count > 0 then
  begin
    vAux := '';
    for vInd := 0 to FLstWhere.Count-1 do
      vAux := vAux + FLstWhere[vInd];

    Result := Result + ' where ' + vAux;
  end;

  if FLstOrder.Count > 0 then
  begin
    vAux := '';
    for vInd := 0 to FLstOrder.Count-1 do
      vAux := vAux + IfThen((vAux <> ''), ', ','') + FLstOrder[vInd];

    Result := Result + ' order by ' + vAux;
  end;
end;

end.
