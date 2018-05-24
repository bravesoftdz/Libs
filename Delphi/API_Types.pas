unit API_Types;

interface

uses
  System.Classes;

type
  TMIMEType = (mtUnknown, mtBMP, mtJPEG, mtPNG, mtGIF);

  TObjProc = procedure of object;

  TMethodEngine = class
  public
    class procedure AddProcToArr(var aProcArr: TArray<TMethod>; aCode, aData: Pointer);
    class procedure ExecProcArr(aProcArr: TArray<TMethod>);
    class procedure RemoveProcFromArr(var aProcArr: TArray<TMethod>; aCode, aData: Pointer);
  end;

  TStreamEngine = class
  public
    class function CreateStreamFromByteString(const aByteString: string): TStream;
    class function GetByteString(aStream: TStream): string;
  end;

  function MIMETypeToStr(const aMIMEType: TMIMEType): string;
  function StrToMIMEType(const aStr: string): TMIMEType;

implementation

uses
  System.SysUtils;

class procedure TMethodEngine.RemoveProcFromArr(var aProcArr: TArray<TMethod>; aCode, aData: Pointer);
var
  i: Integer;
  Method: TMethod;
begin
  for i := 0 to Length(aProcArr) - 1 do
    if (aProcArr[i].Code = aCode) and
       (aProcArr[i].Data = aData)
    then
      begin
        Delete(aProcArr, i, 1);
      end;
end;

class function TStreamEngine.CreateStreamFromByteString(const aByteString: string): TStream;
var
  Buffer: TBytes;
begin
  Buffer := BytesOf(aByteString);

  Result := TMemoryStream.Create;
  Result.Write(Buffer, 0, Length(Buffer));
  Result.Position := 0;
end;

class function TStreamEngine.GetByteString(aStream: TStream): string;
var
  Buffer: TBytes;
begin
  SetLength(Buffer, aStream.Size);
  aStream.Read(Buffer, 0, aStream.Size);
  Result := StringOf(Buffer);
end;

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
