namespace DentalLab.Domain.Interfaces;

using DentalLab.Domain.Entities;

/// <summary>
/// Interface de repositório para EstoqueItem
/// </summary>
public interface IEstoqueItemRepository : IRepository<EstoqueItem>
{
    Task<IEnumerable<EstoqueItem>> GetItensBaixosAsync();
    Task<IEnumerable<EstoqueItem>> GetPorCategoriaAsync(string categoria);
    Task<EstoqueItem?> GetByNomeAsync(string nome);
}
