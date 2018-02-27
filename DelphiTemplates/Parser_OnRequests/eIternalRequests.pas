unit eIternalRequests;

interface

uses
  API_ORM,
  eCommon;

type
  TIternalRequest = class(TEntity)
  private
    FHeaders: string;
    FLinkID: Integer;
    FPostData: string;
    FURL: string;
    function GetHeaderItem(const aName: string): string;
    function GetStrItem(const aStr, aName: string): string;
    function GetPostDataItem(const aName: string): string;
    procedure SetHeaderItem(const aName, aValue: string);
    procedure SetPostDataItem(const aName, aValue: string);
    procedure SetStrItem(var aProp: string; const aName, aValue: string);
  public
    class function GetStructure: TSructure; override;
    property HeaderItem[const aName: string]: string read GetHeaderItem write SetHeaderItem;
    property PostDataItem[const aName: string]: string read GetPostDataItem write SetPostDataItem;
  published
    property Headers: string read FHeaders write FHeaders;
    property LinkID: Integer read FLinkID write FLinkID;
    property PostData: string read FPostData write FPostData;
    property URL: string read FURL write FURL;
  end;

  TIternalRequestList = TEntityAbstractList<TIternalRequest>;

implementation

uses
  API_Strings,
  eLink,
  System.SysUtils;

procedure TIternalRequest.SetStrItem(var aProp: string; const aName, aValue: string);
var
  i: Integer;
  Index: Integer;
  PostDataArr: TArray<string>;
begin
  Index := -1;
  PostDataArr := aProp.Split([';']);

  for i := 0 to Length(PostDataArr) - 1 do
    if TStrTool.ExtractKey(PostDataArr[i]) = aName then
      begin
        Index := i;
        Break;
      end;

  if Index = -1 then
    PostDataArr := PostDataArr + [Format('%s=%s', [aName, aValue])]
  else
    PostDataArr[Index] := Format('%s=%s', [aName, aValue]);

  aProp := string.Join(';', PostDataArr);
end;

procedure TIternalRequest.SetPostDataItem(const aName, aValue: string);
begin
  SetStrItem(FPostData, aName, aValue);
end;

procedure TIternalRequest.SetHeaderItem(const aName, aValue: string);
begin
  SetStrItem(FHeaders, aName, aValue);
end;

function TIternalRequest.GetPostDataItem(const aName: string): string;
begin
  Result := GetStrItem(PostData, aName);
end;

function TIternalRequest.GetHeaderItem(const aName: string): string;
begin
  Result := GetStrItem(Headers, aName);
end;

function TIternalRequest.GetStrItem(const aStr, aName: string): string;
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

class function TIternalRequest.GetStructure: TSructure;
begin
  Result.TableName := 'RQST_ITERNAL_REQUESTS';

  AddForeignKey(Result.ForeignKeyArr, 'LINK_ID', TLink, 'ID');
end;

end.
