namespace DentalLab.Infrastructure.Repositories;

using DentalLab.Domain.Entities;
using DentalLab.Domain.Interfaces;
using DentalLab.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

/// <summary>
/// Implementação do repositório para MovimentacaoEstoque
/// </summary>
public class MovimentacaoEstoqueRepository : Repository<MovimentacaoEstoque>, IMovimentacaoEstoqueRepository
{
    public MovimentacaoEstoqueRepository(DentalLabContext context) : base(context)
    {
    }

    public async Task<IEnumerable<MovimentacaoEstoque>> GetByEstoqueItemAsync(Guid estoqueItemId)
    {
        return await _dbSet
            .Where(m => m.EstoqueItemId == estoqueItemId)
            .Include(m => m.EstoqueItem)
            .OrderByDescending(m => m.DataMovimentacao)
            .ToListAsync();
    }

    public async Task<IEnumerable<MovimentacaoEstoque>> GetPorPeriodoAsync(DateTime dataInicio, DateTime dataFim)
    {
        return await _dbSet
            .Where(m => m.DataMovimentacao >= dataInicio && m.DataMovimentacao <= dataFim)
            .Include(m => m.EstoqueItem)
            .OrderByDescending(m => m.DataMovimentacao)
            .ToListAsync();
    }
}
