unit API_Files;

interface

uses
  System.Classes;

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
    class function GetFileStream(const aPath: string): TFileStream;
    class function GetMIMEType(const aPath: string): string;
    class function GetTextFromFile(const aPath: string): string;
    class procedure Move(aSourceFullPath, aDestFullPath: string; aForceDir: Boolean = True);
    class procedure SaveTextToFile(const aPath, aText: string);
  end;

implementation

uses
  System.IOUtils,
  System.SysUtils,
  System.Types;

class function TFilesEngine.GetMIMEType(const aPath: string): string;
var
  Ext: string;
begin
  Result := '';

  Ext := UpperCase(ExtractFileExt(aPath));

  if (Ext = '.JPG') or
     (Ext = '.JPEG')
  then
    Result := 'image/jpeg'
  else
  if (Ext = '.PNG') then
    Result := 'image/png'
  else
  if (Ext = '.BMP') then
    Result := 'image/bmp'
  else
  if (Ext = '.GIF') then
    Result := 'image/gif';
end;

class function TFilesEngine.GetFileStream(const aPath: string): TFileStream;
begin
  Result := TFile.OpenRead(aPath);
end;

class procedure TFilesEngine.Move(aSourceFullPath, aDestFullPath: string; aForceDir: Boolean = True);
var
  DestDirectory: string;
begin
  if aForceDir then
    begin
      DestDirectory := TPath.GetDirectoryName(aDestFullPath);
      if not TDirectory.Exists(DestDirectory) then
        TDirectory.CreateDirectory(DestDirectory);
    end;

  TFile.Move(aSourceFullPath, aDestFullPath);
end;

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
