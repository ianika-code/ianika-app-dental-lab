namespace DentalLab.Domain.Entities;

using DentalLab.Domain.Enums;

/// <summary>
/// Entidade de Evento da Agenda
/// Registra entregas, retornos e lembretes
/// </summary>
public class EventoAgenda : EntityBase
{
    /// <summary>
    /// Tipo de evento
    /// </summary>
    public TipoEventoAgenda Tipo { get; set; }

    /// <summary>
    /// Título do evento
    /// </summary>
    public string Titulo { get; set; } = string.Empty;

    /// <summary>
    /// Descrição detalhada
    /// </summary>
    public string? Descricao { get; set; }

    /// <summary>
    /// Data e hora do evento
    /// </summary>
    public DateTime DataHora { get; set; }

    /// <summary>
    /// Chave estrangeira opcional para o pedido associado
    /// </summary>
    public Guid? PedidoId { get; set; }

    /// <summary>
    /// Relacionamento: Pedido associado
    /// </summary>
    public Pedido? Pedido { get; set; }

    /// <summary>
    /// Chave estrangeira opcional para o dentista
    /// </summary>
    public Guid? DentistaId { get; set; }

    /// <summary>
    /// Relacionamento: Dentista associado
    /// </summary>
    public Dentista? Dentista { get; set; }

    /// <summary>
    /// Indica se o evento foi concluído
    /// </summary>
    public bool Concluido { get; set; }

    public EventoAgenda() { }

    public EventoAgenda(TipoEventoAgenda tipo, string titulo, DateTime dataHora)
    {
        Tipo = tipo;
        Titulo = titulo;
        DataHora = dataHora;
        Concluido = false;
    }
}
