unit eGroup;

interface

uses
  API_ORM,
  eCommon,
  eRecord;

type
  TGroup = class(TEntity)
  private
    FLinkID: Integer;
    FRecordList: TRecordList;
    function GetRecordList: TRecordList;
  public
    class function GetStructure: TSructure; override;
    procedure AddRecord(const aKey, aValue: string);
    property RecordList: TRecordList read GetRecordList;
  published
    property LinkID: Integer read FLinkID write FLinkID;
  end;

  TGroupList = TEntityAbstractList<TGroup>;

implementation

uses
  eLink;

function TGroup.GetRecordList: TRecordList;
begin
  if not Assigned(FRecordList) then
    FRecordList := TRecordList.Create(Self);

  Result := FRecordList;
end;

procedure TGroup.AddRecord(const aKey, aValue: string);
var
  Rec: TRecord;
begin
  Rec := TRecord.Create(DBEngine);
  Rec.Key := aKey;
  Rec.Value := aValue;

  RecordList.Add(Rec);
end;

class function TGroup.GetStructure: TSructure;
begin
  Result.TableName := 'GROUPS';

  AddForeignKey(Result.ForeignKeyArr, 'LINK_ID', TLink, 'ID');
end;

end.
