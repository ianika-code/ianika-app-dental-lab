namespace DentalLab.Domain.Interfaces;

using DentalLab.Domain.Entities;

/// <summary>
/// Interface de repositório para Paciente
/// </summary>
public interface IPacienteRepository : IRepository<Paciente>
{
    Task<Paciente?> GetByCPFAsync(string cpf);
    Task<IEnumerable<Paciente>> GetByDentistaAsync(Guid dentistaId);
    Task<bool> CPFExistsAsync(string cpf, Guid? excludeId = null);
}
