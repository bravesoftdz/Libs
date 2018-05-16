unit API_Types;

interface

type
  TObjProc = procedure of object;

  TMethodEngine = class
  public
    class procedure AddProcToArr(var aProcArr: TArray<TMethod>; aCode, aData: Pointer);
    class procedure ExecProcArr(aProcArr: TArray<TMethod>);
  end;

implementation

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
