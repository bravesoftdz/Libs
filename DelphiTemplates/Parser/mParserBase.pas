unit mParserBase;

interface

uses
  API_HTTP,
  API_MVC_DB,
  eGroup,
  eLink,
  System.Classes;

type
  TEachGroupRef = reference to procedure(const aArrRow: string; var aGroup: TGroup);

  TModelParser = class(TModelDB)
  private
    FHTTP: THTTP;
    function GetNextLink: TLink;
    procedure AddZeroLink;
    procedure ParsePostData(var aPostStringList: TStringList; aPostData: string);
    procedure ProcessLink(aLink: TLink; out aBodyGroup: TGroup);
  protected
    procedure AddAsEachGroup(aOwnerGroup: TGroup; aDataArr: TArray<string>; aEachGroupProc: TEachGroupRef);
    procedure AddPostOrHeaderData(var aPostData: string; const aKey, aValue: string);
    procedure AfterCreate; override;
    procedure BeforeDestroy; override;
    procedure ProcessPageRoute(const aPage: string; aLink: TLink; var aBodyGroup: TGroup); virtual; abstract;
  public
    inDomain: string;
    inJobID: Integer;
    procedure Start; override;
  end;

implementation

uses
  eJob,
  FireDAC.Comp.Client,
  System.SysUtils;

procedure TModelParser.ParsePostData(var aPostStringList: TStringList; aPostData: string);
var
  PostDataArr: TArray<string>;
  PostDataRow: string;
begin
  PostDataArr := aPostData.Split([';']);

  for PostDataRow in PostDataArr do
    aPostStringList.Add(PostDataRow);
end;

procedure TModelParser.AddPostOrHeaderData(var aPostData: string; const aKey, aValue: string);
begin
  if not aPostData.IsEmpty then
    aPostData := aPostData + ';';

  aPostData := aPostData + Format('%s=%s', [aKey, aValue]);
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
  PostSL: TStringList;
begin
  aBodyGroup := TGroup.Create(FDBEngine, aLink.BodyGroupID);
  aBodyGroup.ParentGroupID := aLink.OwnerGroupID;

  if aLink.PostData.IsEmpty then
    Page := FHTTP.Get(aLink.Link)
  else
    begin
      PostSL := TStringList.Create;
      try
        ParsePostData(PostSL, aLink.PostData);
        FHTTP.SetHeaders(aLink.Headers);
        Page := FHTTP.Post(aLink.Link, PostSL)
      finally
        PostSL.Free;
      end;
    end;

  ProcessPageRoute(Page, aLink, aBodyGroup);
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
  BodyGroup: TGroup;
  Link: TLink;
begin
  while not FCanceled do
    begin
      // CS
      Link := GetNextLink;
      Link.HandledTypeID := 2;
      Link.Store;
      // CS

      try
        ProcessLink(Link, BodyGroup);

        BodyGroup.StoreAll;
        Link.BodyGroupID := BodyGroup.ID;
        Link.Store;
      finally
        BodyGroup.Free;
        Link.Free;
      end;
    end;
end;

end.
