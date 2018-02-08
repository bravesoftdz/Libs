unit eGroup;

interface

uses
  API_ORM,
  eCommon,
  eLink,
  eRecord;

type
  TGroupList = class;

  TGroup = class(TEntity)
  private
    FChildGroupList: TGroupList;
    FLinkList: TLinkList;
    FParentGroupID: Integer;
    FRecordList: TRecordList;
    FRootChain: string;
    function GetChildGroupList: TGroupList;
    function GetLinkList: TLinkList;
    function GetRecordList: TRecordList;
  public
    class function GetStructure: TSructure; override;
    procedure AddLink(const aJobID, aLevel: Integer; const aURL: string;
      aPostData: string = ''; aHeaders: string = '');
    procedure AddRecord(const aKey, aValue: string);
    property ChildGroupList: TGroupList read GetChildGroupList;
    property LinkList: TLinkList read GetLinkList;
    property RecordList: TRecordList read GetRecordList;
  published
    property ParentGroupID: Integer read FParentGroupID write FParentGroupID;
    property RootChain: string read FRootChain write FRootChain;
  end;

  TGroupList = class(TEntityAbstractList<TGroup>)
  end;

implementation

procedure TGroup.AddLink(const aJobID, aLevel: Integer; const aURL: string;
  aPostData: string = ''; aHeaders: string = '');
var
  Link: TLink;
begin
  Link := TLink.Create(FDBEngine);

  Link.JobID := aJobID;
  Link.Level := aLevel;
  Link.Link := aURL;
  Link.HandledTypeID := 1;
  Link.PostData := aPostData;
  Link.Headers := aHeaders;

  LinkList.Add(Link);
end;

function TGroup.GetLinkList: TLinkList;
begin
  if not Assigned(FLinkList) then
    FLinkList := TLinkList.Create(Self);

  Result := FLinkList;
end;

function TGroup.GetChildGroupList: TGroupList;
begin
  if not Assigned(FChildGroupList) then
    FChildGroupList := TGroupList.Create(Self);

  Result := FChildGroupList;
end;

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
  Rec := TRecord.Create(FDBEngine);
  Rec.Key := aKey;
  Rec.Value := aValue;

  RecordList.Add(Rec);
end;

class function TGroup.GetStructure: TSructure;
begin
  Result.TableName := 'GROUPS';

  AddForeignKey(Result.ForeignKeyArr, 'PARENT_GROUP_ID', TGroup, 'ID')
end;

end.
