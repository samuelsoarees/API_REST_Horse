unit uController.Cliente;

interface

uses
   System.JSON;

  procedure Registry;

implementation

uses
  Horse,DataSet.Serialize, FireDAC.Comp.Client, uModel.Cliente, System.SysUtils,
  uCliente;

procedure ListarClientes(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  qry : TFDQuery;
  arrayClientes : TJSONArray;
  modelCliente : TModelCliente;
begin

  try
     modelCliente := TModelCliente.Create;
  except
    on e:exception do
    begin
      res.Send('Erro ao configurar base de dados: ' + e.Message).Status(500);
      exit;
    end;
  end;

  try

    try

      qry := modelCliente.listarClientes(0);

      arrayClientes := qry.ToJSONArray();

      res.Send <TJSONArray>(arrayClientes);

    except
      on e:exception do
        res.Send(e.Message).Status(500);
    end;

  finally
    if Assigned(modelCliente) then
      FreeandNil(modelCliente);
    if Assigned(qry) then
      qry.Free;
  end;

end;

procedure ListarClienteEspecifico(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  qry : TFDQuery;
  arrayClientes : TJSONArray;
  modelCliente : TModelCliente;
  i : Integer;
begin

  try
     modelCliente := TModelCliente.Create;
  except
    on e:exception do
    begin
      res.Send('Erro ao configurar base de dados: ' + e.Message).Status(500);
      exit;
    end;
  end;

  if not TryStrToInt(Req.Params['id'],i) then
  begin
    Res.Status(400);
    exit;
  end;

  try

    try

      qry := modelCliente.listarClientes(Req.Params['id'].ToInteger);

      if qry.RecordCount <= 0 then
      begin
        Res.Status(404);
        exit;
      end;

      arrayClientes := qry.ToJSONArray();

      res.Send <TJSONArray>(arrayClientes);

    except
      on e:exception do
        res.Send(e.Message).Status(500);
    end;

  finally
    if Assigned(modelCliente) then
      FreeAndNil(modelCliente);
    if Assigned(qry) then
      FreeAndNil(qry);
  end;

end;

procedure CadastrarCliente(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  cliente : TCliente;
  jsonReq : TJSONValue;
  modelCliente : TModelCliente;
  erro : String;
  objCliente : TJSONObject;

begin

  try
     modelCliente := TModelCliente.Create;
  except
    on e:exception do
    begin
      res.Send('Erro ao configurar base de dados: ' + e.Message).Status(500);
      exit;
    end;
  end;

  try

    try

      jsonReq := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(req.Body), 0) as TJsonValue;

      cliente := TCliente.Create;

      cliente.nome         := jsonReq.GetValue<string>('nome', '');
      cliente.dtNascimento := StrToDate(jsonReq.GetValue<string>('dtNascimento', ''));
      cliente.documento    := jsonReq.GetValue<string>('documento', '');

      modelCliente.cadastrarCliente(cliente,erro);

      if erro <> '' then
        raise Exception.Create(erro);

      objCliente := TJSONObject.Create;
      objCliente.AddPair('id', cliente.id.ToString);

      res.Send<TJSONObject>(objCliente).Status(201);

    except
      on e:Exception do
        res.Send(e.Message).Status(400);
    end;

  finally
    modelCliente.Free;
    cliente.Free;
    jsonReq.Free;
  end;

end;

procedure AlterarCliente(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  cliente : TCliente;
  jsonReq : TJSONValue;
  modelCliente : TModelCliente;
  erro : String;
  objCliente : TJSONObject;
begin

  try
     modelCliente := TModelCliente.Create;
  except
    on e:exception do
    begin
      res.Send('Erro ao configurar base de dados: ' + e.Message).Status(500);
      exit;
    end;
  end;

  try

    try

      jsonReq := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(req.Body), 0) as TJsonValue;

      cliente := TCliente.Create;

      cliente.id           := jsonReq.GetValue<Integer>('id', 0);
      cliente.nome         := jsonReq.GetValue<string>('nome', '');
      cliente.dtNascimento := StrToDate(jsonReq.GetValue<string>('dtNascimento', ''));
      cliente.documento    := jsonReq.GetValue<string>('documento', '');

      modelCliente.atualizarCliente(cliente,erro);

      if erro <> '' then
        raise Exception.Create(erro);

    except
      on e:Exception do
        res.Send(e.Message).Status(400);
    end;

  finally
    modelCliente.Free;
    cliente.Free;
    jsonReq.Free;
  end;

end;

procedure DeletarCliente(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  modelCliente : TModelCLiente;
  cliente : TCliente;
  erro : String;
begin

  try
     modelCliente := TModelCliente.Create;
  except
    on e:exception do
    begin
      res.Send('Erro ao configurar base de dados: ' + e.Message).Status(500);
      exit;
    end;
  end;

  try

    try

      cliente := TCliente.Create;

      cliente.id := Req.Params['id'].ToInteger;

      if not modelCliente.deletarCliente(cliente,erro) then
        raise Exception.Create(erro);

    except
      on e:exception do
      begin
        res.Send(e.Message).Status(400);
        exit;
      end;

    end;

  finally
    cliente.Free;
  end;

end;

procedure Registry;
begin
  THorse.Get('/cliente', ListarClientes);
  THorse.Get('/cliente/:id', ListarClienteEspecifico);
  THorse.Post('/cliente', CadastrarCliente);
  THorse.Put('/cliente', AlterarCliente);
  THorse.Delete('/cliente/:id', DeletarCliente);
end;

end.
