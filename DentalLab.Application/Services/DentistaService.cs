namespace DentalLab.Application.Services;

using DentalLab.Application.DTOs;
using DentalLab.Domain.Entities;
using DentalLab.Domain.Interfaces;
using FluentValidation;
using Microsoft.Extensions.Logging;

/// <summary>
/// Serviço para gerenciar Dentistas
/// </summary>
public class DentistaService
{
    private readonly IDentistaRepository _dentistaRepository;
    private readonly IValidator<Dentista> _validator;
    private readonly ILogger<DentistaService> _logger;

    public DentistaService(
        IDentistaRepository dentistaRepository,
        IValidator<Dentista> validator,
        ILogger<DentistaService> logger)
    {
        _dentistaRepository = dentistaRepository;
        _validator = validator;
        _logger = logger;
    }

    /// <summary>
    /// Obtém todos os dentistas
    /// </summary>
    public async Task<IEnumerable<DentistaDto>> GetTodosAsync()
    {
        try
        {
            var dentistas = await _dentistaRepository.GetAllAsync();
            return dentistas.Select(MapToDentistaDto).ToList();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao obter lista de dentistas");
            throw;
        }
    }

    /// <summary>
    /// Obtém um dentista por ID
    /// </summary>
    public async Task<DentistaDto?> GetPorIdAsync(Guid id)
    {
        try
        {
            var dentista = await _dentistaRepository.GetByIdAsync(id);
            return dentista != null ? MapToDentistaDto(dentista) : null;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao obter dentista com ID: {id}");
            throw;
        }
    }

    /// <summary>
    /// Busca dentistas por nome
    /// </summary>
    public async Task<IEnumerable<DentistaDto>> BuscarPorNomeAsync(string nome)
    {
        try
        {
            var dentistas = await _dentistaRepository.GetAllAsync();
            return dentistas
                .Where(d => d.Nome.Contains(nome, StringComparison.OrdinalIgnoreCase))
                .Select(MapToDentistaDto)
                .ToList();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao buscar dentistas por nome: {nome}");
            throw;
        }
    }

    /// <summary>
    /// Cria um novo dentista
    /// </summary>
    public async Task<DentistaDto> CriarAsync(CreateUpdateDentistaDto dto)
    {
        try
        {
            // Verificar se CRO já existe
            if (await _dentistaRepository.CROExistsAsync(dto.CRO))
            {
                throw new InvalidOperationException("CRO já cadastrado no sistema");
            }

            var dentista = new Dentista(
                dto.Nome,
                dto.CRO,
                dto.Telefone,
                dto.Email,
                dto.Endereco)
            {
                Observacoes = dto.Observacoes
            };

            // Validar
            var validationResult = await _validator.ValidateAsync(dentista);
            if (!validationResult.IsValid)
            {
                var errors = string.Join("; ", validationResult.Errors.Select(e => e.ErrorMessage));
                throw new ValidationException(errors);
            }

            await _dentistaRepository.AddAsync(dentista);
            await _dentistaRepository.SaveAsync();

            _logger.LogInformation($"Dentista criado com sucesso: {dentista.Nome} - CRO: {dentista.CRO}");

            return MapToDentistaDto(dentista);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao criar dentista: {dto.Nome}");
            throw;
        }
    }

    /// <summary>
    /// Atualiza um dentista existente
    /// </summary>
    public async Task<DentistaDto> AtualizarAsync(Guid id, CreateUpdateDentistaDto dto)
    {
        try
        {
            var dentista = await _dentistaRepository.GetByIdAsync(id);

            if (dentista == null)
            {
                throw new InvalidOperationException("Dentista não encontrado");
            }

            // Verificar se novo CRO já existe (excluindo o atual)
            if (dentista.CRO != dto.CRO && await _dentistaRepository.CROExistsAsync(dto.CRO, id))
            {
                throw new InvalidOperationException("CRO já cadastrado no sistema");
            }

            dentista.Nome = dto.Nome;
            dentista.CRO = dto.CRO;
            dentista.Telefone = dto.Telefone;
            dentista.Email = dto.Email;
            dentista.Endereco = dto.Endereco;
            dentista.Observacoes = dto.Observacoes;
            dentista.UpdatedAt = DateTime.UtcNow;

            // Validar
            var validationResult = await _validator.ValidateAsync(dentista);
            if (!validationResult.IsValid)
            {
                var errors = string.Join("; ", validationResult.Errors.Select(e => e.ErrorMessage));
                throw new ValidationException(errors);
            }

            await _dentistaRepository.UpdateAsync(dentista);
            await _dentistaRepository.SaveAsync();

            _logger.LogInformation($"Dentista atualizado com sucesso: {dentista.Nome}");

            return MapToDentistaDto(dentista);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao atualizar dentista com ID: {id}");
            throw;
        }
    }

    /// <summary>
    /// Deleta um dentista (soft delete)
    /// </summary>
    public async Task DeletarAsync(Guid id)
    {
        try
        {
            var dentista = await _dentistaRepository.GetByIdAsync(id);

            if (dentista == null)
            {
                throw new InvalidOperationException("Dentista não encontrado");
            }

            // Verificar se tem pacientes associados
            if (dentista.Pacientes.Any())
            {
                throw new InvalidOperationException("Não é possível deletar um dentista com pacientes cadastrados");
            }

            dentista.IsDeleted = true;
            dentista.UpdatedAt = DateTime.UtcNow;

            await _dentistaRepository.UpdateAsync(dentista);
            await _dentistaRepository.SaveAsync();

            _logger.LogInformation($"Dentista deletado com sucesso: {dentista.Nome}");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao deletar dentista com ID: {id}");
            throw;
        }
    }

    private static DentistaDto MapToDentistaDto(Dentista dentista)
    {
        return new DentistaDto
        {
            Id = dentista.Id,
            Nome = dentista.Nome,
            CRO = dentista.CRO,
            Telefone = dentista.Telefone,
            Email = dentista.Email,
            Endereco = dentista.Endereco,
            Observacoes = dentista.Observacoes
        };
    }
}
