unit uCliente;

interface

type
  TCliente = class
  private
    Fdocumento: String;
    FdtNascimento: TDate;
    Fnome: String;
    Fid: Integer;
    procedure Setdocumento(const Value: String);
    procedure SetdtNascimento(const Value: TDate);
    procedure Setnome(const Value: String);
    procedure Setid(const Value: Integer);
  public
    property id   : Integer read Fid write Setid;
    property nome : String read Fnome write Setnome;
    property dtNascimento : TDate read FdtNascimento write SetdtNascimento;
    property documento : String read Fdocumento write Setdocumento;
  end;

implementation

uses
  Rest.JSON;

{ TCliente }

procedure TCliente.Setdocumento(const Value: String);
begin
  Fdocumento := Value;
end;

procedure TCliente.SetdtNascimento(const Value: TDate);
begin
  FdtNascimento := Value;
end;

procedure TCliente.Setid(const Value: Integer);
begin
  Fid := Value;
end;

procedure TCliente.Setnome(const Value: String);
begin
  Fnome := Value;
end;

end.
