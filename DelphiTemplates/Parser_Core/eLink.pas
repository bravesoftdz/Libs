unit eLink;

interface

uses
  API_ORM,
  eCommon,
  eIternalRequests;

type
  TLink = class(TEntity)
  private
    FBodyGroupID: Integer;
    FHandledTypeID: Integer;
    FHash: string;
    FIternalRequestList: TIternalRequestList;
    FJobID: Integer;
    FLevel: Integer;
    FOwnerGroupID: Integer;
    FURL: string;
    function GetIternalRequestList: TIternalRequestList;
    procedure SetURL(aValue: string);
  public
    class function GetStructure: TSructure; override;
    function AddIternalRequest(const aURL: string): TIternalRequest;
    property IternalRequestList: TIternalRequestList read GetIternalRequestList;
  published
    property BodyGroupID: Integer read FBodyGroupID write FBodyGroupID;
    property HandledTypeID: Integer read FHandledTypeID write FHandledTypeID;
    property Hash: string read FHash write FHash;
    property JobID: Integer read FJobID write FJobID;
    property Level: Integer read FLevel write FLevel;
    property OwnerGroupID: Integer read FOwnerGroupID write FOwnerGroupID;
    property URL: string read FURL write SetURL;
  end;

  TLinkList = TEntityAbstractList<TLink>;

implementation

uses
  eGroup,
  System.Hash;

function TLink.AddIternalRequest(const aURL: string): TIternalRequest;
begin
  Result := TIternalRequest.Create(FDBEngine);
  Result.URL := aURL;

  IternalRequestList.Add(Result);
end;

function TLink.GetIternalRequestList: TIternalRequestList;
begin
  if not Assigned(FIternalRequestList) then
    FIternalRequestList := TIternalRequestList.Create(Self);

  Result := FIternalRequestList;
end;

procedure TLink.SetURL(aValue: string);
begin
  FURL := aValue;
  FHash := THashMD5.GetHashString(aValue);
end;

class function TLink.GetStructure: TSructure;
begin
  Result.TableName := 'CORE_LINKS';

  AddForeignKey(Result.ForeignKeyArr, 'OWNER_GROUP_ID', TGroup, 'ID');
end;

end.
