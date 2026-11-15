namespace DentalLab.Application.Services;

using DentalLab.Application.DTOs;
using DentalLab.Domain.Entities;
using DentalLab.Domain.Enums;
using DentalLab.Domain.Interfaces;
using FluentValidation;
using Microsoft.Extensions.Logging;

/// <summary>
/// Serviço para gerenciar Estoque
/// </summary>
public class EstoqueService
{
    private readonly IEstoqueItemRepository _estoqueItemRepository;
    private readonly IMovimentacaoEstoqueRepository _movimentacaoRepository;
    private readonly IValidator<EstoqueItem> _validator;
    private readonly ILogger<EstoqueService> _logger;

    public EstoqueService(
        IEstoqueItemRepository estoqueItemRepository,
        IMovimentacaoEstoqueRepository movimentacaoRepository,
        IValidator<EstoqueItem> validator,
        ILogger<EstoqueService> logger)
    {
        _estoqueItemRepository = estoqueItemRepository;
        _movimentacaoRepository = movimentacaoRepository;
        _validator = validator;
        _logger = logger;
    }

    /// <summary>
    /// Obtém todos os itens de estoque
    /// </summary>
    public async Task<IEnumerable<EstoqueItemDto>> GetTodosAsync()
    {
        try
        {
            var itens = await _estoqueItemRepository.GetAllAsync();
            return itens.Select(MapToEstoqueItemDto).ToList();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao obter lista de itens de estoque");
            throw;
        }
    }

    /// <summary>
    /// Obtém um item de estoque por ID
    /// </summary>
    public async Task<EstoqueItemDto?> GetPorIdAsync(Guid id)
    {
        try
        {
            var item = await _estoqueItemRepository.GetByIdAsync(id);
            return item != null ? MapToEstoqueItemDto(item) : null;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao obter item de estoque com ID: {id}");
            throw;
        }
    }

    /// <summary>
    /// Obtém itens de estoque por categoria
    /// </summary>
    public async Task<IEnumerable<EstoqueItemDto>> GetPorCategoriaAsync(CategoriaEstoque categoria)
    {
        try
        {
            var itens = await _estoqueItemRepository.GetPorCategoriaAsync(categoria.ToString());
            return itens.Select(MapToEstoqueItemDto).ToList();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao obter itens por categoria: {categoria}");
            throw;
        }
    }

    /// <summary>
    /// Obtém itens com estoque baixo (quantidade <= mínima)
    /// </summary>
    public async Task<IEnumerable<EstoqueItemDto>> GetItensBaixosAsync()
    {
        try
        {
            var itens = await _estoqueItemRepository.GetItensBaixosAsync();
            return itens.Select(MapToEstoqueItemDto).ToList();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao obter itens com estoque baixo");
            throw;
        }
    }

    /// <summary>
    /// Busca itens por nome
    /// </summary>
    public async Task<IEnumerable<EstoqueItemDto>> BuscarPorNomeAsync(string nome)
    {
        try
        {
            var itens = await _estoqueItemRepository.GetAllAsync();
            return itens
                .Where(i => i.Nome.Contains(nome, StringComparison.OrdinalIgnoreCase))
                .Select(MapToEstoqueItemDto)
                .ToList();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao buscar itens por nome: {nome}");
            throw;
        }
    }

    /// <summary>
    /// Cria um novo item de estoque
    /// </summary>
    public async Task<EstoqueItemDto> CriarAsync(CreateUpdateEstoqueItemDto dto)
    {
        try
        {
            // Verificar se item com mesmo nome já existe
            var itemExistente = await _estoqueItemRepository.GetByNomeAsync(dto.Nome);
            if (itemExistente != null)
            {
                throw new InvalidOperationException("Item com este nome já existe no estoque");
            }

            var item = new EstoqueItem(
                dto.Nome,
                dto.Categoria,
                dto.QuantidadeMinima,
                dto.UnidadeMedida)
            {
                Descricao = dto.Descricao,
                ValorUnitario = dto.ValorUnitario,
                Fornecedor = dto.Fornecedor,
                QuantidadeAtual = 0
            };

            // Validar
            var validationResult = await _validator.ValidateAsync(item);
            if (!validationResult.IsValid)
            {
                var errors = string.Join("; ", validationResult.Errors.Select(e => e.ErrorMessage));
                throw new ValidationException(errors);
            }

            await _estoqueItemRepository.AddAsync(item);
            await _estoqueItemRepository.SaveAsync();

            _logger.LogInformation($"Item de estoque criado com sucesso: {item.Nome}");

            return MapToEstoqueItemDto(item);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao criar item de estoque: {dto.Nome}");
            throw;
        }
    }

