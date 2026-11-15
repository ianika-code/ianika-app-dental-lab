namespace DentalLab.Infrastructure.Repositories;

using DentalLab.Domain.Entities;
using DentalLab.Domain.Interfaces;
using DentalLab.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

/// <summary>
/// Implementação do repositório para Usuario
/// </summary>
public class UsuarioRepository : Repository<Usuario>, IUsuarioRepository
{
    public UsuarioRepository(DentalLabContext context) : base(context)
    {
    }

    public async Task<Usuario?> GetByEmailAsync(string email)
    {
        return await _dbSet.FirstOrDefaultAsync(u => u.Email == email);
    }

    public async Task<bool> EmailExistsAsync(string email, Guid? excludeId = null)
    {
        if (excludeId.HasValue)
        {
            return await _dbSet.AnyAsync(u => u.Email == email && u.Id != excludeId.Value);
        }

        return await _dbSet.AnyAsync(u => u.Email == email);
    }
}
