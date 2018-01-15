unit API_Strings;

interface

type
  TMyStr = type string;

  TMyStrHelper = record helper for TMyStr
  public
    function CutByKey(aFirstKey: string; aLastKey: string; aFirstKeyNum: integer = 1): TMyStr;
    function CutHTMLTags: TMyStr;

    procedure SaveToFile(FileName: String);
  end;

implementation

uses
  System.Classes,
  System.SysUtils;

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

procedure TMyStrHelper.SaveToFile(FileName: String);
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    SL.Text := Self;
    SL.SaveToFile(FileName);
  finally
    SL.Free;
  end;
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
