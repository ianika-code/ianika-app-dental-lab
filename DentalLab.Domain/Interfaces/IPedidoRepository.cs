namespace DentalLab.Domain.Interfaces;

using DentalLab.Domain.Entities;
using DentalLab.Domain.Enums;

/// <summary>
/// Interface de repositório para Pedido
/// </summary>
public interface IPedidoRepository : IRepository<Pedido>
{
    Task<Pedido?> GetByNumeroPedidoAsync(string numeroPedido);
    Task<IEnumerable<Pedido>> GetByStatusAsync(StatusPedido status);
    Task<IEnumerable<Pedido>> GetByPacienteAsync(Guid pacienteId);
    Task<IEnumerable<Pedido>> GetByDentistaAsync(Guid dentistaId);
    Task<IEnumerable<Pedido>> GetPorPeriodoAsync(DateTime dataInicio, DateTime dataFim);
    Task<bool> NumeroPedidoExistsAsync(string numeroPedido, Guid? excludeId = null);
}
