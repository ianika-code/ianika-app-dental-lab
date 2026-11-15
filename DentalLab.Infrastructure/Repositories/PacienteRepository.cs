namespace DentalLab.Infrastructure.Repositories;

using DentalLab.Domain.Entities;
using DentalLab.Domain.Interfaces;
using DentalLab.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

/// <summary>
/// Implementação do repositório para Paciente
/// </summary>
public class PacienteRepository : Repository<Paciente>, IPacienteRepository
{
    public PacienteRepository(DentalLabContext context) : base(context)
    {
    }

    public async Task<Paciente?> GetByCPFAsync(string cpf)
    {
        return await _dbSet
            .Include(p => p.DentistaResponsavel)
            .FirstOrDefaultAsync(p => p.CPF == cpf);
    }

    public async Task<IEnumerable<Paciente>> GetByDentistaAsync(Guid dentistaId)
    {
        return await _dbSet
            .Where(p => p.DentistaResponsavelId == dentistaId)
            .Include(p => p.DentistaResponsavel)
            .ToListAsync();
    }

    public async Task<bool> CPFExistsAsync(string cpf, Guid? excludeId = null)
    {
        if (excludeId.HasValue)
        {
            return await _dbSet.AnyAsync(p => p.CPF == cpf && p.Id != excludeId.Value);
        }

        return await _dbSet.AnyAsync(p => p.CPF == cpf);
    }
}
