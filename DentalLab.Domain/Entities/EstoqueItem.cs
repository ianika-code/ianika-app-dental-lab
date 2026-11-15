namespace DentalLab.Domain.Entities;

using DentalLab.Domain.Enums;

/// <summary>
/// Entidade de Item de Estoque
/// Controla os materiais do laboratório
/// </summary>
public class EstoqueItem : EntityBase
{
    /// <summary>
    /// Nome do material
    /// </summary>
    public string Nome { get; set; } = string.Empty;

    /// <summary>
    /// Categoria do material
    /// </summary>
    public CategoriaEstoque Categoria { get; set; }

    /// <summary>
    /// Descrição detalhada
    /// </summary>
    public string? Descricao { get; set; }

    /// <summary>
    /// Quantidade atual em estoque
    /// </summary>
    public int QuantidadeAtual { get; set; }

    /// <summary>
    /// Quantidade mínima para alerta
    /// </summary>
    public int QuantidadeMinima { get; set; }

    /// <summary>
    /// Unidade de medida (Ex: kg, unidade, litro)
    /// </summary>
    public string UnidadeMedida { get; set; } = string.Empty;

    /// <summary>
    /// Valor unitário do material
    /// </summary>
    public decimal ValorUnitario { get; set; }

    /// <summary>
    /// Fornecedor do material
    /// </summary>
    public string? Fornecedor { get; set; }

    /// <summary>
    /// Data de entrada mais recente
    /// </summary>
    public DateTime? DataUltimaEntrada { get; set; }

    /// <summary>
    /// Relacionamento: Movimentações de estoque
    /// </summary>
    public ICollection<MovimentacaoEstoque> Movimentacoes { get; set; } = new List<MovimentacaoEstoque>();

    public EstoqueItem() { }

    public EstoqueItem(string nome, CategoriaEstoque categoria, int quantidadeMinima, string unidadeMedida)
    {
        Nome = nome;
        Categoria = categoria;
        QuantidadeMinima = quantidadeMinima;
        UnidadeMedida = unidadeMedida;
    }

    /// <summary>
    /// Verifica se o item está com estoque baixo
    /// </summary>
    public bool EstoqueBaixo => QuantidadeAtual <= QuantidadeMinima;
}
