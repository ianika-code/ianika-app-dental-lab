namespace DentalLab.Application.Services;

using DentalLab.Application.DTOs;
using DentalLab.Domain.Entities;
using DentalLab.Domain.Enums;
using DentalLab.Domain.Interfaces;
using FluentValidation;
using Microsoft.Extensions.Logging;

/// <summary>
/// Serviço para gerenciar Pedidos
/// </summary>
public class PedidoService
{
    private readonly IPedidoRepository _pedidoRepository;
    private readonly IPacienteRepository _pacienteRepository;
    private readonly IDentistaRepository _dentistaRepository;
    private readonly IValidator<Pedido> _validator;
    private readonly ILogger<PedidoService> _logger;

    public PedidoService(
        IPedidoRepository pedidoRepository,
        IPacienteRepository pacienteRepository,
        IDentistaRepository dentistaRepository,
        IValidator<Pedido> validator,
        ILogger<PedidoService> logger)
    {
        _pedidoRepository = pedidoRepository;
        _pacienteRepository = pacienteRepository;
        _dentistaRepository = dentistaRepository;
        _validator = validator;
        _logger = logger;
    }

    /// <summary>
    /// Obtém todos os pedidos
    /// </summary>
    public async Task<IEnumerable<PedidoDto>> GetTodosAsync()
    {
        try
        {
            var pedidos = await _pedidoRepository.GetAllAsync();
            return pedidos.Select(MapToPedidoDto).ToList();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao obter lista de pedidos");
            throw;
        }
    }

    /// <summary>
    /// Obtém um pedido por ID
    /// </summary>
    public async Task<PedidoDto?> GetPorIdAsync(Guid id)
    {
        try
        {
            var pedido = await _pedidoRepository.GetByIdAsync(id);
            return pedido != null ? MapToPedidoDto(pedido) : null;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao obter pedido com ID: {id}");
            throw;
        }
    }

    /// <summary>
    /// Obtém pedidos por status
    /// </summary>
    public async Task<IEnumerable<PedidoDto>> GetPorStatusAsync(StatusPedido status)
    {
        try
        {
            var pedidos = await _pedidoRepository.GetByStatusAsync(status);
            return pedidos.Select(MapToPedidoDto).ToList();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao obter pedidos com status: {status}");
            throw;
        }
    }

    /// <summary>
    /// Obtém pedidos de um paciente
    /// </summary>
    public async Task<IEnumerable<PedidoDto>> GetPorPacienteAsync(Guid pacienteId)
    {
        try
        {
            var pedidos = await _pedidoRepository.GetByPacienteAsync(pacienteId);
            return pedidos.Select(MapToPedidoDto).ToList();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao obter pedidos do paciente: {pacienteId}");
            throw;
        }
    }

    /// <summary>
    /// Obtém pedidos de um dentista
    /// </summary>
    public async Task<IEnumerable<PedidoDto>> GetPorDentistaAsync(Guid dentistaId)
    {
        try
        {
            var pedidos = await _pedidoRepository.GetByDentistaAsync(dentistaId);
            return pedidos.Select(MapToPedidoDto).ToList();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao obter pedidos do dentista: {dentistaId}");
            throw;
        }
    }

    /// <summary>
    /// Obtém pedidos em um período
    /// </summary>
    public async Task<IEnumerable<PedidoDto>> GetPorPeriodoAsync(DateTime dataInicio, DateTime dataFim)
    {
        try
        {
            var pedidos = await _pedidoRepository.GetPorPeriodoAsync(dataInicio, dataFim);
            return pedidos.Select(MapToPedidoDto).ToList();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao obter pedidos do período: {dataInicio} a {dataFim}");
            throw;
        }
    }

    /// <summary>
    /// Cria um novo pedido
    /// </summary>
    public async Task<PedidoDto> CriarAsync(CreateUpdatePedidoDto dto)
    {
        try
        {
            // Verificar se paciente existe
            var paciente = await _pacienteRepository.GetByIdAsync(dto.PacienteId);
            if (paciente == null)
            {
                throw new InvalidOperationException("Paciente não encontrado");
            }

            // Verificar se dentista existe
            var dentista = await _dentistaRepository.GetByIdAsync(dto.DentistaId);
            if (dentista == null)
            {
                throw new InvalidOperationException("Dentista não encontrado");
            }

            // Verificar se número do pedido já existe
            if (await _pedidoRepository.NumeroPedidoExistsAsync(dto.NumeroPedido))
            {
                throw new InvalidOperationException("Número de pedido já existe");
            }

            var pedido = new Pedido(
                dto.NumeroPedido,
                dto.PacienteId,
                dto.DentistaId,
                dto.TipoProtese,
                dto.DataPrevista,
                dto.Valor)
            {
                Observacoes = dto.Observacoes
            };

            // Validar
            var validationResult = await _validator.ValidateAsync(pedido);
            if (!validationResult.IsValid)
            {
                var errors = string.Join("; ", validationResult.Errors.Select(e => e.ErrorMessage));
                throw new ValidationException(errors);
            }

            await _pedidoRepository.AddAsync(pedido);
            await _pedidoRepository.SaveAsync();

            _logger.LogInformation($"Pedido criado com sucesso: {pedido.NumeroPedido}");

            return MapToPedidoDto(pedido);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao criar pedido: {dto.NumeroPedido}");
            throw;
        }
    }

