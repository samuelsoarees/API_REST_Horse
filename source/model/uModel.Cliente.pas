unit uModel.Cliente;

interface

uses
  FireDAC.Comp.Client, uDMConexao, uCliente;

type
  TModelCliente = class
  private
    fDMConexao : TDMConexao;
  public
    constructor Create;
    destructor Destroy; override;
    function listarClientes(id : Integer) : TFDQuery;
    function cadastrarCliente(cliente : TCliente;
      out erro : String) : Boolean;
    function atualizarCliente(cliente : TCliente;
      out erro : String) : Boolean;
    function deletarCliente(cliente : TCliente;
      out erro : String): Boolean;
  end;

implementation

uses
  System.SysUtils;

{ TModelCliente }

constructor TModelCliente.Create;
begin
  fDMConexao := TDMConexao.Create(nil);
  fDMConexao.conectarBD;
end;


destructor TModelCliente.Destroy;
begin
  if Assigned(fDMConexao) then
    FreeAndNil(fDMConexao);
  inherited;
end;

function TModelCliente.listarClientes(id: Integer): TFDQuery;
begin

  try

    Result := fDMConexao.criarQry;

    with Result do
    begin

      SQL.Clear;

      SQL.Add(' SELECT *      '+
              ' FROM CLIENTES ');

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

function TModelCliente.cadastrarCliente(cliente: TCliente;
  out erro : String) : Boolean;
var
  qry : TFDQuery;
begin

  try

    try

      qry := fDMConexao.criarQry;

      with qry do
      begin

        if cliente.nome.IsEmpty then
        begin
          erro := 'O nome do cliente não foi informado.';
          Result := false;
          exit;
        end;

        SQL.Clear;

        SQL.Add(' SELECT GEN_ID(GEN_CLIENTES_ID, 1) '+
                ' FROM RDB$DATABASE;');

        Open;

        cliente.id := FieldByName('GEN_ID').AsInteger;

        SQL.Clear;

        SQL.Add(' INSERT INTO CLIENTES ( ID, NOME, DT_NASCIMENTO, DOCUMENTO) '+
                ' VALUES ( :ID, :NOME, :DT_NASCIMENTO, :DOCUMENTO) ');

        ParamByName('ID').AsInteger         := cliente.id;
        ParamByName('NOME').AsString        := cliente.nome;
        ParamByName('DT_NASCIMENTO').AsDate := cliente.dtNascimento;
        ParamByName('DOCUMENTO').AsString   := cliente.documento;

        ExecSQL;

        fDMConexao.FDConnection.Commit;

        Result := True;

      end;

    except
      on e:Exception do
        raise Exception.Create('Erro ao cadastrar cliente: ' + e.Message);
    end;

  finally
    FreeAndnil(qry);
  end;

end;


function TModelCliente.atualizarCliente(cliente: TCliente;
  out erro: String): Boolean;
var
  qry : TFDQuery;
begin

   try

    try

      qry := fDMConexao.criarQry;

      with qry do
      begin

        if cliente.id <= 0  then
        begin
          erro := 'Cliente inválido.';
          Result := false;
          exit;
        end;

        SQL.Clear;

        SQL.Add(' UPDATE CLIENTES                     '+
                ' SET NOME = :NOME,                   '+
                '     DT_NASCIMENTO = :DT_NASCIMENTO, '+
                '     DOCUMENTO = :DOCUMENTO          '+
                ' WHERE (ID = :ID) ');

        ParamByName('ID').AsInteger         := cliente.id;
        ParamByName('NOME').AsString        := cliente.nome;
        ParamByName('DT_NASCIMENTO').AsDate := cliente.dtNascimento;
        ParamByName('DOCUMENTO').AsString   := cliente.documento;

        ExecSQL;

        fDMConexao.FDConnection.Commit;

        Result := True;

      end;

    except
      on e:Exception do
        raise Exception.Create('Erro ao atualiza cliente: ' + e.Message);
    end;

  finally
    FreeAndnil(qry);
  end;

end;

function TModelCliente.deletarCliente(cliente: TCliente;
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

        SQL.Add(' DELETE FROM CLIENTES '+
                ' WHERE (ID = :ID)');

        ParamByName('ID').AsInteger := cliente.id;

        ExecSQL;

        fDMConexao.FDConnection.Commit;

        Result := true;

      end;

    except
      on e:Exception do
      begin
        Result := false;
        raise Exception.Create('Erro ao consultar lista de clientes');
      end;
    end;

  finally
    FreeAndNil(qry);
  end;

end;

end.
