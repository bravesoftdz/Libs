unit eJob;

interface

uses
  API_ORM,
  eCommon;

type
  TJob = class(TEntity)
  private
    FCaption: string;
    FZeroLink: string;
  public
    class function GetStructure: TSructure; override;
  published
    property Caption: string read FCaption write FCaption;
    property ZeroLink: string read FZeroLink write FZeroLink;
  end;

implementation

class function TJob.GetStructure: TSructure;
begin
  Result.TableName := 'JOBS';
end;

end.