    /// <summary>
    /// Atualiza um item de estoque
    /// </summary>
    public async Task<EstoqueItemDto> AtualizarAsync(Guid id, CreateUpdateEstoqueItemDto dto)
    {
        try
        {
            var item = await _estoqueItemRepository.GetByIdAsync(id);
            if (item == null)
            {
                throw new InvalidOperationException("Item de estoque não encontrado");
            }

            // Verificar se novo nome já existe (excluindo o atual)
            if (item.Nome != dto.Nome)
            {
                var itemExistente = await _estoqueItemRepository.GetByNomeAsync(dto.Nome);
                if (itemExistente != null)
                {
                    throw new InvalidOperationException("Item com este nome já existe no estoque");
                }
            }

            item.Nome = dto.Nome;
            item.Categoria = dto.Categoria;
            item.Descricao = dto.Descricao;
            item.QuantidadeMinima = dto.QuantidadeMinima;
            item.UnidadeMedida = dto.UnidadeMedida;
            item.ValorUnitario = dto.ValorUnitario;
            item.Fornecedor = dto.Fornecedor;
            item.UpdatedAt = DateTime.UtcNow;

            // Validar
            var validationResult = await _validator.ValidateAsync(item);
            if (!validationResult.IsValid)
            {
                var errors = string.Join("; ", validationResult.Errors.Select(e => e.ErrorMessage));
                throw new ValidationException(errors);
            }

            await _estoqueItemRepository.UpdateAsync(item);
            await _estoqueItemRepository.SaveAsync();

            _logger.LogInformation($"Item de estoque atualizado com sucesso: {item.Nome}");

            return MapToEstoqueItemDto(item);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao atualizar item de estoque com ID: {id}");
            throw;
        }
    }

    /// <summary>
    /// Registra uma entrada de material no estoque
    /// </summary>
    public async Task<EstoqueItemDto> RegistrarEntradaAsync(Guid estoqueItemId, int quantidade, string motivo, string? observacoes = null)
    {
        try
        {
            if (quantidade <= 0)
            {
                throw new InvalidOperationException("Quantidade deve ser maior que zero");
            }

            var item = await _estoqueItemRepository.GetByIdAsync(estoqueItemId);
            if (item == null)
            {
                throw new InvalidOperationException("Item de estoque não encontrado");
            }

            // Atualizar quantidade
            item.QuantidadeAtual += quantidade;
            item.DataUltimaEntrada = DateTime.UtcNow;
            item.UpdatedAt = DateTime.UtcNow;

            // Registrar movimentação
            var movimentacao = new MovimentacaoEstoque(
                estoqueItemId,
                TipoMovimentacao.Entrada,
                quantidade,
                motivo)
            {
                Observacoes = observacoes
            };

            await _estoqueItemRepository.UpdateAsync(item);
            await _movimentacaoRepository.AddAsync(movimentacao);
            await _movimentacaoRepository.SaveAsync();

            _logger.LogInformation(
                $"Entrada registrada no estoque: {item.Nome} - Quantidade: {quantidade} - Motivo: {motivo}");

            return MapToEstoqueItemDto(item);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao registrar entrada de estoque para item: {estoqueItemId}");
            throw;
        }
    }

