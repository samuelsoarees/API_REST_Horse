unit uCliente;

interface

type
  TCliente = class
  private
    Fdocumento: String;
    FdtNascimento: TDate;
    Fnome: String;
    procedure Setdocumento(const Value: String);
    procedure SetdtNascimento(const Value: TDate);
    procedure Setnome(const Value: String);
  public
    property nome : String read Fnome write Setnome;
    property dtNascimento : TDate read FdtNascimento write SetdtNascimento;
    property documento : String read Fdocumento write Setdocumento;

  end;

implementation

{ TCliente }

procedure TCliente.Setdocumento(const Value: String);
begin
  Fdocumento := Value;
end;

procedure TCliente.SetdtNascimento(const Value: TDate);
begin
  FdtNascimento := Value;
end;

procedure TCliente.Setnome(const Value: String);
begin
  Fnome := Value;
end;

end.