    /// <summary>
    /// Atualiza um pedido existente
    /// </summary>
    public async Task<PedidoDto> AtualizarAsync(Guid id, CreateUpdatePedidoDto dto)
    {
        try
        {
            var pedido = await _pedidoRepository.GetByIdAsync(id);
            if (pedido == null)
            {
                throw new InvalidOperationException("Pedido não encontrado");
            }

            // Verificar se novo número de pedido já existe
            if (pedido.NumeroPedido != dto.NumeroPedido && 
                await _pedidoRepository.NumeroPedidoExistsAsync(dto.NumeroPedido, id))
            {
                throw new InvalidOperationException("Número de pedido já existe");
            }

            // Verificar se paciente existe
            var paciente = await _pacienteRepository.GetByIdAsync(dto.PacienteId);
            if (paciente == null)
            {
                throw new InvalidOperationException("Paciente não encontrado");
            }

            // Verificar se dentista existe
            var dentista = await _dentistaRepository.GetByIdAsync(dto.DentistaId);
            if (dentista == null)
            {
                throw new InvalidOperationException("Dentista não encontrado");
            }

            pedido.NumeroPedido = dto.NumeroPedido;
            pedido.PacienteId = dto.PacienteId;
            pedido.DentistaId = dto.DentistaId;
            pedido.TipoProtese = dto.TipoProtese;
            pedido.DataPrevista = dto.DataPrevista;
            pedido.Valor = dto.Valor;
            pedido.Observacoes = dto.Observacoes;
            pedido.UpdatedAt = DateTime.UtcNow;

            // Validar
            var validationResult = await _validator.ValidateAsync(pedido);
            if (!validationResult.IsValid)
            {
                var errors = string.Join("; ", validationResult.Errors.Select(e => e.ErrorMessage));
                throw new ValidationException(errors);
            }

            await _pedidoRepository.UpdateAsync(pedido);
            await _pedidoRepository.SaveAsync();

            _logger.LogInformation($"Pedido atualizado com sucesso: {pedido.NumeroPedido}");

            return MapToPedidoDto(pedido);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao atualizar pedido com ID: {id}");
            throw;
        }
    }

    /// <summary>
    /// Atualiza o status de um pedido
    /// </summary>
    public async Task<PedidoDto> AtualizarStatusAsync(Guid id, StatusPedido novoStatus)
    {
        try
        {
            var pedido = await _pedidoRepository.GetByIdAsync(id);
            if (pedido == null)
            {
                throw new InvalidOperationException("Pedido não encontrado");
            }

            pedido.Status = novoStatus;

            // Se for finalizado, registra a data de entrega
            if (novoStatus == StatusPedido.Finalizado)
            {
                pedido.DataEntrega = DateTime.UtcNow;
            }

            pedido.UpdatedAt = DateTime.UtcNow;

            await _pedidoRepository.UpdateAsync(pedido);
            await _pedidoRepository.SaveAsync();

            _logger.LogInformation($"Status do pedido {pedido.NumeroPedido} atualizado para: {novoStatus}");

            return MapToPedidoDto(pedido);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao atualizar status do pedido com ID: {id}");
            throw;
        }
    }

    /// <summary>
    /// Deleta um pedido (soft delete)
    /// </summary>
    public async Task DeletarAsync(Guid id)
    {
        try
        {
            var pedido = await _pedidoRepository.GetByIdAsync(id);
            if (pedido == null)
            {
                throw new InvalidOperationException("Pedido não encontrado");
            }

            pedido.IsDeleted = true;
            pedido.UpdatedAt = DateTime.UtcNow;

            await _pedidoRepository.UpdateAsync(pedido);
            await _pedidoRepository.SaveAsync();

            _logger.LogInformation($"Pedido deletado com sucesso: {pedido.NumeroPedido}");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao deletar pedido com ID: {id}");
            throw;
        }
    }

    private static PedidoDto MapToPedidoDto(Pedido pedido)
    {
        return new PedidoDto
        {
            Id = pedido.Id,
            NumeroPedido = pedido.NumeroPedido,
            PacienteId = pedido.PacienteId,
            PacienteNome = pedido.Paciente?.Nome,
            DentistaId = pedido.DentistaId,
            DentistaNome = pedido.Dentista?.Nome,
            TipoProtese = pedido.TipoProtese,
            DataPedido = pedido.DataPedido,
            DataPrevista = pedido.DataPrevista,
            DataEntrega = pedido.DataEntrega,
            Valor = pedido.Valor,
            Status = pedido.Status,
            Observacoes = pedido.Observacoes
        };
    }
}
