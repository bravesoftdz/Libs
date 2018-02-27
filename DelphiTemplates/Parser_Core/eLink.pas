unit eLink;

interface

uses
  API_ORM,
  eCommon;

type
  TLink = class(TEntity)
  private
    FBodyGroupID: Integer;
    FHandledTypeID: Integer;
    FHash: string;
    FJobID: Integer;
    FLevel: Integer;
    FOwnerGroupID: Integer;
    FURL: string;
    procedure SetURL(aValue: string);
  public
    class function GetStructure: TSructure; override;
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
