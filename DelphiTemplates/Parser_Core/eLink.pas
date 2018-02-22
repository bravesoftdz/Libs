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
    FJobID: Integer;
    FLevel: Integer;
    FOwnerGroupID: Integer;
    FURL: string;
  public
    class function GetStructure: TSructure; override;
  published
    property BodyGroupID: Integer read FBodyGroupID write FBodyGroupID;
    property HandledTypeID: Integer read FHandledTypeID write FHandledTypeID;
    property JobID: Integer read FJobID write FJobID;
    property Level: Integer read FLevel write FLevel;
    property OwnerGroupID: Integer read FOwnerGroupID write FOwnerGroupID;
    property URL: string read FURL write FURL;
  end;

  TLinkList = TEntityAbstractList<TLink>;

implementation

uses
  eGroup;

class function TLink.GetStructure: TSructure;
begin
  Result.TableName := 'CORE_LINKS';

  AddForeignKey(Result.ForeignKeyArr, 'OWNER_GROUP_ID', TGroup, 'ID');
end;

end.
