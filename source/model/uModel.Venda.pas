unit uModel.Venda;

interface

uses
  FireDAC.Comp.Client, uDMConexao, uVenda,System.Generics.Collections;

type
  TModelVenda = class
  private
    fDMConexao : TDMConexao;
  public
    constructor Create;
    destructor Destroy; override;
    function listarEspecifico(id : Integer) : TVenda;
    function listar() : TList<TVenda>;
    function cadastrar(venda : TVenda;
      out erro : String) : Boolean;
    function atualizar(venda : TVenda;
      out erro : String) : Boolean;
    function deletar(venda : TVenda;
      out erro : String): Boolean;
  end;

implementation

uses
  System.SysUtils, uCliente, uVendaItem, uProduto;

{ TModelVenda }

constructor TModelVenda.Create;
begin
  fDMConexao := TDMConexao.Create(nil);
  fDMConexao.conectarBD;
end;

destructor TModelVenda.Destroy;
begin
  if Assigned(fDMConexao) then
    FreeAndNil(fDMConexao);
  inherited;
end;

function TModelVenda.cadastrar(venda: TVenda; out erro: String): Boolean;
var
  qry : TFDQuery;
begin

  try

    try

      qry := fDMConexao.criarQry;

      with qry do
      begin

        if venda.cliente.id <= 0 then
        begin
          erro := 'Cliente não informado!';
          Result := false;
          exit;
        end;

        SQL.Clear;

        SQL.Add(' SELECT ID      '+
                ' FROM CLIENTES  '+
                ' WHERE ID = :ID ' );

        Params.ParamByName('ID').AsInteger := venda.cliente.id;

        Open;

        if IsEmpty then
        begin
          erro   := 'Cliente não localizado na base de dados';
          Result := false;
          exit;
        end;

        SQL.Clear;

        SQL.Add(' SELECT GEN_ID(GEN_VENDAS_ID, 1) '+
                ' FROM RDB$DATABASE;');

        Open;

        venda.id := FieldByName('GEN_ID').AsInteger;

        SQL.Clear;

        SQL.Add(' INSERT INTO VENDAS (ID, DATA_VENDA, ID_CLIENTE) '+
                ' VALUES (:ID, :DATA_VENDA, :ID_CLIENTE) ');

        ParamByName('ID').AsInteger         := venda.id;
        ParamByName('DATA_VENDA').AsDate    := now;
        ParamByName('ID_CLIENTE').AsInteger := venda.cliente.id;

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

function TModelVenda.atualizar(venda: TVenda; out erro: String): Boolean;
var
  qry : TFDQuery;
begin

  try

    try

      qry := fDMConexao.criarQry;

      with qry do
      begin

        if (venda.id <= 0) or (venda.cliente.id <=0)  then
        begin
          erro := 'Venda ou cliente inválido!';
          Result := false;
          exit;
        end;

        SQL.Add(' SELECT *       '+
                ' FROM CLIENTES  '+
                ' WHERE ID = :ID ');

        ParamByName('ID').AsInteger := venda.cliente.id;

        Open;

        if IsEmpty then
        begin
          erro := 'Cliente não cadastrado na base de dados';
          Result := false;
          exit;
        end;

        SQL.Clear;

        SQL.Add(' SELECT *       '+
                ' FROM VENDAS    '+
                ' WHERE ID = :ID ');

        ParamByName('ID').AsInteger := venda.id;

        Open;

        if IsEmpty then
        begin
          erro := 'Venda não existente na base de dados';
          Result := false;
          exit;
        end;

        SQL.Clear;

        SQL.Add(' UPDATE VENDAS                    '+
                '    SET DATA_VENDA = :DATA_VENDA, '+
                '    ID_CLIENTE = :ID_CLIENTE      '+
                ' WHERE (ID = :ID) ');

        ParamByName('ID').AsInteger         := venda.id;
        ParamByName('DATA_VENDA').AsDate    := venda.dataVenda;
        ParamByName('ID_CLIENTE').AsInteger := venda.cliente.id;

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

function TModelVenda.listar: TList<TVenda>;
var
  qry : TFDQuery;
  venda : TVenda;
begin

  try

    try

      Result := TList<TVenda>.Create;

      qry := fDMConexao.criarQry;

      with qry do
      begin

        SQL.Add(' SELECT ID     '+
                ' FROM VENDAS V ');

        Open;

        if not IsEmpty then
        begin

          First;

          while not Eof do
          begin

            venda := listarEspecifico(FieldByName('ID').AsInteger);

            Result.Add(venda);

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

