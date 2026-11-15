namespace DentalLab.Domain.Interfaces;

using DentalLab.Domain.Entities;

/// <summary>
/// Interface de repositório para EventoAgenda
/// </summary>
public interface IEventoAgendaRepository : IRepository<EventoAgenda>
{
    Task<IEnumerable<EventoAgenda>> GetProximosEventosAsync(int dias = 7);
    Task<IEnumerable<EventoAgenda>> GetEventosDoDiaAsync(DateTime data);
    Task<IEnumerable<EventoAgenda>> GetNaoConcluidosAsync();
}
