namespace DentalLab.Domain.Interfaces;

using DentalLab.Domain.Entities;

/// <summary>
/// Interface de repositório para Movimentação de Estoque
/// </summary>
public interface IMovimentacaoEstoqueRepository : IRepository<MovimentacaoEstoque>
{
    Task<IEnumerable<MovimentacaoEstoque>> GetByEstoqueItemAsync(Guid estoqueItemId);
    Task<IEnumerable<MovimentacaoEstoque>> GetPorPeriodoAsync(DateTime dataInicio, DateTime dataFim);
}
