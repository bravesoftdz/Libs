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
  public
    class function GetStructure: TSructure; override;
    property HeaderItem[const aName: string]: string read GetHeaderItem;
    property PostDataItem[const aName: string]: string read GetPostDataItem;
  published
    property Headers: string read FHeaders write FHeaders;
    property LinkID: Integer read FLinkID write FLinkID;
    property PostData: string read FPostData write FPostData;
    property URL: string read FURL write FURL;
  end;

implementation

uses
  API_Strings,
  System.SysUtils;

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
end;

end.
