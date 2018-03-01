unit eCommon;

interface

uses
  API_ORM;

type
  TEntity = class(TEntityFeatID)
  end;

  TEntityList<T: TEntity> = class(TEntityAbstractList<T>)
  end;

implementation

end.
