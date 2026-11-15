namespace DentalLab.Tests.Services;

using DentalLab.Application.DTOs;
using DentalLab.Application.Services;
using DentalLab.Domain.Entities;
using DentalLab.Domain.Enums;
using DentalLab.Domain.Interfaces;
using FluentAssertions;
using Moq;
using Microsoft.Extensions.Logging;
using FluentValidation;
using Xunit;

public class EstoqueServiceTests
{
    private readonly Mock<IEstoqueItemRepository> _estoqueItemRepositoryMock;
    private readonly Mock<IMovimentacaoEstoqueRepository> _movimentacaoRepositoryMock;
    private readonly Mock<IValidator<EstoqueItem>> _validatorMock;
    private readonly Mock<ILogger<EstoqueService>> _loggerMock;
    private readonly EstoqueService _estoqueService;

    public EstoqueServiceTests()
    {
        _estoqueItemRepositoryMock = new Mock<IEstoqueItemRepository>();
        _movimentacaoRepositoryMock = new Mock<IMovimentacaoEstoqueRepository>();
        _validatorMock = new Mock<IValidator<EstoqueItem>>();
        _loggerMock = new Mock<ILogger<EstoqueService>>();

        _estoqueService = new EstoqueService(
            _estoqueItemRepositoryMock.Object,
            _movimentacaoRepositoryMock.Object,
            _validatorMock.Object,
            _loggerMock.Object);
    }

