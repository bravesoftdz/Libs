unit eCommon;

interface

uses
  API_ORM;

type
  TEntity = class(TEntityFeatID)
  public
    constructor Create(aID: Integer = 0);
  end;

  TEntityList<T: TEntityAbstract> = class(TEntityAbstractList<T>)
  public
    constructor Create(aFilterArr, aOrderArr: TArray<string>); overload;
  end;

implementation

uses
  cController;

constructor TEntityList<T>.Create(aFilterArr, aOrderArr: TArray<string>);
begin
  Create(cController.DBEngine, aFilterArr, aOrderArr);
end;

constructor TEntity.Create(aID: Integer = 0);
begin
  inherited Create(cController.DBEngine, aID);
end;

end.
