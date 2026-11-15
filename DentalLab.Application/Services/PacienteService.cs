namespace DentalLab.Application.Services;

using DentalLab.Application.DTOs;
using DentalLab.Domain.Entities;
using DentalLab.Domain.Interfaces;
using FluentValidation;
using Microsoft.Extensions.Logging;

/// <summary>
/// Serviço para gerenciar Pacientes
/// </summary>
public class PacienteService
{
    private readonly IPacienteRepository _pacienteRepository;
    private readonly IDentistaRepository _dentistaRepository;
    private readonly IValidator<Paciente> _validator;
    private readonly ILogger<PacienteService> _logger;

    public PacienteService(
        IPacienteRepository pacienteRepository,
        IDentistaRepository dentistaRepository,
        IValidator<Paciente> validator,
        ILogger<PacienteService> logger)
    {
        _pacienteRepository = pacienteRepository;
        _dentistaRepository = dentistaRepository;
        _validator = validator;
        _logger = logger;
    }

    /// <summary>
    /// Obtém todos os pacientes
    /// </summary>
    public async Task<IEnumerable<PacienteDto>> GetTodosAsync()
    {
        try
        {
            var pacientes = await _pacienteRepository.GetAllAsync();
            return await MapToPacienteDtoListAsync(pacientes);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao obter lista de pacientes");
            throw;
        }
    }

    /// <summary>
    /// Obtém um paciente por ID
    /// </summary>
    public async Task<PacienteDto?> GetPorIdAsync(Guid id)
    {
        try
        {
            var paciente = await _pacienteRepository.GetByIdAsync(id);
            if (paciente == null) return null;

            return await MapToPacienteDtoAsync(paciente);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao obter paciente com ID: {id}");
            throw;
        }
    }

    /// <summary>
    /// Busca pacientes por nome
    /// </summary>
    public async Task<IEnumerable<PacienteDto>> BuscarPorNomeAsync(string nome)
    {
        try
        {
            var pacientes = await _pacienteRepository.GetAllAsync();
            var resultado = pacientes.Where(p => p.Nome.Contains(nome, StringComparison.OrdinalIgnoreCase));
            return await MapToPacienteDtoListAsync(resultado);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao buscar pacientes por nome: {nome}");
            throw;
        }
    }

    /// <summary>
    /// Obtém pacientes de um dentista
    /// </summary>
    public async Task<IEnumerable<PacienteDto>> GetPorDentistaAsync(Guid dentistaId)
    {
        try
        {
            var pacientes = await _pacienteRepository.GetByDentistaAsync(dentistaId);
            return await MapToPacienteDtoListAsync(pacientes);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao obter pacientes do dentista: {dentistaId}");
            throw;
        }
    }

    /// <summary>
    /// Cria um novo paciente
    /// </summary>
    public async Task<PacienteDto> CriarAsync(CreateUpdatePacienteDto dto)
    {
        try
        {
            // Verificar se dentista existe
            var dentista = await _dentistaRepository.GetByIdAsync(dto.DentistaResponsavelId);
            if (dentista == null)
            {
                throw new InvalidOperationException("Dentista não encontrado");
            }

            // Verificar se CPF já existe
            if (await _pacienteRepository.CPFExistsAsync(dto.CPF))
            {
                throw new InvalidOperationException("CPF já cadastrado no sistema");
            }

            var paciente = new Paciente(
                dto.Nome,
                dto.CPF,
                dto.Telefone,
                dto.DataNascimento,
                dto.DentistaResponsavelId)
            {
                Observacoes = dto.Observacoes
            };

            // Validar
            var validationResult = await _validator.ValidateAsync(paciente);
            if (!validationResult.IsValid)
            {
                var errors = string.Join("; ", validationResult.Errors.Select(e => e.ErrorMessage));
                throw new ValidationException(errors);
            }

            await _pacienteRepository.AddAsync(paciente);
            await _pacienteRepository.SaveAsync();

            _logger.LogInformation($"Paciente criado com sucesso: {paciente.Nome} - CPF: {paciente.CPF}");

            return await MapToPacienteDtoAsync(paciente);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao criar paciente: {dto.Nome}");
            throw;
        }
    }

