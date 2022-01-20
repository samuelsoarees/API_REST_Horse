unit uDMConexao;

interface

uses
  System.SysUtils,
  System.Classes,

  FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.Phys.FB,
  FireDAC.Phys.FBDef,
  FireDAC.Phys.IBBase,
  FireDAC.Comp.Client,
  FireDAC.Comp.UI,
  FireDac.DApt,

  Data.DB,

  uFuncoesGerais;

type
  TDMConexao = class(TDataModule)
    FDGUIxWaitCursor: TFDGUIxWaitCursor;
    Transaction: TFDTransaction;
    FDConnection: TFDConnection;
    DriverLink: TFDPhysFBDriverLink;
  private
    { private declarations }
  public
    function criarQry: TFDQuery;
    procedure conectarBD();
  end;

var
  DMConexao: TDMConexao;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

function TDMConexao.criarQry: TFDQuery;
var
  qry : TFDQuery;
begin

  try

    qry := TFDQuery.Create(nil);

    qry.Connection := FDConnection;

    Result := qry;

  except
    on e:exception do
      raise Exception.Create(e.Message);
  end;

end;

procedure TDMConexao.conectarBD();
var
  caminho : String;
begin

  try

    caminho := ParamStr(0);
    caminho := ExtractFilePath(caminho);

    DriverLink.VendorLib := caminho + 'fbclient.dll';

    with FDConnection do
    begin

      Connected := false;
      Params.Clear;
      Params.Values['DriverID']  := 'FB';
      Params.Values['Server']    := LerIni('FirebirdConnection','Server');
      Params.Values['Database']  := LerIni('FirebirdConnection','Database','');
      Params.Values['User_name'] := LerIni('FirebirdConnection','User_Name');
      Params.Values['Password']  := LerIni('FirebirdConnection','Password');
      Params.Values['Port']      := LerIni('FirebirdConnection', 'Port');
      Connected := True;

    end;

  except
    on e:exception do
      raise Exception.Create('Ocorreu uma Falha na configuração no Banco Firebird!' + e.Message);
  end;


end;


end.
