namespace DentalLab.Domain.Interfaces;

using DentalLab.Domain.Entities;

/// <summary>
/// Interface de repositório para Usuario
/// </summary>
public interface IUsuarioRepository : IRepository<Usuario>
{
    Task<Usuario?> GetByEmailAsync(string email);
    Task<bool> EmailExistsAsync(string email, Guid? excludeId = null);
}
