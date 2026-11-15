namespace DentalLab.Application.DTOs;

using DentalLab.Domain.Enums;

/// <summary>
/// DTO para EventoAgenda
/// </summary>
public class EventoAgendaDto
{
    public Guid Id { get; set; }
    public TipoEventoAgenda Tipo { get; set; }
    public string Titulo { get; set; } = string.Empty;
    public string? Descricao { get; set; }
    public DateTime DataHora { get; set; }
    public Guid? PedidoId { get; set; }
    public string? PedidoNumero { get; set; }
    public Guid? DentistaId { get; set; }
    public string? DentistaNome { get; set; }
    public bool Concluido { get; set; }
}

/// <summary>
/// DTO para criar ou atualizar EventoAgenda
/// </summary>
public class CreateUpdateEventoAgendaDto
{
    public TipoEventoAgenda Tipo { get; set; }
    public string Titulo { get; set; } = string.Empty;
    public string? Descricao { get; set; }
    public DateTime DataHora { get; set; }
    public Guid? PedidoId { get; set; }
    public Guid? DentistaId { get; set; }
}
