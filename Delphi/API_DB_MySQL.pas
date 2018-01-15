unit API_DB_MySQL;

interface

uses
  API_DB,
  FireDAC.Phys.MySQL;

type
  TMySQLEngine = class(TDBEngine)
  protected
    procedure SetConnectParams; override;
  public
    function GetLastInsertedID: integer; override;
  end;

implementation

uses
  FireDAC.Comp.Client;

function TMySQLEngine.GetLastInsertedID: integer;
var
  dsQuery: TFDQuery;
begin
  Result := 0;

  dsQuery := TFDQuery.Create(nil);
  try
    dsQuery.SQL.Text := 'select LAST_INSERT_ID()';
    OpenQuery(dsQuery);

    Result := dsQuery.Fields[0].AsInteger;
  finally
    dsQuery.Free;
  end;
end;

procedure TMySQLEngine.SetConnectParams;
begin
  inherited;
  FDConnection.Params.Values['DriverID'] := 'MySQL';
end;

end.
