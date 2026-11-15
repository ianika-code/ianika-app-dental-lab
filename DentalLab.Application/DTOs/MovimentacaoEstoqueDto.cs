namespace DentalLab.Application.DTOs;

using DentalLab.Domain.Enums;

/// <summary>
/// DTO para MovimentacaoEstoque
/// </summary>
public class MovimentacaoEstoqueDto
{
    public Guid Id { get; set; }
    public Guid EstoqueItemId { get; set; }
    public string EstoqueItemNome { get; set; } = string.Empty;
    public TipoMovimentacao Tipo { get; set; }
    public int Quantidade { get; set; }
    public DateTime DataMovimentacao { get; set; }
    public string Motivo { get; set; } = string.Empty;
    public string? Observacoes { get; set; }
}
