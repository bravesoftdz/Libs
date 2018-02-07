unit eLink;

interface

uses
  API_ORM,
  eCommon,
  eGroup;

type
  TLink = class(TEntity)
  private
    FGroupList: TGroupList;
    FHandledTypeID: Integer;
    FJobID: Integer;
    FLevel: Integer;
    FLink: string;
    function GetGroupList: TGroupList;
  public
    class function GetStructure: TSructure; override;
    property GroupList: TGroupList read GetGroupList;
  published
    property HandledTypeID: Integer read FHandledTypeID write FHandledTypeID;
    property JobID: Integer read FJobID write FJobID;
    property Level: Integer read FLevel write FLevel;
    property Link: string read FLink write FLink;
  end;

implementation

function TLink.GetGroupList: TGroupList;
begin
  if not Assigned(FGroupList) then
    FGroupList := TGroupList.Create(Self);

  Result := FGroupList;
end;

class function TLink.GetStructure: TSructure;
begin
  Result.TableName := 'LINKS';
end;

end.
