unit uModel.VendaItem;

interface

uses
  System.Generics.Collections, uVendaItem, uDMConexao,FireDAC.Comp.Client;

type
  TModelVendaItem = class
  private
    fDMConexao : TDMConexao;
  public
    constructor Create;
    destructor Destroy; override;
    function validarCadastroItem(vendaItem : TVendaItem;
      qry : TFDQuery; out erro : String) : Boolean;

    function listarEspecifico(id : Integer) : TVendaItem;
    function listar(idVenda : Integer) : TList<TVendaItem>;
    function cadastrar(vendaItem : TVendaItem;
      out erro : String) : Boolean;
    function atualizar(vendaItem : TVendaItem;
      out erro : String) : Boolean;
    function deletar(vendaItem : TVendaItem;
      out erro : String): Boolean;
  end;

implementation

uses
  System.SysUtils, uProduto;

{ TModelVendaItem }

constructor TModelVendaItem.Create;
begin
  fDMConexao := TDMConexao.Create(nil);
  fDMConexao.conectarBD;
end;

destructor TModelVendaItem.Destroy;
begin
  if Assigned(fDMConexao) then
    FreeAndNil(fDMConexao);
  inherited;
end;

function TModelVendaItem.atualizar(vendaItem: TVendaItem;
  out erro: String): Boolean;
var
  qry : TFDQuery;
begin

  try

    try

      qry := fDMConexao.criarQry;

      with qry do
      begin

        if (vendaItem.id <=0) or (vendaItem.quantidade <= 0) then
        begin
          erro := 'ID de venda ou quantidade inválida!';
          Result := false;
          exit;
        end;

        SQL.Clear;

        SQL.Add(' SELECT *          '+
                ' FROM VENDAS_ITENS '+
                ' WHERE ID = :ID ');

        ParamByName('ID').AsInteger := vendaItem.id;

        Open;

        if IsEmpty then
        begin
          erro := 'Item não localizado no sistema';
          Result := false;
          exit;
        end;

        SQL.Clear;

        SQL.Add(' UPDATE VENDAS_ITENS             '+
                '    SET QUANTIDADE = :QUANTIDADE '+
                ' WHERE ID = :ID ' );

        ParamByName('ID').AsInteger    := vendaItem.id;
        ParamByName('QUANTIDADE').AsCurrency := vendaItem.quantidade;

        ExecSQL;

        fDMConexao.FDConnection.Commit;

        Result := True;

      end;

    except
      on e:Exception do
        raise Exception.Create('Erro ao atualizar venda: ' + e.Message);
    end;

  finally
    FreeAndnil(qry);
  end;

end;

function TModelVendaItem.cadastrar(vendaItem: TVendaItem;
  out erro: String): Boolean;
var
  qry : TFDQuery;
begin

  try

    try

      qry := fDMConexao.criarQry;

      if not validarCadastroItem(vendaItem,qry,erro) then
      begin
        Result := false;
        exit;
      end;

      with qry do
      begin

        SQL.Clear;

        SQL.Add(' SELECT ID        '+
                ' FROM VENDAS_ITENS '+
                ' WHERE ID_PRODUTO = :ID  ');

        Params.ParamByName('ID').AsInteger := vendaItem.produto.id;

        Open;

        if not IsEmpty then
        begin
          erro   := 'Produto já está cadastrado nessa venda, tente atualizar o mesmo!';
          Result := false;
          exit;
        end;

        SQL.Clear;

        SQL.Add(' SELECT GEN_ID(GEN_VENDAS_ITENS_ID, 1) '+
                ' FROM RDB$DATABASE;');

        Open;

        vendaItem.id := FieldByName('GEN_ID').AsInteger;

        SQL.Clear;

        SQL.Add(' INSERT INTO VENDAS_ITENS (ID, ID_VENDA, ID_PRODUTO, '+
                '                           QUANTIDADE)               '+
                ' VALUES (:ID, :ID_VENDA, :ID_PRODUTO, :QUANTIDADE)   ');

        ParamByName('ID').AsInteger          := vendaItem.id;
        ParamByName('ID_VENDA').AsInteger    := vendaItem.idVenda;
        ParamByName('ID_PRODUTO').AsInteger  := vendaItem.produto.id;
        ParamByName('QUANTIDADE').AsCurrency := vendaItem.quantidade;

        ExecSQL;

        fDMConexao.FDConnection.Commit;

        Result := True;

      end;

    except
      on e:Exception do
        raise Exception.Create('Erro ao cadastrar venda: ' + e.Message);
    end;

  finally
    FreeAndnil(qry);
  end;

end;

function TModelVendaItem.deletar(vendaItem: TVendaItem;
  out erro: String): Boolean;
var
  qry : TFDQuery;
