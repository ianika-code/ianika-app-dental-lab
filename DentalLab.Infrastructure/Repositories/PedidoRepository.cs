namespace DentalLab.Infrastructure.Repositories;

using DentalLab.Domain.Entities;
using DentalLab.Domain.Enums;
using DentalLab.Domain.Interfaces;
using DentalLab.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

/// <summary>
/// Implementação do repositório para Pedido
/// </summary>
public class PedidoRepository : Repository<Pedido>, IPedidoRepository
{
    public PedidoRepository(DentalLabContext context) : base(context)
    {
    }

    public async Task<Pedido?> GetByNumeroPedidoAsync(string numeroPedido)
    {
        return await _dbSet
            .Include(p => p.Paciente)
            .Include(p => p.Dentista)
            .FirstOrDefaultAsync(p => p.NumeroPedido == numeroPedido);
    }

    public async Task<IEnumerable<Pedido>> GetByStatusAsync(StatusPedido status)
    {
        return await _dbSet
            .Where(p => p.Status == status)
            .Include(p => p.Paciente)
            .Include(p => p.Dentista)
            .ToListAsync();
    }

    public async Task<IEnumerable<Pedido>> GetByPacienteAsync(Guid pacienteId)
    {
        return await _dbSet
            .Where(p => p.PacienteId == pacienteId)
            .Include(p => p.Paciente)
            .Include(p => p.Dentista)
            .ToListAsync();
    }

    public async Task<IEnumerable<Pedido>> GetByDentistaAsync(Guid dentistaId)
    {
        return await _dbSet
            .Where(p => p.DentistaId == dentistaId)
            .Include(p => p.Paciente)
            .Include(p => p.Dentista)
            .ToListAsync();
    }

    public async Task<IEnumerable<Pedido>> GetPorPeriodoAsync(DateTime dataInicio, DateTime dataFim)
    {
        return await _dbSet
            .Where(p => p.DataPedido >= dataInicio && p.DataPedido <= dataFim)
            .Include(p => p.Paciente)
            .Include(p => p.Dentista)
            .ToListAsync();
    }

    public async Task<bool> NumeroPedidoExistsAsync(string numeroPedido, Guid? excludeId = null)
    {
        if (excludeId.HasValue)
        {
            return await _dbSet.AnyAsync(p => p.NumeroPedido == numeroPedido && p.Id != excludeId.Value);
        }

        return await _dbSet.AnyAsync(p => p.NumeroPedido == numeroPedido);
    }
}
