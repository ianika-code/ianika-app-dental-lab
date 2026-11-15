namespace DentalLab.Application.DTOs;

/// <summary>
/// DTO para Dentista
/// </summary>
public class DentistaDto
{
    public Guid Id { get; set; }
    public string Nome { get; set; } = string.Empty;
    public string CRO { get; set; } = string.Empty;
    public string Telefone { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Endereco { get; set; } = string.Empty;
    public string? Observacoes { get; set; }
}

/// <summary>
/// DTO para criar ou atualizar Dentista
/// </summary>
public class CreateUpdateDentistaDto
{
    public string Nome { get; set; } = string.Empty;
    public string CRO { get; set; } = string.Empty;
    public string Telefone { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Endereco { get; set; } = string.Empty;
    public string? Observacoes { get; set; }
}
