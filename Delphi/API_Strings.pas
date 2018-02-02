unit API_Strings;

interface

type
  TStrTool = class
    class function Reverse(const aStr: string): string;
  end;

  TMyStr = type string;

  TMyStrHelper = record helper for TMyStr
  public
    function CutByKey(aFirstKey: string; aLastKey: string; aFirstKeyNum: integer = 1): TMyStr;
    function CutHTMLTags: TMyStr;

    procedure SaveToFile(const aPath: string);
  end;

implementation

uses
  API_Files,
  System.Classes,
  System.SysUtils;

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

function TMyStrHelper.CutByKey(aFirstKey: string; aLastKey: string; aFirstKeyNum: integer = 1): TMyStr;
var
  i: integer;
begin
  Result := Self;

  for i := 1 to aFirstKeyNum - 1 do
    Delete(Result, 1, Pos(aFirstKey, Result) + Length(aFirstKey));

  if Pos(aFirstKey, Result) > 0 then
    begin
      Result := Copy(Result, Pos(aFirstKey, Result) + Length(aFirstKey), Length(Result));
      Delete(Result, Pos(aLastKey, Result), Length(Result));
      Result := Trim(Result);
    end
  else
    Result := '';
end;

end.
