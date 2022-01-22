unit uVendaItem;

interface

uses
  uProduto, System.JSON;

type
  TVendaItem = class
  private
    Fproduto: TProduto;
    Fid: Integer;
    FidVenda: Integer;
    Fquantidade: Currency;
    procedure Setid(const Value: Integer);
    procedure SetidVenda(const Value: Integer);
    procedure Setproduto(const Value: TProduto);
    procedure Setquantidade(const Value: Currency);
    { private declarations }
  public
    property id : Integer read Fid write Setid;
    property idVenda : Integer read FidVenda write SetidVenda;
    property produto : TProduto read Fproduto write Setproduto;
    property quantidade : Currency read Fquantidade write Setquantidade;
    destructor Destroy(); override;
    function toJson() : TJsonObject;
  end;

implementation

uses
  System.SysUtils;

{ TItemVenda }

destructor TVendaItem.Destroy;
begin
  if Assigned(produto) then
    FreeAndNil(produto);
  inherited;
end;

procedure TVendaItem.Setid(const Value: Integer);
begin
  Fid := Value;
end;

procedure TVendaItem.SetidVenda(const Value: Integer);
begin
  FidVenda := Value;
end;

procedure TVendaItem.Setproduto(const Value: TProduto);
begin
  Fproduto := Value;
end;

procedure TVendaItem.Setquantidade(const Value: Currency);
begin
  Fquantidade := Value;
end;

function TVendaItem.toJson: TJsonObject;
var
  jsonProduto : TJsonObject;
begin

  Result := TJSONObject.Create;

  Result.AddPair('id', TJSONNumber.Create(Self.id));
  Result.AddPair('idVenda', TJSONNumber.Create(Self.idVenda));
  Result.AddPair('quantidade', TJSONNumber.Create(Self.quantidade));

  jsonProduto := TJSONObject.Create;
  jsonProduto.AddPair('id',TJSONNumber.Create(Self.produto.id));
  jsonProduto.AddPair('nome',Self.produto.nome );
  jsonProduto.AddPair('valor',TJSONNumber.Create(Self.produto.valor) );


  Result.AddPair('produto',jsonProduto);

end;

end.
