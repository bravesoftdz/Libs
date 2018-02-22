unit eRecord;

interface

uses
  API_ORM,
  eCommon;

type
  TRecord = class(TEntity)
  private
    FKey: string;
    FOwnerGroupID: Integer;
    FValue: string;
  public
    class function GetStructure: TSructure; override;
  published
    property Key: string read FKey write FKey;
    property OwnerGroupID: Integer read FOwnerGroupID write FOwnerGroupID;
    property Value: string read FValue write FValue;
  end;

  TRecordList = TEntityAbstractList<TRecord>;

implementation

uses
  eGroup;

class function TRecord.GetStructure: TSructure;
begin
  Result.TableName := 'RECORDS';

  AddForeignKey(Result.ForeignKeyArr, 'OWNER_GROUP_ID', TGroup, 'ID');
end;

end.
