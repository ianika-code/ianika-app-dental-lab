namespace DentalLab.Domain.Interfaces;

using DentalLab.Domain.Entities;

/// <summary>
/// Interface de repositório para Dentista
/// </summary>
public interface IDentistaRepository : IRepository<Dentista>
{
    Task<Dentista?> GetByCROAsync(string cro);
    Task<IEnumerable<Dentista>> GetAtivosAsync();
    Task<bool> CROExistsAsync(string cro, Guid? excludeId = null);
}