    /// <summary>
    /// Registra uma saída de material do estoque
    /// </summary>
    public async Task<EstoqueItemDto> RegistrarSaidaAsync(Guid estoqueItemId, int quantidade, string motivo, string? observacoes = null)
    {
        try
        {
            if (quantidade <= 0)
            {
                throw new InvalidOperationException("Quantidade deve ser maior que zero");
            }

            var item = await _estoqueItemRepository.GetByIdAsync(estoqueItemId);
            if (item == null)
            {
                throw new InvalidOperationException("Item de estoque não encontrado");
            }

            // Verificar se há quantidade suficiente
            if (item.QuantidadeAtual < quantidade)
            {
                throw new InvalidOperationException(
                    $"Quantidade insuficiente em estoque. Disponível: {item.QuantidadeAtual}");
            }

            // Atualizar quantidade
            item.QuantidadeAtual -= quantidade;
            item.UpdatedAt = DateTime.UtcNow;

            // Registrar movimentação
            var movimentacao = new MovimentacaoEstoque(
                estoqueItemId,
                TipoMovimentacao.Saida,
                quantidade,
                motivo)
            {
                Observacoes = observacoes
            };

            await _estoqueItemRepository.UpdateAsync(item);
            await _movimentacaoRepository.AddAsync(movimentacao);
            await _movimentacaoRepository.SaveAsync();

            _logger.LogInformation(
                $"Saída registrada no estoque: {item.Nome} - Quantidade: {quantidade} - Motivo: {motivo}");

            return MapToEstoqueItemDto(item);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao registrar saída de estoque para item: {estoqueItemId}");
            throw;
        }
    }

    /// <summary>
    /// Obtém o histórico de movimentações de um item
    /// </summary>
    public async Task<IEnumerable<MovimentacaoEstoqueDto>> GetHistoricoMovimentacoesAsync(Guid estoqueItemId)
    {
        try
        {
            var movimentacoes = await _movimentacaoRepository.GetByEstoqueItemAsync(estoqueItemId);
            return movimentacoes.Select(MapToMovimentacaoEstoqueDto).ToList();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao obter histórico de movimentações do item: {estoqueItemId}");
            throw;
        }
    }

    /// <summary>
    /// Obtém movimentações de um período
    /// </summary>
    public async Task<IEnumerable<MovimentacaoEstoqueDto>> GetMovimentacoesPorPeriodoAsync(
        DateTime dataInicio,
        DateTime dataFim)
    {
        try
        {
            var movimentacoes = await _movimentacaoRepository.GetPorPeriodoAsync(dataInicio, dataFim);
            return movimentacoes.Select(MapToMovimentacaoEstoqueDto).ToList();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao obter movimentações do período: {dataInicio} a {dataFim}");
            throw;
        }
    }

    /// <summary>
    /// Calcula o valor total em estoque
    /// </summary>
    public async Task<decimal> CalcularValorTotalEstoqueAsync()
    {
        try
        {
            var itens = await _estoqueItemRepository.GetAllAsync();
            return itens.Sum(i => i.QuantidadeAtual * i.ValorUnitario);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao calcular valor total do estoque");
            throw;
        }
    }

    /// <summary>
    /// Deleta um item de estoque (soft delete)
    /// </summary>
    public async Task DeletarAsync(Guid id)
    {
        try
        {
            var item = await _estoqueItemRepository.GetByIdAsync(id);
            if (item == null)
            {
                throw new InvalidOperationException("Item de estoque não encontrado");
            }

            item.IsDeleted = true;
            item.UpdatedAt = DateTime.UtcNow;

            await _estoqueItemRepository.UpdateAsync(item);
            await _estoqueItemRepository.SaveAsync();

            _logger.LogInformation($"Item de estoque deletado com sucesso: {item.Nome}");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao deletar item de estoque com ID: {id}");
            throw;
        }
    }

    private static EstoqueItemDto MapToEstoqueItemDto(EstoqueItem item)
    {
        return new EstoqueItemDto
        {
            Id = item.Id,
            Nome = item.Nome,
            Categoria = item.Categoria,
            Descricao = item.Descricao,
            QuantidadeAtual = item.QuantidadeAtual,
            QuantidadeMinima = item.QuantidadeMinima,
            UnidadeMedida = item.UnidadeMedida,
            ValorUnitario = item.ValorUnitario,
            Fornecedor = item.Fornecedor,
            EstoqueBaixo = item.EstoqueBaixo
        };
    }

    private static MovimentacaoEstoqueDto MapToMovimentacaoEstoqueDto(MovimentacaoEstoque movimentacao)
    {
        return new MovimentacaoEstoqueDto
        {
            Id = movimentacao.Id,
            EstoqueItemId = movimentacao.EstoqueItemId,
            EstoqueItemNome = movimentacao.EstoqueItem?.Nome ?? string.Empty,
            Tipo = movimentacao.Tipo,
            Quantidade = movimentacao.Quantidade,
            DataMovimentacao = movimentacao.DataMovimentacao,
            Motivo = movimentacao.Motivo,
            Observacoes = movimentacao.Observacoes
        };
    }
}