    /// <summary>
    /// Atualiza um paciente existente
    /// </summary>
    public async Task<PacienteDto> AtualizarAsync(Guid id, CreateUpdatePacienteDto dto)
    {
        try
        {
            var paciente = await _pacienteRepository.GetByIdAsync(id);
            if (paciente == null)
            {
                throw new InvalidOperationException("Paciente não encontrado");
            }

            // Verificar se dentista existe
            var dentista = await _dentistaRepository.GetByIdAsync(dto.DentistaResponsavelId);
            if (dentista == null)
            {
                throw new InvalidOperationException("Dentista não encontrado");
            }

            // Verificar se novo CPF já existe (excluindo o atual)
            if (paciente.CPF != dto.CPF && await _pacienteRepository.CPFExistsAsync(dto.CPF, id))
            {
                throw new InvalidOperationException("CPF já cadastrado no sistema");
            }

            paciente.Nome = dto.Nome;
            paciente.CPF = dto.CPF;
            paciente.Telefone = dto.Telefone;
            paciente.DataNascimento = dto.DataNascimento;
            paciente.DentistaResponsavelId = dto.DentistaResponsavelId;
            paciente.Observacoes = dto.Observacoes;
            paciente.UpdatedAt = DateTime.UtcNow;

            // Validar
            var validationResult = await _validator.ValidateAsync(paciente);
            if (!validationResult.IsValid)
            {
                var errors = string.Join("; ", validationResult.Errors.Select(e => e.ErrorMessage));
                throw new ValidationException(errors);
            }

            await _pacienteRepository.UpdateAsync(paciente);
            await _pacienteRepository.SaveAsync();

            _logger.LogInformation($"Paciente atualizado com sucesso: {paciente.Nome}");

            return await MapToPacienteDtoAsync(paciente);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao atualizar paciente com ID: {id}");
            throw;
        }
    }

    /// <summary>
    /// Deleta um paciente (soft delete)
    /// </summary>
    public async Task DeletarAsync(Guid id)
    {
        try
        {
            var paciente = await _pacienteRepository.GetByIdAsync(id);
            if (paciente == null)
            {
                throw new InvalidOperationException("Paciente não encontrado");
            }

            paciente.IsDeleted = true;
            paciente.UpdatedAt = DateTime.UtcNow;

            await _pacienteRepository.UpdateAsync(paciente);
            await _pacienteRepository.SaveAsync();

            _logger.LogInformation($"Paciente deletado com sucesso: {paciente.Nome}");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao deletar paciente com ID: {id}");
            throw;
        }
    }

    private async Task<PacienteDto> MapToPacienteDtoAsync(Paciente paciente)
    {
        var dentista = paciente.DentistaResponsavel;
        if (dentista == null)
        {
            dentista = await _dentistaRepository.GetByIdAsync(paciente.DentistaResponsavelId);
        }

        return new PacienteDto
        {
            Id = paciente.Id,
            Nome = paciente.Nome,
            CPF = paciente.CPF,
            Telefone = paciente.Telefone,
            DataNascimento = paciente.DataNascimento,
            DentistaResponsavelId = paciente.DentistaResponsavelId,
            DentistaResponsavelNome = dentista?.Nome,
            Observacoes = paciente.Observacoes
        };
    }

    private async Task<IEnumerable<PacienteDto>> MapToPacienteDtoListAsync(IEnumerable<Paciente> pacientes)
    {
        var dtos = new List<PacienteDto>();
        foreach (var paciente in pacientes)
        {
            dtos.Add(await MapToPacienteDtoAsync(paciente));
        }
        return dtos;
    }
}
