namespace DentalLab.Application.DTOs;

/// <summary>
/// DTO para Paciente
/// </summary>
public class PacienteDto
{
    public Guid Id { get; set; }
    public string Nome { get; set; } = string.Empty;
    public string CPF { get; set; } = string.Empty;
    public string Telefone { get; set; } = string.Empty;
    public DateTime DataNascimento { get; set; }
    public Guid DentistaResponsavelId { get; set; }
    public string? DentistaResponsavelNome { get; set; }
    public string? Observacoes { get; set; }
}

/// <summary>
/// DTO para criar ou atualizar Paciente
/// </summary>
public class CreateUpdatePacienteDto
{
    public string Nome { get; set; } = string.Empty;
    public string CPF { get; set; } = string.Empty;
    public string Telefone { get; set; } = string.Empty;
    public DateTime DataNascimento { get; set; }
    public Guid DentistaResponsavelId { get; set; }
    public string? Observacoes { get; set; }
}
