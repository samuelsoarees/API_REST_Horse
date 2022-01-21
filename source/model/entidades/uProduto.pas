unit uProduto;

interface

type
  TProduto = class
  private
    Fvalor: Currency;
    Fid: Integer;
    Fnome: String;
    procedure Setid(const Value: Integer);
    procedure Setnome(const Value: String);
    procedure Setvalor(const Value: Currency);
    { private declarations }
  public
    property id : Integer read Fid write Setid;
    property nome : String read Fnome write Setnome;
    property valor : Currency read Fvalor write Setvalor;
  end;

implementation

{ TProduto }

procedure TProduto.Setid(const Value: Integer);
begin
  Fid := Value;
end;

procedure TProduto.Setnome(const Value: String);
begin
  Fnome := Value;
end;

procedure TProduto.Setvalor(const Value: Currency);
begin
  Fvalor := Value;
end;

end.
