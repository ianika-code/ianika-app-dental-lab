namespace DentalLab.Domain.Entities;

/// <summary>
/// Entidade de Paciente
/// Representa um paciente atendido através de um dentista
/// </summary>
public class Paciente : EntityBase
{
    /// <summary>
    /// Nome completo do paciente
    /// </summary>
    public string Nome { get; set; } = string.Empty;

    /// <summary>
    /// CPF (Cadastro de Pessoa Física)
    /// </summary>
    public string CPF { get; set; } = string.Empty;

    /// <summary>
    /// Telefone de contato
    /// </summary>
    public string Telefone { get; set; } = string.Empty;

    /// <summary>
    /// Data de nascimento
    /// </summary>
    public DateTime DataNascimento { get; set; }

    /// <summary>
    /// Chave estrangeira para o dentista responsável
    /// </summary>
    public Guid DentistaResponsavelId { get; set; }

    /// <summary>
    /// Relacionamento: Dentista responsável
    /// </summary>
    public Dentista? DentistaResponsavel { get; set; }

    /// <summary>
    /// Observações adicionais sobre o paciente
    /// </summary>
    public string? Observacoes { get; set; }

    /// <summary>
    /// Relacionamento: Pedidos do paciente
    /// </summary>
    public ICollection<Pedido> Pedidos { get; set; } = new List<Pedido>();

    public Paciente() { }

    public Paciente(string nome, string cpf, string telefone, DateTime dataNascimento, Guid dentistaResponsavelId)
    {
        Nome = nome;
        CPF = cpf;
        Telefone = telefone;
        DataNascimento = dataNascimento;
        DentistaResponsavelId = dentistaResponsavelId;
    }
}
