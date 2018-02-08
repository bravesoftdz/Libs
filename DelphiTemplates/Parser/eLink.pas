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
    FHeaders: string;
    FJobID: Integer;
    FLevel: Integer;
    FLink: string;
    FOwnerGroupID: Integer;
    FPostData: string;
    function GetHeaderItem(const aName: string): string;
    function GetStrItem(const aStr, aName: string): string;
    function GetPostDataItem(const aName: string): string;
  public
    class function GetStructure: TSructure; override;
    property HeaderItem[const aName: string]: string read GetHeaderItem;
    property PostDataItem[const aName: string]: string read GetPostDataItem;
  published
    property BodyGroupID: Integer read FBodyGroupID write FBodyGroupID;
    property HandledTypeID: Integer read FHandledTypeID write FHandledTypeID;
    property Headers: string read FHeaders write FHeaders;
    property JobID: Integer read FJobID write FJobID;
    property Level: Integer read FLevel write FLevel;
    property Link: string read FLink write FLink;
    property OwnerGroupID: Integer read FOwnerGroupID write FOwnerGroupID;
    property PostData: string read FPostData write FPostData;
  end;

  TLinkList = TEntityAbstractList<TLink>;

implementation

uses
  API_Strings,
  eGroup,
  System.SysUtils;

function TLink.GetStrItem(const aStr, aName: string): string;
var
  StrArr: TArray<string>;
  StrRow: string;
begin
  Result := '';
  StrArr := aStr.Split([';']);

  for StrRow in StrArr do
    begin
      if aName = TStrTool.ExtractKey(StrRow) then
        Exit(TStrTool.ExtractValue(StrRow));
    end;
end;

function TLink.GetHeaderItem(const aName: string): string;
begin
  Result := GetStrItem(Headers, aName);
end;

function TLink.GetPostDataItem(const aName: string): string;
begin
  Result := GetStrItem(PostData, aName);
end;

class function TLink.GetStructure: TSructure;
begin
  Result.TableName := 'LINKS';

  AddForeignKey(Result.ForeignKeyArr, 'OWNER_GROUP_ID', TGroup, 'ID');
end;

end.
