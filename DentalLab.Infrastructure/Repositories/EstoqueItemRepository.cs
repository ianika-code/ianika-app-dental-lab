namespace DentalLab.Infrastructure.Repositories;

using DentalLab.Domain.Entities;
using DentalLab.Domain.Interfaces;
using DentalLab.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

/// <summary>
/// Implementação do repositório para EstoqueItem
/// </summary>
public class EstoqueItemRepository : Repository<EstoqueItem>, IEstoqueItemRepository
{
    public EstoqueItemRepository(DentalLabContext context) : base(context)
    {
    }

    public async Task<IEnumerable<EstoqueItem>> GetItensBaixosAsync()
    {
        return await _dbSet
            .Where(e => e.QuantidadeAtual <= e.QuantidadeMinima)
            .ToListAsync();
    }

    public async Task<IEnumerable<EstoqueItem>> GetPorCategoriaAsync(string categoria)
    {
        return await _dbSet
            .Where(e => e.Categoria.ToString() == categoria)
            .ToListAsync();
    }

    public async Task<EstoqueItem?> GetByNomeAsync(string nome)
    {
        return await _dbSet.FirstOrDefaultAsync(e => e.Nome == nome);
    }
}
