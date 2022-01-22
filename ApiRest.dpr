program ApiRest;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Horse,
  Horse.Jhonson,
  Horse.BasicAuthentication,
  uModel.Cliente in 'source\model\uModel.Cliente.pas',
  uController.Cliente in 'source\controller\uController.Cliente.pas',
  uCliente in 'source\model\entidades\uCliente.pas',
  uDMConexao in 'source\model\dao\uDMConexao.pas' {DMConexao: TDataModule},
  uFuncoesGerais in 'source\lib\uFuncoesGerais.pas',
  uProduto in 'source\model\entidades\uProduto.pas',
  uModel.Produto in 'source\model\uModel.Produto.pas',
  uController.Produto in 'source\controller\uController.Produto.pas',
  uVendaItem in 'source\model\entidades\uVendaItem.pas',
  uVenda in 'source\model\entidades\uVenda.pas',
  uController.Venda in 'source\controller\uController.Venda.pas',
  uModel.Venda in 'source\model\uModel.Venda.pas',
  uModel.VendaItem in 'source\model\uModel.VendaItem.pas',
  uController.VendaItem in 'source\controller\uController.VendaItem.pas';

begin

  THorse.Use(Jhonson());

  THorse.Use(HorseBasicAuthentication(
  function(const AUsername, APassword: string): Boolean
  begin
    Result := AUsername.Equals('testserver') and APassword.Equals('22012022');
  end));

  uController.Cliente.Registry;
  uController.Produto.Registry;
  uController.Venda.Registry;
  uController.VendaItem.Registry;

  THorse.Listen(9000);

end.
