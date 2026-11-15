namespace DentalLab.Application.Services;

using DentalLab.Application.DTOs;
using DentalLab.Domain.Entities;
using DentalLab.Domain.Enums;
using DentalLab.Domain.Interfaces;
using Microsoft.Extensions.Logging;

/// <summary>
/// Serviço para gerenciar Agenda
/// </summary>
public class EventoAgendaService
{
    private readonly IEventoAgendaRepository _eventoRepository;
    private readonly IPedidoRepository _pedidoRepository;
    private readonly IDentistaRepository _dentistaRepository;
    private readonly ILogger<EventoAgendaService> _logger;

    public EventoAgendaService(
        IEventoAgendaRepository eventoRepository,
        IPedidoRepository pedidoRepository,
        IDentistaRepository dentistaRepository,
        ILogger<EventoAgendaService> logger)
    {
        _eventoRepository = eventoRepository;
        _pedidoRepository = pedidoRepository;
        _dentistaRepository = dentistaRepository;
        _logger = logger;
    }

    /// <summary>
    /// Obtém todos os eventos
    /// </summary>
    public async Task<IEnumerable<EventoAgendaDto>> GetTodosAsync()
    {
        try
        {
            var eventos = await _eventoRepository.GetAllAsync();
            return await MapToEventoAgendaDtoListAsync(eventos);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao obter lista de eventos da agenda");
            throw;
        }
    }

    /// <summary>
    /// Obtém um evento por ID
    /// </summary>
    public async Task<EventoAgendaDto?> GetPorIdAsync(Guid id)
    {
        try
        {
            var evento = await _eventoRepository.GetByIdAsync(id);
            if (evento == null) return null;

            return await MapToEventoAgendaDtoAsync(evento);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao obter evento com ID: {id}");
            throw;
        }
    }

    /// <summary>
    /// Obtém próximos eventos (próximos 7 dias por padrão)
    /// </summary>
    public async Task<IEnumerable<EventoAgendaDto>> GetProximosEventosAsync(int dias = 7)
    {
        try
        {
            var eventos = await _eventoRepository.GetProximosEventosAsync(dias);
            return await MapToEventoAgendaDtoListAsync(eventos);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao obter próximos {dias} dias de eventos");
            throw;
        }
    }

    /// <summary>
    /// Obtém eventos do dia
    /// </summary>
    public async Task<IEnumerable<EventoAgendaDto>> GetEventosDoDiaAsync(DateTime data)
    {
        try
        {
            var eventos = await _eventoRepository.GetEventosDoDiaAsync(data);
            return await MapToEventoAgendaDtoListAsync(eventos);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao obter eventos do dia: {data:dd/MM/yyyy}");
            throw;
        }
    }

    /// <summary>
    /// Obtém eventos não concluídos
    /// </summary>
    public async Task<IEnumerable<EventoAgendaDto>> GetEventosNaoConcluidosAsync()
    {
        try
        {
            var eventos = await _eventoRepository.GetNaoConcluidosAsync();
            return await MapToEventoAgendaDtoListAsync(eventos);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao obter eventos não concluídos");
            throw;
        }
    }

    /// <summary>
    /// Cria um novo evento na agenda
    /// </summary>
    public async Task<EventoAgendaDto> CriarAsync(CreateUpdateEventoAgendaDto dto)
    {
        try
        {
            // Validações
            if (string.IsNullOrWhiteSpace(dto.Titulo))
            {
                throw new InvalidOperationException("Título do evento é obrigatório");
            }

            // Validar pedido se informado
            if (dto.PedidoId.HasValue && dto.PedidoId.Value != Guid.Empty)
            {
                var pedido = await _pedidoRepository.GetByIdAsync(dto.PedidoId.Value);
                if (pedido == null)
                {
                    throw new InvalidOperationException("Pedido não encontrado");
                }
            }

            // Validar dentista se informado
            if (dto.DentistaId.HasValue && dto.DentistaId.Value != Guid.Empty)
            {
                var dentista = await _dentistaRepository.GetByIdAsync(dto.DentistaId.Value);
                if (dentista == null)
                {
                    throw new InvalidOperationException("Dentista não encontrado");
                }
            }

            var evento = new EventoAgenda(dto.Tipo, dto.Titulo, dto.DataHora)
            {
                Descricao = dto.Descricao,
                PedidoId = dto.PedidoId != Guid.Empty ? dto.PedidoId : null,
                DentistaId = dto.DentistaId != Guid.Empty ? dto.DentistaId : null
            };

            await _eventoRepository.AddAsync(evento);
            await _eventoRepository.SaveAsync();

            _logger.LogInformation($"Evento criado com sucesso: {evento.Titulo} - {evento.DataHora:dd/MM/yyyy HH:mm}");

            return await MapToEventoAgendaDtoAsync(evento);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao criar evento: {dto.Titulo}");
            throw;
        }
    }

