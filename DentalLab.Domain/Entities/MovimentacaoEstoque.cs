namespace DentalLab.Domain.Entities;

using DentalLab.Domain.Enums;

/// <summary>
/// Entidade de Movimentação de Estoque
/// Registra entradas e saídas de materiais
/// </summary>
public class MovimentacaoEstoque : EntityBase
{
    /// <summary>
    /// Chave estrangeira para o item de estoque
    /// </summary>
    public Guid EstoqueItemId { get; set; }

    /// <summary>
    /// Relacionamento: Item de estoque
    /// </summary>
    public EstoqueItem? EstoqueItem { get; set; }

    /// <summary>
    /// Tipo de movimentação (entrada ou saída)
    /// </summary>
    public TipoMovimentacao Tipo { get; set; }

    /// <summary>
    /// Quantidade movimentada
    /// </summary>
    public int Quantidade { get; set; }

    /// <summary>
    /// Data da movimentação
    /// </summary>
    public DateTime DataMovimentacao { get; set; }

    /// <summary>
    /// Motivo da movimentação
    /// </summary>
    public string Motivo { get; set; } = string.Empty;

    /// <summary>
    /// Observações adicionais
    /// </summary>
    public string? Observacoes { get; set; }

    public MovimentacaoEstoque() { }

    public MovimentacaoEstoque(Guid estoqueItemId, TipoMovimentacao tipo, int quantidade, string motivo)
    {
        EstoqueItemId = estoqueItemId;
        Tipo = tipo;
        Quantidade = quantidade;
        Motivo = motivo;
        DataMovimentacao = DateTime.UtcNow;
    }
}
