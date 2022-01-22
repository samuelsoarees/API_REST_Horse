unit uModel.Produto;

interface

uses
  uProduto, FireDAC.Comp.Client, uDMConexao;

type
  TModelProduto = class
  private
    fDMConexao : TDMConexao;
    function consultarProduto(id: Integer): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    function listar(id : Integer) : TFDQuery;
    function cadastrar(produto : TProduto;
      out erro : String) : Boolean;
    function atualizar(produto : TProduto;
      out erro : String) : Boolean;
    function deletar(produto : TProduto;
      out erro : String): Boolean;
  end;

implementation

uses
  System.SysUtils;

{ TModelProduto }


function TModelProduto.consultarProduto(id: Integer): Boolean;
var
  qry : TFDQuery;
begin

  try
    qry := fDMConexao.criarQry;

    with qry do
    begin

      SQL.Clear;
      SQL.Add(' SELECT *       '+
              ' FROM PRODUTOS  '+
              ' WHERE ID = :ID ');
      ParamByName('ID').AsInteger := id;

      Open;

      Result := not IsEmpty;

    end;

  finally
    qry.Free;
  end;

end;

constructor TModelProduto.Create;
begin
  fDMConexao := TDMConexao.Create(nil);
  fDMConexao.conectarBD;
end;

destructor TModelProduto.Destroy;
begin
  if Assigned(fDMConexao) then
    FreeAndNil(fDMConexao);
  inherited;
end;

function TModelProduto.atualizar(produto: TProduto; out erro: String): Boolean;
var
  qry : TFDQuery;
begin

   try

    try

      qry := fDMConexao.criarQry;

      with qry do
      begin

        if (produto.id <= 0) or (produto.nome.IsEmpty) then
        begin
          erro := 'Código inválido, ou nome não informado';
          Result := false;
          exit;
        end;

        if not consultarProduto(produto.id) then
        begin
          Result := false;
          erro := 'Produto não cadastrado na base de dados';
          exit;
        end;

        SQL.Clear;

        SQL.Add(' UPDATE PRODUTOS     '+
                '  SET NOME = :NOME,  '+
                '      VALOR = :VALOR '+
                ' WHERE (ID = :ID) ');

        ParamByName('ID').AsInteger     := produto.id;
        ParamByName('NOME').AsString    := produto.nome;
        ParamByName('VALOR').AsCurrency := produto.valor;

        ExecSQL;

        fDMConexao.FDConnection.Commit;

        Result := True;

      end;

    except
      on e:Exception do
        raise Exception.Create('Erro ao atualizar produto: ' + e.Message);
    end;

  finally
    FreeAndnil(qry);
  end;

end;

function TModelProduto.cadastrar(produto: TProduto; out erro: String): Boolean;
var
  qry : TFDQuery;
begin

  try

    try

      qry := fDMConexao.criarQry;

      with qry do
      begin

        if produto.nome.IsEmpty then
        begin
          erro := 'O nome do produto não foi informado.';
          Result := false;
          exit;
        end;

        SQL.Clear;

        SQL.Add(' SELECT GEN_ID(GEN_PRODUTOS_ID, 1) '+
                ' FROM RDB$DATABASE;');

        Open;

        produto.id := FieldByName('GEN_ID').AsInteger;

        SQL.Clear;

        SQL.Add(' INSERT INTO PRODUTOS (ID, NOME, VALOR) '+
                ' VALUES (:ID, :NOME, :VALOR) ');

        ParamByName('ID').AsInteger     := produto.id;
        ParamByName('NOME').AsString    := produto.nome;
        ParamByName('VALOR').AsCurrency := produto.valor;

        ExecSQL;

        fDMConexao.FDConnection.Commit;

        Result := True;

      end;

    except
      on e:Exception do
        raise Exception.Create('Erro ao cadastrar produto: ' + e.Message);
    end;

  finally
    FreeAndnil(qry);
  end;

end;

function TModelProduto.deletar(produto: TProduto; out erro: String): Boolean;
var
  qry : TFDQuery;
begin

  try

    try

      qry := fDMConexao.criarQry;

      if not consultarProduto(produto.id) then
      begin
        Result := false;
        erro := 'Produto não cadastrado na base de dados';
        exit;
      end;

      with qry do
      begin

        SQL.Clear;

        SQL.Add(' DELETE FROM PRODUTOS '+
                ' WHERE (ID = :ID)');

        ParamByName('ID').AsInteger := produto.id;

        ExecSQL;

        fDMConexao.FDConnection.Commit;

        Result := true;

      end;

    except
      on e:Exception do
      begin
        Result := false;
        raise Exception.Create('Erro ao deletar produto');
      end;
    end;

  finally
    FreeAndNil(qry);
  end;
end;

function TModelProduto.listar(id: Integer): TFDQuery;
begin

   try

    Result := fDMConexao.criarQry;

    with Result do
    begin

      SQL.Clear;

      SQL.Add(' SELECT *      '+
              ' FROM PRODUTOS ');

      if id > 0 then
      begin
        SQL.Add(' WHERE ID = :ID ');
        ParamByName('ID').AsInteger := id;
      end;

      Open;

    end;

  except
    on e:Exception do
    begin
      Result := nil;
      raise Exception.Create('Erro ao consultar lista de clientes');
    end;

  end;

end;

end.
