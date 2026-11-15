namespace DentalLab.Domain.Entities;

/// <summary>
/// Entidade de Dentista
/// Representa um cirurgião-dentista que utiliza o laboratório
/// </summary>
public class Dentista : EntityBase
{
    /// <summary>
    /// Nome completo do dentista
    /// </summary>
    public string Nome { get; set; } = string.Empty;

    /// <summary>
    /// Número do Conselho Regional de Odontologia
    /// </summary>
    public string CRO { get; set; } = string.Empty;

    /// <summary>
    /// Telefone de contato
    /// </summary>
    public string Telefone { get; set; } = string.Empty;

    /// <summary>
    /// Email de contato
    /// </summary>
    public string Email { get; set; } = string.Empty;

    /// <summary>
    /// Endereço do consultório
    /// </summary>
    public string Endereco { get; set; } = string.Empty;

    /// <summary>
    /// Observações adicionais
    /// </summary>
    public string? Observacoes { get; set; }

    /// <summary>
    /// Relacionamento: Pacientes atendidos por este dentista
    /// </summary>
    public ICollection<Paciente> Pacientes { get; set; } = new List<Paciente>();

    /// <summary>
    /// Relacionamento: Pedidos deste dentista
    /// </summary>
    public ICollection<Pedido> Pedidos { get; set; } = new List<Pedido>();

    public Dentista() { }

    public Dentista(string nome, string cro, string telefone, string email, string endereco)
    {
        Nome = nome;
        CRO = cro;
        Telefone = telefone;
        Email = email;
        Endereco = endereco;
    }
}
