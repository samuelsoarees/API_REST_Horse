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
  uController.Produto in 'source\controller\uController.Produto.pas';

begin

  THorse.Use(Jhonson());

//  THorse.Use(HorseBasicAuthentication(
//  function(const AUsername, APassword: string): Boolean
//  begin
//    Result := AUsername.Equals('samuel') and APassword.Equals('1234');
//  end));

  uController.Cliente.Registry;
  uController.Produto.Registry;

  THorse.Listen(9000);

end.
