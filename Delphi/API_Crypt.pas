unit API_Crypt;

interface

uses
  LbRSA,
  LbClass;

type
  TCryptParams = record
    PrivateExponent: string;
    PrivateModulus: string;
    PublicExponent: string;
    PublicModulus: string;
  end;

  TCryptEngine = class abstract
  private
    FLbRSA: TLbRSA;
    FLbBlowfish: TLbBlowfish;
  public
    function Decrypt(aValue: string): string;
    function Encrypt(aValue: string): string;
    constructor Create(aCryptParams: TCryptParams);
    destructor Destroy; override;
  end;

  TCryptRSA = class(TCryptEngine)
  end;

  TCryptEngineClass = class of TCryptEngine;

implementation

uses LbAsym, LbCipher;

function TCryptEngine.Decrypt(aValue: string): string;
begin
  //Result := FLbRSA.DecryptString(aValue);
  Result := FLbBlowfish.DecryptString(aValue);
end;

function TCryptEngine.Encrypt(aValue: string): string;
begin
  //Result := FLbRSA.EncryptString(aValue);
  Result := FLbBlowfish.EncryptString(aValue);
end;

destructor TCryptEngine.Destroy;
begin
  FLbRSA.Free;
  FLbBlowfish.Free;
  inherited;
end;

const Key: TKey128 = (168, 195, 109, 253, 15, 207, 211, 55, 254, 74, 229, 230, 16, 174, 49, 201);

constructor TCryptEngine.Create(aCryptParams: TCryptParams);
var
  Temp: string;
  //Key: TKey128;
begin
 FLbBlowfish := TLbBlowfish.Create(nil);

  FLbRSA := TLbRSA.Create(nil);

  FLbRSA.KeySize := aks128;

  FLbRSA.PrivateKey.ModulusAsString := aCryptParams.PrivateModulus;
  FLbRSA.PrivateKey.ExponentAsString := aCryptParams.PrivateExponent;
  FLbRSA.PublicKey.ModulusAsString := aCryptParams.PublicModulus;
  FLbRSA.PublicKey.ExponentAsString := aCryptParams.PublicExponent;

//FLbBlowfish.GenerateKey('fdgfdg');
//FLbBlowfish.GetKey(Key);

  FLbBlowfish.SetKey(Key);

  //Temp := FLbRSA.DecryptString('Bh2rgfAVmaq4JOBfDJ/IQrTROunnQzFBLTC0m6ZY7TA1iTGe36s+1d9rF+HzafpYwHY2PRqzqL8SxwgM+BtJAA==');
end;

end.
