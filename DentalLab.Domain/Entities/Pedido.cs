namespace DentalLab.Domain.Entities;

using DentalLab.Domain.Enums;

/// <summary>
/// Entidade de Pedido
/// Representa um pedido de prótese dentária
/// </summary>
public class Pedido : EntityBase
{
    /// <summary>
    /// Número único do pedido
    /// </summary>
    public string NumeroPedido { get; set; } = string.Empty;

    /// <summary>
    /// Chave estrangeira para o paciente
    /// </summary>
    public Guid PacienteId { get; set; }

    /// <summary>
    /// Relacionamento: Paciente
    /// </summary>
    public Paciente? Paciente { get; set; }

    /// <summary>
    /// Chave estrangeira para o dentista
    /// </summary>
    public Guid DentistaId { get; set; }

    /// <summary>
    /// Relacionamento: Dentista
    /// </summary>
    public Dentista? Dentista { get; set; }

    /// <summary>
    /// Tipo de prótese (ex: Coroa, Ponte, Prótese Total)
    /// </summary>
    public string TipoProtese { get; set; } = string.Empty;

    /// <summary>
    /// Data do pedido
    /// </summary>
    public DateTime DataPedido { get; set; }

    /// <summary>
    /// Data prevista de entrega
    /// </summary>
    public DateTime DataPrevista { get; set; }

    /// <summary>
    /// Data real de entrega (quando concluído)
    /// </summary>
    public DateTime? DataEntrega { get; set; }

    /// <summary>
    /// Valor do pedido
    /// </summary>
    public decimal Valor { get; set; }

    /// <summary>
    /// Status atual do pedido
    /// </summary>
    public StatusPedido Status { get; set; }

    /// <summary>
    /// Observações adicionais sobre o pedido
    /// </summary>
    public string? Observacoes { get; set; }

    public Pedido() { }

    public Pedido(string numeroPedido, Guid pacienteId, Guid dentistaId, string tipoProtese, DateTime dataPrevista, decimal valor)
    {
        NumeroPedido = numeroPedido;
        PacienteId = pacienteId;
        DentistaId = dentistaId;
        TipoProtese = tipoProtese;
        DataPedido = DateTime.UtcNow;
        DataPrevista = dataPrevista;
        Valor = valor;
        Status = StatusPedido.Recebido;
    }
}
