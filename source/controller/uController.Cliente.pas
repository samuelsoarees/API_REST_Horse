unit uController.Cliente;

interface
  procedure Registry;

implementation

uses
  Horse;

procedure ListarClientes(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin



end;

procedure Registry;
begin
  THorse.Get('/cliente', ListarClientes);
end;

end.
