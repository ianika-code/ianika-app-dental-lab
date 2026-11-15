namespace DentalLab.Application.DTOs;

using DentalLab.Domain.Enums;

/// <summary>
/// DTO para Pedido
/// </summary>
public class PedidoDto
{
    public Guid Id { get; set; }
    public string NumeroPedido { get; set; } = string.Empty;
    public Guid PacienteId { get; set; }
    public string? PacienteNome { get; set; }
    public Guid DentistaId { get; set; }
    public string? DentistaNome { get; set; }
    public string TipoProtese { get; set; } = string.Empty;
    public DateTime DataPedido { get; set; }
    public DateTime DataPrevista { get; set; }
    public DateTime? DataEntrega { get; set; }
    public decimal Valor { get; set; }
    public StatusPedido Status { get; set; }
    public string? Observacoes { get; set; }
}

/// <summary>
/// DTO para criar ou atualizar Pedido
/// </summary>
public class CreateUpdatePedidoDto
{
    public string NumeroPedido { get; set; } = string.Empty;
    public Guid PacienteId { get; set; }
    public Guid DentistaId { get; set; }
    public string TipoProtese { get; set; } = string.Empty;
    public DateTime DataPrevista { get; set; }
    public decimal Valor { get; set; }
    public string? Observacoes { get; set; }
}
