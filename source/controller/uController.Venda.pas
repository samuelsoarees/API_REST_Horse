unit uController.Venda;

interface

procedure Registry;

implementation

uses
  Horse, uVenda,System.JSON, uModel.Venda, System.SysUtils, uCliente,
  System.Generics.Collections;

procedure Cadastrar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  venda : TVenda;
  jsonReq : TJSONValue;
  modelVenda : TModelVenda;
  erro : String;
  objCliente : TJSONObject;
begin

  try
     modelVenda := TModelVenda.Create;
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

      venda := TVenda.Create;

      venda.cliente := TCliente.create;

      venda.cliente.id  := jsonReq.GetValue<Integer>('idCliente', 0);

      modelVenda.cadastrar(venda,erro);

      if erro <> '' then
        raise Exception.Create(erro);

      objCliente := TJSONObject.Create;
      objCliente.AddPair('idVenda', venda.id.ToString);

      res.Send<TJSONObject>(objCliente).Status(201);

    except
      on e:Exception do
        res.Send(e.Message).Status(400);
    end;

  finally
    modelVenda.Free;
    venda.Free;
    jsonReq.Free;
  end;

end;

procedure Deletar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  modelVenda : TModelVenda;
  venda : TVenda;
  erro : String;
begin

  try
     modelVenda := TModelVenda.Create;
  except
    on e:exception do
    begin
      res.Send('Erro ao configurar base de dados: ' + e.Message).Status(500);
      exit;
    end;
  end;

  try

    try

      venda := TVenda.Create;

      venda.id := Req.Params['id'].ToInteger;

      if not modelVenda.deletar(venda,erro) then
        raise Exception.Create(erro);

    except
      on e:exception do
      begin
        res.Send(e.Message).Status(400);
        exit;
      end;

    end;

  finally
    venda.Free;
    modelVenda.Free;
  end;

end;

procedure ListarEspecifico(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  arrayItemVenda : TJSONArray;
  modelVenda : TModelVenda;
  i : Integer;
  venda : TVenda;
  jsonObject : TJSONObject;
begin

  try
    modelVenda := TModelVenda.Create;
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

      venda := modelVenda.listarEspecifico(Req.Params['id'].ToInteger);

      if Assigned(venda) then
      begin

        jsonObject := venda.toJson();

        res.Send <TJSONObject>(jsonObject);

      end
      else
        Res.Status(404);

    except
      on e:exception do
        res.Send(e.Message).Status(500);
    end;

  finally
    venda.Free;
    modelVenda.Free;
  end;

end;

procedure Listar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  listaVendas : TList<TVenda>;
  modelVenda : TModelVenda;
  jsonArray : TJSONArray;
  i: Integer;
begin

   try
    modelVenda := TModelVenda.Create;
  except
    on e:exception do
    begin
      res.Send('Erro ao configurar base de dados: ' + e.Message).Status(500);
      exit;
    end;
  end;

  try

    try

      listaVendas := modelVenda.listar;

      if Assigned(listaVendas) then
      begin

        jsonArray := TJSONArray.Create;

        for i := 0 to pred(listaVendas.Count) do
          jsonArray.Add(listaVendas[i].toJson());

        res.Send <TJSONArray>(jsonArray);

      end
      else
        Res.Status(404);

    except
      on e:exception do
        res.Send(e.Message).Status(500);
    end;

  finally
    listaVendas.Free;
    modelVenda.Free;
  end;

end;

procedure Alterar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  venda : TVenda;
  jsonReq : TJSONValue;
  modelVenda : TModelVenda;
  objCliente : TJSONObject;
  erro : String;
begin

  try
     modelVenda := TModelVenda.Create;
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

      venda := TVenda.Create;

      venda.id        := jsonReq.GetValue<Integer>('id', 0);
      venda.dataVenda := StrToDate(jsonReq.GetValue<string>('dataVenda', '01/01/1899'));

      venda.cliente := TCliente.Create;
      venda.cliente.id := jsonReq.GetValue<Integer>('idCliente', 0);

      modelVenda.atualizar(venda,erro);

      if erro <> '' then
        raise Exception.Create(erro);

    except
      on e:Exception do
        res.Send(e.Message).Status(400);
    end;

  finally
    modelVenda.Free;
    venda.Free;
    jsonReq.Free;
  end;

end;

procedure Registry;
begin
  THorse.Post('/venda', Cadastrar);
  THorse.Get('/venda', Listar);
  THorse.Get('/venda/:id', ListarEspecifico);
  THorse.Put('/venda', Alterar);
  THorse.Delete('/venda/:id', Deletar);
end;

end.
