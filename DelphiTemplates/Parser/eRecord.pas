unit eRecord;

interface

uses
  API_ORM,
  eCommon;

type
  TRecord = class(TEntity)
  private
    FGroupID: Integer;
    FKey: string;
    FValue: string;
  public
    class function GetStructure: TSructure; override;
  published
    property GroupID: Integer read FGroupID write FGroupID;
    property Key: string read FKey write FKey;
    property Value: string read FValue write FValue;
  end;

  TRecordList = TEntityAbstractList<TRecord>;

implementation

uses
  eGroup;

class function TRecord.GetStructure: TSructure;
begin
  Result.TableName := 'RECORDS';

  AddForeignKey(Result.ForeignKeyArr, 'GROUP_ID', TGroup, 'ID');
end;

end.
