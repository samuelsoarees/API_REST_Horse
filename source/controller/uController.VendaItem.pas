unit uController.VendaItem;

interface

procedure Registry;

implementation

uses
  Horse, uVendaItem, System.JSON, uModel.VendaItem, System.SysUtils, uProduto,
  System.Generics.Collections;

procedure Cadastrar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  vendaItem : TVendaItem;
  jsonReq : TJSONValue;
  modelVendaItem : TModelVendaItem;
  erro : String;
  objCliente : TJSONObject;
begin

  try
     modelVendaItem := TModelVendaItem.Create;
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

      vendaItem := TVendaItem.Create;
      vendaItem.produto := TProduto.create;

      vendaItem.idVenda     := jsonReq.GetValue<Integer>('idVenda', 0);
      vendaItem.produto.id  := jsonReq.GetValue<Integer>('idProduto', 0);
      vendaItem.quantidade  := jsonReq.GetValue<Currency>('quantidade', 0);

      modelVendaItem.cadastrar(vendaItem,erro);

      if erro <> '' then
        raise Exception.Create(erro);

      objCliente := TJSONObject.Create;
      objCliente.AddPair('idVendaItem', vendaItem.id.ToString);

      res.Send<TJSONObject>(objCliente).Status(201);

    except
      on e:Exception do
        res.Send(e.Message).Status(400);
    end;

  finally
    modelVendaItem.Free;
    vendaItem.Free;
    jsonReq.Free;
  end;

end;

procedure Deletar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  modelVendaItem : TModelVendaItem;
  vendaItem : TVendaItem;
  erro : String;
  i : Integer;
begin

  try
     modelVendaItem := TModelVendaItem.Create;
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

      vendaItem := TVendaItem.Create;
      vendaItem.id := Req.Params['id'].ToInteger;

      if not modelVendaItem.deletar(vendaItem,erro) then
        raise Exception.Create(erro);

    except
      on e:exception do
      begin
        res.Send(e.Message).Status(400);
        exit;
      end;

    end;

  finally
    vendaItem.Free;
    modelVendaItem.Free;
  end;

end;

procedure Alterar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  vendaItem : TVendaItem;
  jsonReq : TJSONValue;
  modelVendaItem : TModelVendaItem;
  objCliente : TJSONObject;
  erro : String;
begin

  try
     modelVendaItem := TModelVendaItem.Create;
  except
    on e:exception do
    begin
      res.Send('Erro ao configurar base de dados: ' + e.Message).Status(500);
      exit;
    end;
  end;

  try

    try

      vendaItem := TVendaItem.Create;

      jsonReq := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(req.Body), 0) as TJsonValue;

      vendaItem.id         := jsonReq.GetValue<Integer>('id', 0);
      vendaItem.quantidade := jsonReq.GetValue<Currency>('quantidade', 0);

      modelVendaItem.atualizar(vendaItem,erro);

      if erro <> '' then
        raise Exception.Create(erro);

    except
      on e:Exception do
        res.Send(e.Message).Status(400);
    end;

  finally
    modelVendaItem.Free;
    vendaItem.Free;
  end;

end;

procedure ListarEspecifico(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  modelVendaItem : TModelVendaItem;
  i : Integer;
  vendaItem : TVendaItem;
  jsonObject : TJSONObject;
begin

  try
    modelVendaItem := TModelVendaItem.Create;
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

      vendaItem := modelVendaItem.listarEspecifico(Req.Params['id'].ToInteger);

      if Assigned(vendaItem) then
      begin

        jsonObject := vendaItem.toJson();

        res.Send <TJSONObject>(jsonObject);

      end
      else
        Res.Status(404);

    except
      on e:exception do
        res.Send(e.Message).Status(500);
    end;

  finally
    vendaItem.Free;
    modelVendaItem.Free;
  end;

end;

procedure Listar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  listaVendasItens : TList<TVendaItem>;
  modelVendaItem : TModelVendaItem;
  jsonArray : TJSONArray;
  i: Integer;
  jsonReq : TJSONValue;
  idVenda : Integer;
begin

  listaVendasItens := nil;

  try
    modelVendaItem := TModelVendaItem.Create;
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

      idVenda := jsonReq.GetValue<Integer>('idVenda', 0);

      if idVenda <= 0 then
      begin
        Res.Status(400);
        exit;
      end;

      listaVendasItens := modelVendaItem.listar(idVenda);

      if Assigned(listaVendasItens) then
      begin

        jsonArray := TJSONArray.Create;

        for i := 0 to pred(listaVendasItens.Count) do
          jsonArray.Add(listaVendasItens[i].toJson());

        res.Send <TJSONArray>(jsonArray);

      end
      else
        Res.Status(404);

    except
      on e:exception do
        res.Send(e.Message).Status(500);
    end;

  finally
    if Assigned(listaVendasItens) then
      listaVendasItens.Free;

    modelVendaItem.Free;
  end;

end;

procedure Registry;
begin
  THorse.Post('/vendaItem', Cadastrar);
  THorse.Get('/vendaItem', Listar);
  THorse.Get('/vendaItem/:id', ListarEspecifico);
  THorse.Put('/vendaItem', Alterar);
  THorse.Delete('/vendaItem/:id', Deletar);
end;

end.
