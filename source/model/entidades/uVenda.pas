unit uVenda;

interface

uses
  uVendaItem, uCliente, System.Generics.Collections, System.JSON;

type
  TVenda = class
  private
    FdataVenda: TDate;
    Fcliente: TCliente;
    FlistaItens: TList<TVendaItem>;
    Fid: Integer;
    procedure Setcliente(const Value: TCliente);
    procedure SetdataVenda(const Value: TDate);
    procedure Setid(const Value: Integer);
    procedure SetlistaItens(const Value: TList<TVendaItem>);
    { private declarations }
  public
    property id : Integer read Fid write Setid;
    property dataVenda : TDate read FdataVenda write SetdataVenda;
    property cliente : TCliente read Fcliente write Setcliente;
    property listaItens : TList<TVendaItem> read FlistaItens write SetlistaItens;
    destructor Destroy(); override;
    function toJson() : TJSONObject;
  end;

implementation

uses
  System.SysUtils;

{ TVenda }

destructor TVenda.Destroy;
begin

  if Assigned(listaItens) then
    FreeAndNil(listaItens);

  if Assigned(cliente) then
    FreeAndNil(cliente);

  inherited;
end;

procedure TVenda.Setcliente(const Value: TCliente);
begin
  Fcliente := Value;
end;

procedure TVenda.SetdataVenda(const Value: TDate);
begin
  FdataVenda := Value;
end;

procedure TVenda.Setid(const Value: Integer);
begin
  Fid := Value;
end;

procedure TVenda.SetlistaItens(const Value: TList<TVendaItem>);
begin
  FlistaItens := Value;
end;

function TVenda.toJson() : TJSONObject;
var
  jsonObjVendaItem, jsonObjCliente : TJSONObject;
  jsonArrayVendaItem : TJsonArray;
  I: Integer;
begin

  Result := TJSONObject.Create;

  Result.AddPair('id', TJSONNumber.Create(Self.id));
  Result.AddPair('data_venda', DateToStr(Self.dataVenda));

  jsonObjCliente := TJSONObject.Create;
  jsonObjCliente.AddPair('id',TJSONNumber.Create(Self.cliente.id));
  jsonObjCliente.AddPair('nome',Self.cliente.nome );

  Result.AddPair('cliente',jsonObjCliente);

  jsonArrayVendaItem := TJSONArray.Create;

  if Assigned(Self.listaItens) then
  begin

    for I := 0 to pred(Self.listaItens.Count) do
    begin

      jsonObjVendaItem := TJSONObject.Create;

      jsonObjVendaItem.AddPair('id',TJSONNumber.Create(self.listaItens[i].id) );
      jsonObjVendaItem.AddPair('id_produto',TJSONNumber.Create(self.listaItens[i].produto.id) );
      jsonObjVendaItem.AddPair('nome',TJSONNumber.Create(self.listaItens[i].produto.nome) );
      jsonObjVendaItem.AddPair('quantidade',TJSONNumber.Create(self.listaItens[i].quantidade));

      jsonArrayVendaItem.AddElement(jsonObjVendaItem);

    end;

  end;

  Result.AddPair('itens', jsonArrayVendaItem);

end;

end.
