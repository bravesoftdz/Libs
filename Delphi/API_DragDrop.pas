unit API_DragDrop;

interface

uses
  Vcl.Forms,
  Winapi.Messages,
  Winapi.ShellAPI;

type
  TDragDropEngine = class
  private
    FForm: TForm;
    function GetFileCount(aDropHandle: HDROP): Integer;
    function GetFileName(aDropHandle: HDROP; aIndx: Integer): string;
  public
    function GetDropedFiles(aMsg: TWMDropFiles): TArray<string>;
    constructor Create(aForm: TForm);
    destructor Destroy; override;
  end;

implementation

function TDragDropEngine.GetFileName(aDropHandle: HDROP; aIndx: Integer): string;
var
  FileNameLength: Integer;
begin
  FileNameLength := DragQueryFile(aDropHandle, aIndx, nil, 0);
  SetLength(Result, FileNameLength);
  DragQueryFile(aDropHandle, aIndx, PChar(Result), FileNameLength + 1);
end;

function TDragDropEngine.GetFileCount(aDropHandle: HDROP): Integer;
begin
  Result := DragQueryFile(aDropHandle, $FFFFFFFF, nil, 0);
end;

function TDragDropEngine.GetDropedFiles(aMsg: TWMDropFiles): TArray<string>;
var
  FileCount: Integer;
  i: Integer;
begin
  Result := [];

  FileCount := GetFileCount(aMsg.Drop);
  for i := 0 to FileCount - 1 do
    begin
      Result := Result + [GetFileName(aMsg.Drop, i)];
    end;

  DragFinish(aMsg.Drop);
end;

constructor TDragDropEngine.Create(aForm: TForm);
begin
  FForm := aForm;

  DragAcceptFiles(FForm.Handle, True);
end;

destructor TDragDropEngine.Destroy;
begin
  DragAcceptFiles(FForm.Handle, False);
end;

end.
