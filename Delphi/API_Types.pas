unit API_Types;

interface

type
  TMIMEType = (mtUnknown, mtBMP, mtJPEG, mtPNG, mtGIF);

  TObjProc = procedure of object;

  TMethodEngine = class
  public
    class procedure AddProcToArr(var aProcArr: TArray<TMethod>; aCode, aData: Pointer);
    class procedure ExecProcArr(aProcArr: TArray<TMethod>);
  end;

  function MIMETypeToStr(const aMIMEType: TMIMEType): string;
  function StrToMIMEType(const aStr: string): TMIMEType;

implementation

function StrToMIMEType(const aStr: string): TMIMEType;
begin
  Result := mtUnknown;

  if aStr = 'image/jpg' then
    Result := mtJPEG
  else
  if aStr = 'image/jpeg' then
    Result := mtJPEG
  else
  if aStr = 'image/png' then
    Result := mtPNG;
end;

function MIMETypeToStr(const aMIMEType: TMIMEType): string;
begin
  Result := '';

  case aMIMEType of
    mtJPEG: Result := 'image/jpg';
    mtPNG: Result := 'image/png';
  end;
end;

class procedure TMethodEngine.ExecProcArr(aProcArr: TArray<TMethod>);
var
  Proc: TObjProc;
  Method: TMethod;
begin
  for Method in aProcArr do
    begin
      Proc := TObjProc(Method);
      Proc;
    end;
end;

class procedure TMethodEngine.AddProcToArr(var aProcArr: TArray<TMethod>; aCode, aData: Pointer);
var
  Method: TMethod;
begin
  Method.Code := aCode;
  Method.Data := aData;

  aProcArr := aProcArr + [Method];
end;

end.
