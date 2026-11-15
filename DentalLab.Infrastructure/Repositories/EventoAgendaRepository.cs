namespace DentalLab.Infrastructure.Repositories;

using DentalLab.Domain.Entities;
using DentalLab.Domain.Interfaces;
using DentalLab.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

/// <summary>
/// Implementação do repositório para EventoAgenda
/// </summary>
public class EventoAgendaRepository : Repository<EventoAgenda>, IEventoAgendaRepository
{
    public EventoAgendaRepository(DentalLabContext context) : base(context)
    {
    }

    public async Task<IEnumerable<EventoAgenda>> GetProximosEventosAsync(int dias = 7)
    {
        var dataAtual = DateTime.UtcNow;
        var dataFim = dataAtual.AddDays(dias);

        return await _dbSet
            .Where(e => e.DataHora >= dataAtual && e.DataHora <= dataFim && !e.Concluido)
            .Include(e => e.Pedido)
            .Include(e => e.Dentista)
            .OrderBy(e => e.DataHora)
            .ToListAsync();
    }

    public async Task<IEnumerable<EventoAgenda>> GetEventosDoDiaAsync(DateTime data)
    {
        var dataInicio = data.Date;
        var dataFim = dataInicio.AddDays(1);

        return await _dbSet
            .Where(e => e.DataHora >= dataInicio && e.DataHora < dataFim)
            .Include(e => e.Pedido)
            .Include(e => e.Dentista)
            .OrderBy(e => e.DataHora)
            .ToListAsync();
    }

    public async Task<IEnumerable<EventoAgenda>> GetNaoConcluidosAsync()
    {
        return await _dbSet
            .Where(e => !e.Concluido)
            .Include(e => e.Pedido)
            .Include(e => e.Dentista)
            .OrderBy(e => e.DataHora)
            .ToListAsync();
    }
}
