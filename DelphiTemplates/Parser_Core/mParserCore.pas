unit mParserCore;

interface

uses
  API_MVC_DB;

type
  TModelParser = class abstract(TModelDB)
  public
    inDomain: string;
    inJobID: Integer;
    procedure Start; override;
  end;

implementation

procedure TModelParser.Start;
begin
end;

end.
