unit API_Crypt;

interface

uses
  LbCipher,
  LbClass;

type
  TCryptParams = record
    SynchKey: TKey128;
  end;

  TCryptEngine = class abstract
  protected
    FCrypter: TObject;
  public
    function Decrypt(aValue: string): string; virtual; abstract;
    function Encrypt(aValue: string): string; virtual; abstract;
    constructor Create(aCryptParams: TCryptParams); virtual; abstract;
    destructor Destroy; override;
  end;

  TCryptEngineClass = class of TCryptEngine;

  TCryptBlowfish = class(TCryptEngine)
  private
    function GetCrypter: TLbBlowfish;
  public
    function Decrypt(aValue: string): string; override;
    function Encrypt(aValue: string): string; override;
    constructor Create(aCryptParams: TCryptParams); override;
    property Crypter: TLbBlowfish read GetCrypter;
  end;

implementation

constructor TCryptBlowfish.Create(aCryptParams: TCryptParams);
begin
  inherited;

  FCrypter := TLbBlowfish.Create(nil);
  Crypter.SetKey(aCryptParams.SynchKey);
end;

function TCryptBlowfish.GetCrypter: TLbBlowfish;
begin
  Result := FCrypter as TLbBlowfish;
end;

function TCryptBlowfish.Decrypt(aValue: string): string;
begin
  Result := Crypter.DecryptString(aValue);
end;

function TCryptBlowfish.Encrypt(aValue: string): string;
begin
  Result := Crypter.EncryptString(aValue);
end;

destructor TCryptEngine.Destroy;
begin
  FCrypter.Free;
  inherited;
end;

end.
