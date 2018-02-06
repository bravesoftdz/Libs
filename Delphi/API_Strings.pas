unit API_Strings;

interface

type
  TStrTool = class
    class function CutArrayByKey(const aStr, aFirstKey, aLastKey: string): TArray<string>;
    class function CutByKey(const aStr, aFirstKey, aLastKey: string; aFirstKeyNum: integer = 1): string;
    class function Reverse(const aStr: string): string;
  end;

  TMyStr = type string;

  TMyStrHelper = record helper for TMyStr
  public
    function CutHTMLTags: TMyStr;

    procedure SaveToFile(const aPath: string);
  end;

implementation

uses
  API_Files,
  System.Classes,
  System.SysUtils;

class function TStrTool.CutArrayByKey(const aStr, aFirstKey, aLastKey: string): TArray<string>;
var
  Page: string;
  Row: string;
begin
  Page := aStr;
  Result := [];

  while Page.Contains(aFirstKey) do
    begin
      Row := CutByKey(Page, aFirstKey, aLastKey);
      Result := Result + [Row];

      Page := Page.Remove(0, Page.IndexOf(aFirstKey) + aFirstKey.Length);
      Page := Page.Remove(0, Page.IndexOf(aLastKey) + aLastKey.Length);
    end;
end;

class function TStrTool.Reverse(const aStr: string): string;
var
  i: Integer;
begin
  Result := '';

  for i := aStr.Length downto 1 do
    Result := Result + aStr[i];
end;

function TMyStrHelper.CutHTMLTags: TMyStr;
var
  i: Integer;
  IsOpenTag: Boolean;
  TagText: string;
begin
  IsOpenTag := False;
  TagText := '';
  Result := Self;

  for i := 1 to Length(Self) do
    begin
      if (Pos(Result, '>') = 0) and
         (Pos(Result, '<') = 0)
      then
        Exit(Result);

      if Self[i] = '<' then
        IsOpenTag := True;

      if IsOpenTag then
        TagText := TagText + Self[i];

      if Result[i] = '>' then
        begin
          Result := StringReplace(Result, TagText, '', [rfReplaceAll, rfIgnoreCase]);

          IsOpenTag := False;
          TagText := '';
        end;
    end;
end;

procedure TMyStrHelper.SaveToFile(const aPath: string);
begin
  TFilesEngine.SaveTextToFile(aPath, Self);
end;

class function TStrTool.CutByKey(const aStr, aFirstKey, aLastKey: string; aFirstKeyNum: integer = 1): string;
var
  i: integer;
begin
  Result := aStr;

  for i := 1 to aFirstKeyNum - 1 do
    Result := Result.Remove(0, Result.IndexOf(aFirstKey) + aFirstKey.Length);

  if Result.Contains(aFirstKey) or
     aFirstKey.IsEmpty
  then
    begin
      Result := Result.Substring(Result.IndexOf(aFirstKey) + aFirstKey.Length, Result.Length);
      Result := Result.Remove(Result.IndexOf(aLastKey), Result.Length);
    end
  else
    Result := '';
end;

end.
