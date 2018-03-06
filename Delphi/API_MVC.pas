unit API_MVC;

interface

uses
  System.Generics.Collections,
  System.Threading;

type
  TModelAbstract = class;
  TModelClass = class of TModelAbstract;

  TControllerAbstract = class;
  TControllerClass = class of TControllerAbstract;

  TObjProc = procedure of object;
  TViewMessageProc = procedure(const aMsg: string) of object;
  TModelMessageProc = procedure(const aMsg: string; aModel: TModelAbstract) of object;
  TModelInitProc = procedure(aModel: TModelAbstract) of object;

  /// <summary>
  /// inheritor class name have to contain verb f.e. TModelDoSomething
  /// </summary>
  TModelAbstract = class abstract
  private
    FOnModelMessage: TModelMessageProc;
    function GetEndMessage: string;
    procedure Execute(Sender: TObject);
  protected
    FCanceled: Boolean;
    FDataObj: TObjectDictionary<string, TObject>;
    FIsAsync: Boolean;
    FTask: ITask;
    FTaskIndex: Integer;
    procedure AfterCreate; virtual;
    procedure BeforeDestroy; virtual;
    procedure SendMessage(aMsg: string);
  public
    /// <summary>
    /// Override this procedure as point of enter to Model work.
    /// </summary>
    procedure Start; virtual; abstract;
    procedure Stop;
    constructor Create(aDataObj: TObjectDictionary<string, TObject>; aTaskIndex: Integer = 0); virtual;
    destructor Destroy; override;
    property EndMessage: string read GetEndMessage;
    property TaskIndex: Integer read FTaskIndex;
  end;

  IViewAbstract = interface
    function GetCloseMessage: string;
    procedure InitMVC(var aControllerClass: TControllerClass);
    procedure SendMessage(aMsg: string);
    property CloseMessage: string read GetCloseMessage;
  end;

{$M+}
  TControllerAbstract = class abstract
  private
    FRunningModelArr: TArray<TModelAbstract>;
    function GetViewListener: TViewMessageProc;
    procedure DoViewListener(const aMsg: string);
    procedure ModelInit(aModel: TModelAbstract);
    procedure RemoveModel(aModel: TModelAbstract);
  protected
    FIsAsyncModelRunMode: Boolean;
    FDataObj: TObjectDictionary<string, TObject>;
    procedure CallModel<T: TModelAbstract>(aThreadCount: Integer = 1);
    procedure CallModelAsync<T: TModelAbstract>(aThreadCount: Integer = 1);
    procedure ModelListener(const aMsg: string; aModel: TModelAbstract); virtual;
    procedure PerfomViewMessage(const aMsg: string); virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    property ViewListener: TViewMessageProc read GetViewListener;
  end;
{$M-}

  TPlatformSupport = class abstract
  protected
    FController: TControllerAbstract;
  public
    constructor Create(aController: TControllerAbstract);
  end;

implementation

uses
  System.SysUtils;

procedure TControllerAbstract.CallModelAsync<T>(aThreadCount: Integer = 1);
begin
  FIsAsyncModelRunMode := True;
  CallModel<T>(aThreadCount);
  FIsAsyncModelRunMode := False;
end;

constructor TPlatformSupport.Create(aController: TControllerAbstract);
begin
  FController := aController;
end;

procedure TControllerAbstract.RemoveModel(aModel: TModelAbstract);
var
  i: Integer;
  Model: TModelAbstract;
begin
  for i := 0 to Length(FRunningModelArr) - 1 do
    if FRunningModelArr[i] = aModel then
      Break;

  Delete(FRunningModelArr, i, 1);
end;

procedure TModelAbstract.Stop;
begin
  FCanceled := True;
end;

function TModelAbstract.GetEndMessage: string;
begin
  Result := Format('On%sEnd',[Self.ClassName.Substring(1)]);
end;

procedure TModelAbstract.BeforeDestroy;
begin
end;

destructor TModelAbstract.Destroy;
begin
  BeforeDestroy;

  inherited;
end;

procedure TModelAbstract.AfterCreate;
begin
end;

function TControllerAbstract.GetViewListener: TViewMessageProc;
begin
  Result := DoViewListener;
end;

procedure TControllerAbstract.ModelInit(aModel: TModelAbstract);
var
  ModelInitProc: TModelInitProc;
  ModelInitProcName: string;
begin
  ModelInitProcName := Format('On%sInit',[aModel.ClassName.Substring(1)]);

  TMethod(ModelInitProc).Code := Self.MethodAddress(ModelInitProcName);
  TMethod(ModelInitProc).Data := Self;

  if Assigned(ModelInitProc) then
    ModelInitProc(aModel);
end;

procedure TModelAbstract.SendMessage(aMsg: string);
begin
  FOnModelMessage(aMsg, Self);
end;

procedure TControllerAbstract.ModelListener(const aMsg: string; aModel: TModelAbstract);
var
  ModelMessageProc: TModelMessageProc;
begin
  if aMsg = aModel.EndMessage then
    RemoveModel(aModel);

  TMethod(ModelMessageProc).Code := Self.MethodAddress(aMsg);
  TMethod(ModelMessageProc).Data := Self;

  if Assigned(ModelMessageProc) then
    ModelMessageProc(aMsg, aModel);
end;

constructor TModelAbstract.Create(aDataObj: TObjectDictionary<string, TObject>; aTaskIndex: Integer = 0);
begin
  FTaskIndex := aTaskIndex;
  FDataObj := aDataObj;

  AfterCreate;
end;

procedure TModelAbstract.Execute(Sender: TObject);
begin
  Start;
  SendMessage(EndMessage);

  if not FIsAsync then
    Free;
end;

procedure TControllerAbstract.CallModel<T>(aThreadCount: Integer = 1);
var
  i: Integer;
  Model: TModelAbstract;
  ModelClass: TModelClass;
  Task: ITask;
begin
  for i := 1 to aThreadCount do
    begin
      ModelClass := T;
      Model := ModelClass.Create(FDataObj, i - 1);
      Model.FOnModelMessage := ModelListener;
      Model.FIsAsync := FIsAsyncModelRunMode;

      ModelInit(Model);

      Task := TTask.Create(Self, Model.Execute);

      Model.FTask := Task;
      FRunningModelArr := FRunningModelArr + [Model];

      Task.Start;
    end;
end;

destructor TControllerAbstract.Destroy;
var
  Model: TModelAbstract;
  TaskArr: array of ITask;
begin
  for Model in FRunningModelArr do
    begin
      Model.Stop;
      TaskArr := TaskArr + [Model.FTask];
    end;

  TTask.WaitForAll(TaskArr);

  FDataObj.Free;

  inherited;
end;

procedure TControllerAbstract.PerfomViewMessage(const aMsg: string);
begin
end;

procedure TControllerAbstract.DoViewListener(const aMsg: string);
var
  ControllerProc: TObjProc;
begin
  TMethod(ControllerProc).Code := Self.MethodAddress(aMsg);
  TMethod(ControllerProc).Data := Self;

  if Assigned(ControllerProc) then
    ControllerProc
  else
    PerfomViewMessage(aMsg);
end;

constructor TControllerAbstract.Create;
begin
  FDataObj := TObjectDictionary<string, TObject>.Create([]);
end;

end.
