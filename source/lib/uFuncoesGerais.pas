unit uFuncoesGerais;

interface

uses
  System.IniFiles,System.SysUtils;

  function LerIni(Chave1, Chave2: String; ValorPadrao: String = ''): String;

implementation

function LerIni(Chave1, Chave2: String; ValorPadrao: String = ''): String;
var
  Arquivo: String;
  FileIni: TIniFile;
  caminho: String;
begin

  caminho := ParamStr(0);
  caminho := ExtractFilePath(caminho);

  Arquivo := caminho + 'configBD.ini';
  result := ValorPadrao;

  try
    FileIni := TIniFile.Create(Arquivo);
    if FileExists(Arquivo) then
      result := FileIni.ReadString(Chave1, Chave2, ValorPadrao);
  finally
    FreeAndNil(FileIni)
  end;

end;

end.