    [Fact]
    public async Task CriarAsync_ComDadosValidos_DeveCriarItem()
    {
        // Arrange
        _estoqueItemRepositoryMock
            .Setup(r => r.GetByNomeAsync(It.IsAny<string>()))
            .ReturnsAsync((EstoqueItem?)null);

        _validatorMock
            .Setup(v => v.ValidateAsync(It.IsAny<EstoqueItem>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(new FluentValidation.Results.ValidationResult());

        _estoqueItemRepositoryMock
            .Setup(r => r.AddAsync(It.IsAny<EstoqueItem>()))
            .Returns(Task.CompletedTask);

        _estoqueItemRepositoryMock
            .Setup(r => r.SaveAsync())
            .Returns(Task.CompletedTask);

        var dto = new CreateUpdateEstoqueItemDto
        {
            Nome = "Resina Acrílica",
            Categoria = CategoriaEstoque.Resinas,
            QuantidadeMinima = 10,
            UnidadeMedida = "kg",
            ValorUnitario = 50m
        };

        // Act
        var resultado = await _estoqueService.CriarAsync(dto);

        // Assert
        resultado.Should().NotBeNull();
        resultado.Nome.Should().Be("Resina Acrílica");
        resultado.QuantidadeAtual.Should().Be(0);
        _estoqueItemRepositoryMock.Verify(r => r.AddAsync(It.IsAny<EstoqueItem>()), Times.Once);
    }

    [Fact]
    public async Task RegistrarEntradaAsync_ComQuantidadeValida_DeveAumentarEstoque()
    {
        // Arrange
        var itemId = Guid.NewGuid();
        var item = new EstoqueItem("Resina Acrílica", CategoriaEstoque.Resinas, 10, "kg")
        {
            Id = itemId,
            QuantidadeAtual = 5,
            ValorUnitario = 50m
        };

        _estoqueItemRepositoryMock
            .Setup(r => r.GetByIdAsync(itemId))
            .ReturnsAsync(item);

        _estoqueItemRepositoryMock
            .Setup(r => r.UpdateAsync(It.IsAny<EstoqueItem>()))
            .Returns(Task.CompletedTask);

        _movimentacaoRepositoryMock
            .Setup(r => r.AddAsync(It.IsAny<MovimentacaoEstoque>()))
            .Returns(Task.CompletedTask);

        _movimentacaoRepositoryMock
            .Setup(r => r.SaveAsync())
            .Returns(Task.CompletedTask);

        // Act
        var resultado = await _estoqueService.RegistrarEntradaAsync(itemId, 10, "Compra fornecedor");

        // Assert
        resultado.Should().NotBeNull();
        resultado.QuantidadeAtual.Should().Be(15);
        _estoqueItemRepositoryMock.Verify(r => r.UpdateAsync(It.IsAny<EstoqueItem>()), Times.Once);
        _movimentacaoRepositoryMock.Verify(r => r.AddAsync(It.IsAny<MovimentacaoEstoque>()), Times.Once);
    }

    [Fact]
    public async Task RegistrarSaidaAsync_ComQuantidadeSuficiente_DeveReduzirEstoque()
    {
        // Arrange
        var itemId = Guid.NewGuid();
        var item = new EstoqueItem("Resina Acrílica", CategoriaEstoque.Resinas, 10, "kg")
        {
            Id = itemId,
            QuantidadeAtual = 15,
            ValorUnitario = 50m
        };

        _estoqueItemRepositoryMock
            .Setup(r => r.GetByIdAsync(itemId))
            .ReturnsAsync(item);

        _estoqueItemRepositoryMock
            .Setup(r => r.UpdateAsync(It.IsAny<EstoqueItem>()))
            .Returns(Task.CompletedTask);

        _movimentacaoRepositoryMock
            .Setup(r => r.AddAsync(It.IsAny<MovimentacaoEstoque>()))
            .Returns(Task.CompletedTask);

        _movimentacaoRepositoryMock
            .Setup(r => r.SaveAsync())
            .Returns(Task.CompletedTask);

        // Act
        var resultado = await _estoqueService.RegistrarSaidaAsync(itemId, 5, "Uso em produção");

        // Assert
        resultado.Should().NotBeNull();
        resultado.QuantidadeAtual.Should().Be(10);
        _estoqueItemRepositoryMock.Verify(r => r.UpdateAsync(It.IsAny<EstoqueItem>()), Times.Once);
        _movimentacaoRepositoryMock.Verify(r => r.AddAsync(It.IsAny<MovimentacaoEstoque>()), Times.Once);
    }

    [Fact]
    public async Task RegistrarSaidaAsync_ComQuantidadeInsuficiente_DeveLancarExcecao()
    {
        // Arrange
        var itemId = Guid.NewGuid();
        var item = new EstoqueItem("Resina Acrílica", CategoriaEstoque.Resinas, 10, "kg")
        {
            Id = itemId,
            QuantidadeAtual = 5,
            ValorUnitario = 50m
        };

        _estoqueItemRepositoryMock
            .Setup(r => r.GetByIdAsync(itemId))
            .ReturnsAsync(item);

        // Act & Assert
        await Assert.ThrowsAsync<InvalidOperationException>(() 
            => _estoqueService.RegistrarSaidaAsync(itemId, 10, "Uso em produção"));
    }

    [Fact]
    public async Task GetItensBaixosAsync_DeveRetornarApenasItensBaixos()
    {
        // Arrange
        var itemBaixo = new EstoqueItem("Resina", CategoriaEstoque.Resinas, 10, "kg")
        {
            QuantidadeAtual = 5
        };

        var itemNormal = new EstoqueItem("Gesso", CategoriaEstoque.Gessos, 5, "kg")
        {
            QuantidadeAtual = 20
        };

        _estoqueItemRepositoryMock
            .Setup(r => r.GetItensBaixosAsync())
            .ReturnsAsync(new[] { itemBaixo });

        // Act
        var resultado = await _estoqueService.GetItensBaixosAsync();

        // Assert
        resultado.Should().HaveCount(1);
        resultado.First().EstoqueBaixo.Should().BeTrue();
    }

    [Fact]
    public async Task CalcularValorTotalEstoqueAsync_DeveRetornarValorCorreto()
    {
        // Arrange
        var item1 = new EstoqueItem("Resina", CategoriaEstoque.Resinas, 10, "kg")
        {
            QuantidadeAtual = 10,
            ValorUnitario = 50m
        };

        var item2 = new EstoqueItem("Gesso", CategoriaEstoque.Gessos, 5, "kg")
        {
            QuantidadeAtual = 20,
            ValorUnitario = 10m
        };

        _estoqueItemRepositoryMock
            .Setup(r => r.GetAllAsync())
            .ReturnsAsync(new[] { item1, item2 });

        // Act
        var resultado = await _estoqueService.CalcularValorTotalEstoqueAsync();

        // Assert
        // (10 * 50) + (20 * 10) = 500 + 200 = 700
        resultado.Should().Be(700m);
    }
}
