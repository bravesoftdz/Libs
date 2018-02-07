unit mParserBase;

interface

uses
  API_HTTP,
  API_MVC_DB,
  eGroup,
  eLink;

type
  TEachGroupRef = reference to procedure(const aArrRow: string; var aGroup: TGroup);

  TModelParser = class(TModelDB)
  private
    FHTTP: THTTP;
    function GetNextLink: TLink;
    procedure AddZeroLink;
    procedure ProcessLink(aLink: TLink);
  protected
    procedure AddInEachGroup(aLink: TLink; aDataArr: TArray<string>; aEachGroupProc: TEachGroupRef);
    procedure AddLink(const aLevel: Integer; const aURL: string);
    procedure AfterCreate; override;
    procedure BeforeDestroy; override;
    procedure ProcessPageRoute(const aPage: string; var aLink: TLink); virtual; abstract;
  public
    inDomen: string;
    inJobID: Integer;
    procedure Start; override;
  end;

implementation

uses
  eJob,
  FireDAC.Comp.Client;

procedure TModelParser.AddLink(const aLevel: Integer; const aURL: string);
var
  Link: TLink;
begin
  Link := TLink.Create(FDBEngine);
  try
    Link.JobID := inJobID;
    Link.Level := aLevel;
    Link.Link := aURL;
    Link.HandledTypeID := 1;

    Link.Store;
  finally
    Link.Free;
  end;
end;

procedure TModelParser.AddInEachGroup(aLink: TLink; aDataArr: TArray<string>; aEachGroupProc: TEachGroupRef);
var
  ArrRow: string;
  Group: TGroup;
begin
  for ArrRow in aDataArr do
    begin
      Group := TGroup.Create(FDBEngine);
      aEachGroupProc(ArrRow, Group);
      aLink.GroupList.Add(Group);
    end;
end;

procedure TModelParser.ProcessLink(aLink: TLink);
var
  Page: string;
begin
  Page := FHTTP.Get(aLink.Link);

  ProcessPageRoute(Page, aLink);
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
    Link.Link := Job.ZeroLink;
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
  dsQuery := TFDQuery.Create(nil);
  try
    SQL := 'select Id from links t where t.job_id = :JobID and t.handled_type_id = 1 order by t.level desc, t.id limit 1 ';
    dsQuery.SQL.Text := SQL;
    dsQuery.ParamByName('JobID').AsInteger := inJobID;
    FDBEngine.OpenQuery(dsQuery);

    if dsQuery.IsEmpty then
      begin
        AddZeroLink;
        Result := GetNextLink;
      end
    else
      Result := TLink.Create(FDBEngine, dsQuery.Fields[0].AsInteger);
  finally
    dsQuery.Free;
  end;
end;

procedure TModelParser.BeforeDestroy;
begin
  FHTTP.Free;
end;

procedure TModelParser.AfterCreate;
begin
  FHTTP := THTTP.Create;
end;

procedure TModelParser.Start;
var
  Link: TLink;
begin
  while not FCanceled do
    begin
      Link := GetNextLink;
      try
        Link.HandledTypeID := 2;
        Link.Store;

        ProcessLink(Link);

        Link.StoreAll;
      finally
        Link.Free;
      end;
    end;
end;

end.
