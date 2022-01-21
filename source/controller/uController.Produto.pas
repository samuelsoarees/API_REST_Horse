unit uController.Produto;

interface

  procedure Registry;

implementation

uses
  Horse, uProduto, uModel.Produto, System.SysUtils, System.JSON,
  FireDAC.Comp.Client, DataSet.Serialize;

procedure Cadastrar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  produto : TProduto;
  jsonReq : TJSONValue;
  modelProduto : TModelProduto;
  erro : String;
  objCliente : TJSONObject;

begin

  try
     modelProduto := TModelProduto.Create;
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

      produto := TProduto.Create;

      produto.nome  := jsonReq.GetValue<string>('nome', '');
      produto.valor := jsonReq.GetValue<Currency>('valor', 0);

      modelProduto.cadastrar(produto,erro);

      if erro <> '' then
        raise Exception.Create(erro);

      objCliente := TJSONObject.Create;
      objCliente.AddPair('id', produto.id.ToString);

      res.Send<TJSONObject>(objCliente).Status(201);

    except
      on e:Exception do
        res.Send(e.Message).Status(400);
    end;

  finally
    modelProduto.Free;
    produto.Free;
    jsonReq.Free;
  end;

end;

procedure Alterar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  produto : TProduto;
  jsonReq : TJSONValue;
  modelProduto : TModelProduto;
  erro : String;
  objCliente : TJSONObject;
begin

  try
     modelProduto := TModelProduto.Create;
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

      produto := TProduto.Create;

      produto.id    := jsonReq.GetValue<Integer>('id', 0);
      produto.nome  := jsonReq.GetValue<string>('nome', '');
      produto.valor := jsonReq.GetValue<Currency>('valor', 0);

      modelProduto.atualizar(produto,erro);

      if erro <> '' then
        raise Exception.Create(erro);

    except
      on e:Exception do
        res.Send(e.Message).Status(400);
    end;

  finally
    modelProduto.Free;
    produto.Free;
    jsonReq.Free;
  end;

end;

procedure Deletar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  modelProduto : TModelProduto;
  produto : TProduto;
  erro : String;
begin

  try
     modelProduto := TModelProduto.Create;
  except
    on e:exception do
    begin
      res.Send('Erro ao configurar base de dados: ' + e.Message).Status(500);
      exit;
    end;
  end;

  try

    try

      produto := TProduto.Create;

      produto.id := Req.Params['id'].ToInteger;

      if not modelProduto.deletar(produto,erro) then
        raise Exception.Create(erro);

    except
      on e:exception do
      begin
        res.Send(e.Message).Status(400);
        exit;
      end;

    end;

  finally
    produto.Free;
  end;

end;

procedure Listar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  qry : TFDQuery;
  arrayProdutos : TJSONArray;
  modelProduto : TModelProduto;
begin

  try
     modelProduto := TModelProduto.Create;
  except
    on e:exception do
    begin
      res.Send('Erro ao configurar base de dados: ' + e.Message).Status(500);
      exit;
    end;
  end;

  try

    try

      qry := modelProduto.listar(0);

      arrayProdutos := qry.ToJSONArray();

      res.Send <TJSONArray>(arrayProdutos);

    except
      on e:exception do
        res.Send(e.Message).Status(500);
    end;

  finally
    if Assigned(modelProduto) then
      FreeandNil(modelProduto);
    if Assigned(qry) then
      qry.Free;
  end;

end;

procedure ListarEspecifico(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  qry : TFDQuery;
  arrayProduto : TJSONArray;
  modelProduto : TModelProduto;
  i : Integer;
begin

  try
     modelProduto := TModelProduto.Create;
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

      qry := modelProduto.listar(Req.Params['id'].ToInteger);

      if qry.RecordCount <= 0 then
      begin
        Res.Status(404);
        exit;
      end;

      arrayProduto := qry.ToJSONArray();

      res.Send <TJSONArray>(arrayProduto);

    except
      on e:exception do
        res.Send(e.Message).Status(500);
    end;

  finally
    if Assigned(modelProduto) then
      FreeAndNil(modelProduto);
    if Assigned(qry) then
      FreeAndNil(qry);
  end;

end;

procedure Registry;
begin
  THorse.Get('/produto', Listar);
  THorse.Get('/produto/:id', ListarEspecifico);
  THorse.Post('/produto', Cadastrar);
  THorse.Put('/produto', Alterar);
  THorse.Delete('/produto/:id', Deletar);
end;

end.
