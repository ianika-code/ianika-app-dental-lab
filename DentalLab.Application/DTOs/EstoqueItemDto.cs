namespace DentalLab.Application.DTOs;

using DentalLab.Domain.Enums;

/// <summary>
/// DTO para EstoqueItem
/// </summary>
public class EstoqueItemDto
{
    public Guid Id { get; set; }
    public string Nome { get; set; } = string.Empty;
    public CategoriaEstoque Categoria { get; set; }
    public string? Descricao { get; set; }
    public int QuantidadeAtual { get; set; }
    public int QuantidadeMinima { get; set; }
    public string UnidadeMedida { get; set; } = string.Empty;
    public decimal ValorUnitario { get; set; }
    public string? Fornecedor { get; set; }
    public bool EstoqueBaixo { get; set; }
}

/// <summary>
/// DTO para criar ou atualizar EstoqueItem
/// </summary>
public class CreateUpdateEstoqueItemDto
{
    public string Nome { get; set; } = string.Empty;
    public CategoriaEstoque Categoria { get; set; }
    public string? Descricao { get; set; }
    public int QuantidadeMinima { get; set; }
    public string UnidadeMedida { get; set; } = string.Empty;
    public decimal ValorUnitario { get; set; }
    public string? Fornecedor { get; set; }
}