begin

  try

    try

      qry := fDMConexao.criarQry;

      with qry do
      begin

        SQL.Clear;

        SQL.Add(' SELECT *          '+
                ' FROM VENDAS_ITENS '+
                ' WHERE ID = :ID ');

        ParamByName('ID').AsInteger := vendaItem.id;

        Open;

        if IsEmpty then
        begin
          erro := 'Item não localizado no sistema';
          Result := false;
          exit;
        end;

        SQL.Clear;

        SQL.Add(' DELETE FROM VENDAS_ITENS '+
                ' WHERE (ID = :ID)         ');

        ParamByName('ID').AsInteger := vendaItem.id;

        ExecSQL;

        fDMConexao.FDConnection.Commit;

        Result := true;

      end;

    except
      on e:Exception do
      begin
        Result := false;
        raise Exception.Create('Erro ao deletar item da venda');
      end;
    end;

  finally
    FreeAndNil(qry);
  end;

end;

function TModelVendaItem.listar(idVenda: Integer): TList<TVendaItem>;
var
  qry : TFDQuery;
  vendaItem : TVendaItem;
begin

  try

    try

      Result := TList<TVendaItem>.Create;

      qry := fDMConexao.criarQry;

      with qry do
      begin

        SQL.Add(' SELECT ID                 '+
                ' FROM VENDAS_ITENS V       '+
                ' WHERE ID_VENDA = :idVenda ');

        Params.ParamByName('idVenda').AsInteger := idVenda;

        Open;

        if not IsEmpty then
        begin

          First;

          while not Eof do
          begin

            vendaItem := listarEspecifico(FieldByName('ID').AsInteger);

            Result.Add(vendaItem);

            Next;

          end;

        end
        else
          Result := nil;

      end;

    except
      on e:exception do
      begin
        Result := nil;
        raise Exception.Create('Erro ao consultar lista de vendas');
      end;
    end;

  finally
    qry.Free;
  end;

end;

function TModelVendaItem.listarEspecifico(id: Integer): TVendaItem;
var
  vendaItem : TVendaItem;
begin

  try

    with fDMConexao.criarQry do
    begin

      SQL.Clear;

      SQL.Add(' SELECT VI.ID,                                                '+
              '        VI.ID_VENDA,                                          '+
              '        VI.ID_PRODUTO,                                        '+
              '        P.NOME,                                               '+
              '        P.VALOR,                                              '+
              '        VI.QUANTIDADE                                         '+
              ' FROM VENDAS_ITENS VI JOIN PRODUTOS P ON VI.ID_PRODUTO = P.ID '+
              ' WHERE VI.ID = :ID ');

      ParamByName('ID').AsInteger := id;

      Open;

      if not IsEmpty then
      begin

        Result := TVendaItem.Create;

        Result.id         := FieldByName('ID').AsInteger;
        Result.idVenda    := FieldByName('ID_VENDA').AsInteger;
        Result.quantidade := FieldByName('QUANTIDADE').AsCurrency;

        Result.produto    := TProduto.Create;

        Result.produto.id    := FieldByName('ID_PRODUTO').AsInteger;
        Result.produto.nome  := FieldByName('NOME').AsString;
        Result.produto.valor := FieldByName('VALOR').AsCurrency;

      end
      else
        Result := nil;

    end;

  except
    on e:Exception do
    begin
      Result := nil;
      raise Exception.Create('Erro ao consultar venda');
    end;

  end;

end;

function TModelVendaItem.validarCadastroItem(vendaItem : TVendaItem;
  qry: TFDQuery; out erro : String): Boolean;
begin

  if vendaItem.produto.id <= 0 then
  begin
    erro := 'Código do produto inválido';
    Result := false;
    exit;
  end;

  if vendaItem.quantidade <= 0 then
  begin
    erro := 'Quantidade informada é inválida!';
    Result := false;
    exit;
  end;

  with qry do
  begin

    SQL.Clear;

    SQL.Add(' SELECT ID      '+
            ' FROM PRODUTOS  '+
            ' WHERE ID = :ID ' );

    Params.ParamByName('ID').AsInteger := vendaItem.produto.id;

    Open;

    if IsEmpty then
    begin
      erro   := 'Produto não cadastrado na base de dados!';
      Result := false;
      exit;
    end;

    SQL.Clear;

    SQL.Add(' SELECT ID       '+
            ' FROM VENDAS     '+
            ' WHERE ID = :ID  ');

    Params.ParamByName('ID').AsInteger := vendaItem.idVenda;

    Open;

    if IsEmpty then
    begin
      erro   := 'Venda não existe no sistema, Informe corretamente o código da venda!';
      Result := false;
      exit;
    end;

    Result := true;

  end;

end;

end.
