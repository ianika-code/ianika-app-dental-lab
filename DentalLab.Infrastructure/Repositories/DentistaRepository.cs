namespace DentalLab.Infrastructure.Repositories;

using DentalLab.Domain.Entities;
using DentalLab.Domain.Interfaces;
using DentalLab.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

/// <summary>
/// Implementação do repositório para Dentista
/// </summary>
public class DentistaRepository : Repository<Dentista>, IDentistaRepository
{
    public DentistaRepository(DentalLabContext context) : base(context)
    {
    }

    public async Task<Dentista?> GetByCROAsync(string cro)
    {
        return await _dbSet.FirstOrDefaultAsync(d => d.CRO == cro);
    }

    public async Task<IEnumerable<Dentista>> GetAtivosAsync()
    {
        return await _dbSet.ToListAsync();
    }

    public async Task<bool> CROExistsAsync(string cro, Guid? excludeId = null)
    {
        if (excludeId.HasValue)
        {
            return await _dbSet.AnyAsync(d => d.CRO == cro && d.Id != excludeId.Value);
        }

        return await _dbSet.AnyAsync(d => d.CRO == cro);
    }
}
