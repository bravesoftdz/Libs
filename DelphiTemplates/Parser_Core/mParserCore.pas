unit mParserCore;

interface

uses
  API_MVC_DB,
  eGroup,
  eLink,
  System.SyncObjs;

type
  TEachGroupRef = reference to procedure(const aArrRow: string; var aGroup: TGroup);

  TModelParser = class abstract(TModelDB)
  private
    function CheckFirstRun: Boolean;
    function GetNextLink: TLink;
    procedure AddZeroLink;
  protected
    procedure AddAsEachGroup(aOwnerGroup: TGroup; aDataArr: TArray<string>; aEachGroupProc: TEachGroupRef);
    procedure ProcessLink(aLink: TLink; out aBodyGroup: TGroup); virtual;
  public
    inDomain: string;
    inJobID: Integer;
    procedure Start; override;
  end;

var
  CriticalSection: TCriticalSection;

implementation

uses
  eJob,
  FireDAC.Comp.Client,
  System.Classes,
  System.SysUtils;

function TModelParser.CheckFirstRun: Boolean;
var
  dsQuery: TFDQuery;
  SQL: string;
begin
  dsQuery := TFDQuery.Create(nil);
  try
    SQL := 'select count(*) from core_links t where t.job_id = :JobID';
    dsQuery.SQL.Text := SQL;
    dsQuery.ParamByName('JobID').AsInteger := inJobID;
    FDBEngine.OpenQuery(dsQuery);

    if dsQuery.Fields[0].AsInteger = 0 then
      Result := True
    else
      Result := False;
  finally
    dsQuery.Free;
  end;
end;

procedure TModelParser.AddAsEachGroup(aOwnerGroup: TGroup; aDataArr: TArray<string>; aEachGroupProc: TEachGroupRef);
var
  ArrRow: string;
  Group: TGroup;
begin
  for ArrRow in aDataArr do
    begin
      Group := TGroup.Create(FDBEngine);
      aEachGroupProc(ArrRow, Group);
      aOwnerGroup.ChildGroupList.Add(Group);
    end;
end;

procedure TModelParser.ProcessLink(aLink: TLink; out aBodyGroup: TGroup);
var
  Page: string;
begin
  aBodyGroup := TGroup.Create(FDBEngine, aLink.BodyGroupID);
  aBodyGroup.ParentGroupID := aLink.OwnerGroupID;

  //FCurrLink := aLink;

  //FHTTP.SetHeaders(aLink.Headers);

  {if aLink.PostData.IsEmpty then
    Page := FHTTP.Get(aLink.Link)
  else
    begin
      PostSL := TStringList.Create;
      try
        ParsePostData(PostSL, aLink.PostData);
        Page := FHTTP.Post(aLink.Link, PostSL)
      finally
        PostSL.Free;
      end;
    end;  }
end;

procedure TModelParser.AddZeroLink;
var
  Job: TJob;
  Link: TLink;
begin
  Job := TJob.Create(FDBEngine, inJobID);
  Link := TLink.Create(FDBEngine);
  try
    Link.JobID := Job.ID;
    Link.Level := 0;
    Link.URL := Job.ZeroLink;
    Link.HandledTypeID := 1;

    Link.Store;
  finally
    Job.Free;
    Link.Free;
  end;
end;

function TModelParser.GetNextLink: TLink;
var
  dsQuery: TFDQuery;
  SQL: string;
begin
  Result := nil;

  dsQuery := TFDQuery.Create(nil);
  try
    SQL := 'select Id from core_links t where t.job_id = :JobID and t.handled_type_id = 1 order by t.level desc, t.id limit 1 ';
    dsQuery.SQL.Text := SQL;
    dsQuery.ParamByName('JobID').AsInteger := inJobID;
    FDBEngine.OpenQuery(dsQuery);

    if dsQuery.IsEmpty then
      begin
        if CheckFirstRun then
          begin
            AddZeroLink;
            Result := GetNextLink;
          end;
      end
    else
      Result := TLink.Create(FDBEngine, dsQuery.Fields[0].AsInteger);
  finally
    dsQuery.Free;
  end;
end;

procedure TModelParser.Start;
var
  BodyGroup: TGroup;
  Link: TLink;
begin
  while not FCanceled do
    begin
      CriticalSection.Enter;

      Link := GetNextLink;

      if Link <> nil then
        begin
          Link.HandledTypeID := 2;
          Link.Store;
        end;

      CriticalSection.Leave;

      if Link <> nil then
        try
          ProcessLink(Link, BodyGroup);

          BodyGroup.StoreAll;

          Link.BodyGroupID := BodyGroup.ID;
          Link.HandledTypeID := 3;
          Link.Store;
        finally
          BodyGroup.Free;
          Link.Free;
        end;
    end;
end;

initialization
  CriticalSection := TCriticalSection.Create;

finalization
  CriticalSection.Free;

end.
