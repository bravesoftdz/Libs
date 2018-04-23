unit API_Files;

interface

type
  TFileInfo = record
  public
    DirectoryArr: TArray<string>;
    Drive: string;
    Extension: string;
    FileName: string;
    FullPath: string;
    Name: string;
    procedure LoadFromFile(aPath: string);
  end;

  TFilesEngine = class
  public
    class function GetFileInfoArr(const aPath: string): TArray<TFileInfo>;
    class function GetTextFromFile(const aPath: string): string;
    class procedure SaveTextToFile(const aPath, aText: string);
  end;

implementation

uses
  System.Classes,
  System.IOUtils,
  System.SysUtils,
  System.Types;

class procedure TFilesEngine.SaveTextToFile(const aPath, aText: string);
begin
  TFile.WriteAllText(aPath, aText);
end;

class function TFilesEngine.GetTextFromFile(const aPath: String): String;
var
  SL: TStringList;
begin
  //Result := TFile.ReadAllText(aPath);

  SL := TStringList.Create;
  try
    SL.LoadFromFile(aPath);
    Result := SL.Text;
  finally
    SL.Free;
  end;
end;

procedure TFileInfo.LoadFromFile(aPath: string);
var
  i: Integer;
  PathWords: TArray<string>;
  PointIndex: Integer;
begin
  PathWords := aPath.Split(['\']);

  FullPath := aPath;
  Drive := PathWords[0];

  DirectoryArr := [];
  for i := 1 to Length(PathWords) - 2 do
    DirectoryArr := DirectoryArr + [PathWords[i]];

  FileName := PathWords[High(PathWords)];

  PointIndex := FileName.LastIndexOf('.');
  Name := FileName.Substring(0, PointIndex);
  Extension := FileName.Substring(PointIndex + 1, FileName.Length);
end;

class function TFilesEngine.GetFileInfoArr(const aPath: string): TArray<TFileInfo>;
var
 FileInfo: TFileInfo;
 Files: TStringDynArray;
 i: Integer;
begin
  Result := [];

  if TDirectory.Exists(aPath) then
    begin
      Files := TDirectory.GetFiles(aPath);
    end
  else
  if TFile.Exists(aPath) then
    Files := [aPath];

  for i := 0 to Length(Files) - 1 do
    begin
      FileInfo.LoadFromFile(Files[i]);

      Result := Result + [FileInfo];
    end;
end;

end.