function TModelVenda.listarEspecifico(id: Integer): TVenda;
var
  vendaItem : TVendaItem;
begin

  try

    with fDMConexao.criarQry do
    begin

      SQL.Clear;

      SQL.Add(' SELECT V.ID,                  '+
              '        V.DATA_VENDA,          '+
              '        C.ID AS ID_CLIENTE,    '+
              '        C.NOME,                '+
              '        C.DT_NASCIMENTO,       '+
              '        C.DOCUMENTO            '+
              ' FROM VENDAS V JOIN CLIENTES C '+
              '   ON V.ID_CLIENTE = C.ID '+
              ' WHERE V.ID = :ID ');

      ParamByName('ID').AsInteger := id;

      Open;

      if not IsEmpty then
      begin

        Result := TVenda.Create;
        Result.cliente := TCliente.Create;

        Result.id                   := FieldByName('ID').AsInteger;
        Result.dataVenda            := FieldByName('DATA_VENDA').AsDateTime;
        Result.cliente.id           := FieldByName('ID_CLIENTE').AsInteger;
        Result.cliente.nome         := FieldByName('NOME').AsString;
        Result.cliente.dtNascimento := FieldByName('DT_NASCIMENTO').AsDateTime;
        Result.cliente.documento    := FieldByName('DOCUMENTO').AsString;

      end
      else
      begin
        Result := nil;
        exit;
      end;

      SQL.Clear;

      SQL.Add(' SELECT VI.ID,                        '+
              '        VI.ID_VENDA,                  '+
              '        VI.QUANTIDADE,                '+
              '        VI.ID_PRODUTO,                '+
              '        P.NOME,                       '+
              '        P.VALOR                       '+
              ' FROM VENDAS_ITENS VI JOIN PRODUTOS P '+
              '   ON VI.ID_PRODUTO = P.ID            '+
              ' WHERE VI.ID_VENDA = :ID');

      ParamByName('ID').AsInteger := Result.id;

      Open;

      if not IsEmpty then
      begin

        First;

        Result.listaItens := TList<TVendaItem>.Create;

        while not eof do
        begin

          vendaItem := TVendaItem.Create;

          vendaItem.id         := FieldByName('ID').AsInteger;
          vendaItem.idVenda    := FieldByName('ID_VENDA').AsInteger;
          vendaItem.quantidade := FieldByName('QUANTIDADE').AsCurrency;

          vendaItem.produto    := TProduto.Create;

          vendaItem.produto.id    := FieldByName('ID_PRODUTO').AsInteger;
          vendaitem.produto.nome  := FieldByName('NOME').AsString;
          vendaItem.produto.valor := FieldByName('VALOR').AsCurrency;

          Result.listaItens.Add(vendaItem);

          Next;

        end;

      end;

    end;

  except
    on e:Exception do
    begin
      Result := nil;
      raise Exception.Create('Erro ao consultar venda');
    end;

  end;

end;

function TModelVenda.deletar(venda: TVenda; out erro: String): Boolean;
var
  qry : TFDQuery;
begin

  try

    try

      qry := fDMConexao.criarQry;

      with qry do
      begin

        SQL.Clear;

        SQL.Add(' SELECT *       '+
                ' FROM VENDAS    '+
                ' WHERE ID = :ID ');

        ParamByName('ID').AsInteger := venda.id;

        Open;

        if IsEmpty then
        begin
          erro := 'Venda não existente na base de dados';
          Result := false;
          exit;
        end;

        SQL.Clear;

        SQL.Add(' DELETE FROM VENDAS_ITENS '+
                ' WHERE (ID_VENDA = :ID_VENDA)');

        ParamByName('ID_VENDA').AsInteger := venda.id;

        ExecSQL;

        SQL.Clear;

        SQL.Add(' DELETE FROM VENDAS '+
                ' WHERE (ID = :ID)');

        ParamByName('ID').AsInteger := venda.id;

        ExecSQL;

        fDMConexao.FDConnection.Commit;

        Result := true;

      end;

    except
      on e:Exception do
      begin
        Result := false;
        raise Exception.Create('Erro ao deletar venda');
      end;
    end;

  finally
    FreeAndNil(qry);
  end;

end;

end.