    /// <summary>
    /// Atualiza um evento existente
    /// </summary>
    public async Task<EventoAgendaDto> AtualizarAsync(Guid id, CreateUpdateEventoAgendaDto dto)
    {
        try
        {
            var evento = await _eventoRepository.GetByIdAsync(id);
            if (evento == null)
            {
                throw new InvalidOperationException("Evento não encontrado");
            }

            // Validações
            if (string.IsNullOrWhiteSpace(dto.Titulo))
            {
                throw new InvalidOperationException("Título do evento é obrigatório");
            }

            // Validar pedido se informado
            if (dto.PedidoId.HasValue && dto.PedidoId.Value != Guid.Empty)
            {
                var pedido = await _pedidoRepository.GetByIdAsync(dto.PedidoId.Value);
                if (pedido == null)
                {
                    throw new InvalidOperationException("Pedido não encontrado");
                }
            }

            // Validar dentista se informado
            if (dto.DentistaId.HasValue && dto.DentistaId.Value != Guid.Empty)
            {
                var dentista = await _dentistaRepository.GetByIdAsync(dto.DentistaId.Value);
                if (dentista == null)
                {
                    throw new InvalidOperationException("Dentista não encontrado");
                }
            }

            evento.Tipo = dto.Tipo;
            evento.Titulo = dto.Titulo;
            evento.Descricao = dto.Descricao;
            evento.DataHora = dto.DataHora;
            evento.PedidoId = dto.PedidoId != Guid.Empty ? dto.PedidoId : null;
            evento.DentistaId = dto.DentistaId != Guid.Empty ? dto.DentistaId : null;
            evento.UpdatedAt = DateTime.UtcNow;

            await _eventoRepository.UpdateAsync(evento);
            await _eventoRepository.SaveAsync();

            _logger.LogInformation($"Evento atualizado com sucesso: {evento.Titulo}");

            return await MapToEventoAgendaDtoAsync(evento);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao atualizar evento com ID: {id}");
            throw;
        }
    }

    /// <summary>
    /// Marca um evento como concluído
    /// </summary>
    public async Task<EventoAgendaDto> MarcarComoConcluidoAsync(Guid id)
    {
        try
        {
            var evento = await _eventoRepository.GetByIdAsync(id);
            if (evento == null)
            {
                throw new InvalidOperationException("Evento não encontrado");
            }

            evento.Concluido = true;
            evento.UpdatedAt = DateTime.UtcNow;

            await _eventoRepository.UpdateAsync(evento);
            await _eventoRepository.SaveAsync();

            _logger.LogInformation($"Evento marcado como concluído: {evento.Titulo}");

            return await MapToEventoAgendaDtoAsync(evento);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao marcar evento como concluído: {id}");
            throw;
        }
    }

    /// <summary>
    /// Deleta um evento da agenda (soft delete)
    /// </summary>
    public async Task DeletarAsync(Guid id)
    {
        try
        {
            var evento = await _eventoRepository.GetByIdAsync(id);
            if (evento == null)
            {
                throw new InvalidOperationException("Evento não encontrado");
            }

            evento.IsDeleted = true;
            evento.UpdatedAt = DateTime.UtcNow;

            await _eventoRepository.UpdateAsync(evento);
            await _eventoRepository.SaveAsync();

            _logger.LogInformation($"Evento deletado com sucesso: {evento.Titulo}");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao deletar evento com ID: {id}");
            throw;
        }
    }

    private async Task<EventoAgendaDto> MapToEventoAgendaDtoAsync(EventoAgenda evento)
    {
        return new EventoAgendaDto
        {
            Id = evento.Id,
            Tipo = evento.Tipo,
            Titulo = evento.Titulo,
            Descricao = evento.Descricao,
            DataHora = evento.DataHora,
            PedidoId = evento.PedidoId,
            PedidoNumero = evento.Pedido?.NumeroPedido,
            DentistaId = evento.DentistaId,
            DentistaNome = evento.Dentista?.Nome,
            Concluido = evento.Concluido
        };
    }

    private async Task<IEnumerable<EventoAgendaDto>> MapToEventoAgendaDtoListAsync(IEnumerable<EventoAgenda> eventos)
    {
        var dtos = new List<EventoAgendaDto>();
        foreach (var evento in eventos)
        {
            dtos.Add(await MapToEventoAgendaDtoAsync(evento));
        }
        return dtos;
    }
}
