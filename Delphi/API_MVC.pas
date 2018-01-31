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
    procedure Execute(Sender: TObject);
  protected
    FDataObj: TObjectDictionary<string, TObject>;
    procedure SendMessage(aMsg: string);
  public
    /// <summary>
    /// Override this procedure as point of enter to Model work.
    /// </summary>
    procedure Start; virtual; abstract;
    constructor Create(aDataObj: TObjectDictionary<string, TObject>);
  end;

  IViewAbstract = interface
    procedure InitMVC(var aControllerClass: TControllerClass);
    procedure SendMessage(aMsg: string);
  end;

  TTaskData = record
    Model: TModelAbstract;
    Task: ITask;
  end;

{$M+}
  TControllerAbstract = class abstract
  private
    FTaskDataArr: TArray<TTaskData>;
    procedure DoViewListener(const aMsg: string);
    procedure ModelListener(const aMsg: string; aModel: TModelAbstract);
    procedure ModelInit(aModel: TModelAbstract);
    function GetViewListener: TViewMessageProc;
  protected
    FDataObj: TObjectDictionary<string, TObject>;
    procedure CallModel<T: TModelAbstract>(aThreadCount: Integer = 1);
    procedure PerfomViewMessage(const aMsg: string); virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    property ViewListener: TViewMessageProc read GetViewListener;
  end;
{$M-}

implementation

uses
  System.SysUtils;

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
  TMethod(ModelMessageProc).Code := Self.MethodAddress(aMsg);
  TMethod(ModelMessageProc).Data := Self;

  if Assigned(ModelMessageProc) then
    ModelMessageProc(aMsg, aModel);
end;

constructor TModelAbstract.Create(aDataObj: TObjectDictionary<string, TObject>);
begin
  FDataObj := aDataObj;
end;

procedure TModelAbstract.Execute(Sender: TObject);
begin
  Start;
  SendMessage(Format('On%sEnd',[Self.ClassName.Substring(1)]));
  Free;
end;

procedure TControllerAbstract.CallModel<T>(aThreadCount: Integer = 1);
var
  i: Integer;
  Model: TModelAbstract;
  ModelClass: TModelClass;
  Task: ITask;
  TaskData: TTaskData;
begin
  for i := 1 to aThreadCount do
    begin
      ModelClass := T;
      Model := ModelClass.Create(FDataObj);
      Model.FOnModelMessage := ModelListener;

      ModelInit(Model);

      Task := TTask.Create(Self, Model.Execute);

      TaskData.Task := Task;
      TaskData.Model := Model;

      FTaskDataArr := FTaskDataArr + [TaskData];

      Task.Start;
    end;
end;

destructor TControllerAbstract.Destroy;
begin
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
