program ApiRest;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Horse,
  Horse.Jhonson,
  uModel.Cliente in 'source\model\uModel.Cliente.pas',
  uController.Cliente in 'source\controller\uController.Cliente.pas',
  uCliente in 'source\model\entidades\uCliente.pas',
  uDMConexao in 'source\model\dao\uDMConexao.pas' {DMConexao: TDataModule},
  uFuncoesGerais in 'source\lib\uFuncoesGerais.pas';

begin
  THorse.Use(Jhonson());

  uController.Cliente.Registry;

  THorse.Listen(9000);

end.
