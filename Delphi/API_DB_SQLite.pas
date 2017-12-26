unit API_DB_SQLite;

interface

uses
  API_DB,
  FireDAC.Comp.Client,
  FireDAC.Phys.SQLite;

type
  TSQLiteEngine = class(TDBEngine)
  private
    FLastInsertedTable: string;
  protected
    procedure SetConnectParams; override;
  public
    function GetLastInsertedID: Integer; override;
    procedure ExecQuery(aQuery: TFDQuery); override;
  end;

implementation

uses
  System.SysUtils;

procedure TSQLiteEngine.ExecQuery(aQuery: TFDQuery);
var
  SQLWords: TArray<string>;
begin
  if Pos('INSERT INTO', UpperCase(aQuery.SQL.Text)) > 0 then
    begin
      SQLWords := aQuery.SQL.Text.Split([' ']);
      FLastInsertedTable := SQLWords[2];
    end;

  inherited;
end;

procedure TSQLiteEngine.SetConnectParams;
begin
  inherited;

  FDConnection.Params.Values['DriverID'] := 'SQLite';
end;

function TSQLiteEngine.GetLastInsertedID: Integer;
var
  dsQuery: TFDQuery;
begin
  Result := 0;

  dsQuery := TFDQuery.Create(nil);
  try
    dsQuery.SQL.Text := 'select seq from sqlite_sequence where name = :table';
    dsQuery.ParamByName('table').AsString := LowerCase(FLastInsertedTable);

    OpenQuery(dsQuery);
    Result := dsQuery.Fields[0].AsInteger;
  finally
    dsQuery.Free;
  end;
end;

end.
