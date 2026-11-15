namespace DentalLab.Domain.Enums;

/// <summary>
/// Enum com os possíveis status de um pedido
/// </summary>
public enum StatusPedido
{
    /// <summary>
    /// Pedido recebido e aguardando processamento
    /// </summary>
    Recebido = 0,

    /// <summary>
    /// Pedido em produção
    /// </summary>
    EmProducao = 1,

    /// <summary>
    /// Pedido em ajuste/correção
    /// </summary>
    EmAjuste = 2,

    /// <summary>
    /// Pedido finalizado e pronto para entrega
    /// </summary>
    Finalizado = 3,

    /// <summary>
    /// Pedido entregue ao dentista
    /// </summary>
    Entregue = 4
}
