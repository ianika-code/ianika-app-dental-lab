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

public class PedidoServiceTests
{
    private readonly Mock<IPedidoRepository> _pedidoRepositoryMock;
    private readonly Mock<IPacienteRepository> _pacienteRepositoryMock;
    private readonly Mock<IDentistaRepository> _dentistaRepositoryMock;
    private readonly Mock<IValidator<Pedido>> _validatorMock;
    private readonly Mock<ILogger<PedidoService>> _loggerMock;
    private readonly PedidoService _pedidoService;

    public PedidoServiceTests()
    {
        _pedidoRepositoryMock = new Mock<IPedidoRepository>();
        _pacienteRepositoryMock = new Mock<IPacienteRepository>();
        _dentistaRepositoryMock = new Mock<IDentistaRepository>();
        _validatorMock = new Mock<IValidator<Pedido>>();
        _loggerMock = new Mock<ILogger<PedidoService>>();

        _pedidoService = new PedidoService(
            _pedidoRepositoryMock.Object,
            _pacienteRepositoryMock.Object,
            _dentistaRepositoryMock.Object,
            _validatorMock.Object,
            _loggerMock.Object);
    }

    [Fact]
    public async Task CriarAsync_ComDadosValidos_DeveCriarPedido()
    {
        // Arrange
        var pacienteId = Guid.NewGuid();
        var dentistaId = Guid.NewGuid();

        var paciente = new Paciente("João Silva", "123.456.789-00", "11999999999", DateTime.Now.AddYears(-30), dentistaId);
        var dentista = new Dentista("Dr. Silva", "12345", "11988888888", "silva@email.com", "Rua A, 123");

        _pacienteRepositoryMock
            .Setup(r => r.GetByIdAsync(pacienteId))
            .ReturnsAsync(paciente);

        _dentistaRepositoryMock
            .Setup(r => r.GetByIdAsync(dentistaId))
            .ReturnsAsync(dentista);

        _pedidoRepositoryMock
            .Setup(r => r.NumeroPedidoExistsAsync(It.IsAny<string>(), null))
            .ReturnsAsync(false);

        _validatorMock
            .Setup(v => v.ValidateAsync(It.IsAny<Pedido>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(new FluentValidation.Results.ValidationResult());

        _pedidoRepositoryMock
            .Setup(r => r.AddAsync(It.IsAny<Pedido>()))
            .Returns(Task.CompletedTask);

        _pedidoRepositoryMock
            .Setup(r => r.SaveAsync())
            .Returns(Task.CompletedTask);

        var dto = new CreateUpdatePedidoDto
        {
            NumeroPedido = "PED-001",
            PacienteId = pacienteId,
            DentistaId = dentistaId,
            TipoProtese = "Coroa",
            DataPrevista = DateTime.Now.AddDays(7),
            Valor = 500m
        };

        // Act
        var resultado = await _pedidoService.CriarAsync(dto);

        // Assert
        resultado.Should().NotBeNull();
        resultado.NumeroPedido.Should().Be("PED-001");
        resultado.Status.Should().Be(StatusPedido.Recebido);
        _pedidoRepositoryMock.Verify(r => r.AddAsync(It.IsAny<Pedido>()), Times.Once);
        _pedidoRepositoryMock.Verify(r => r.SaveAsync(), Times.Once);
    }

    [Fact]
    public async Task CriarAsync_ComPacienteInexistente_DeveLancarExcecao()
    {
        // Arrange
        _pacienteRepositoryMock
            .Setup(r => r.GetByIdAsync(It.IsAny<Guid>()))
            .ReturnsAsync((Paciente?)null);

        var dto = new CreateUpdatePedidoDto
        {
            NumeroPedido = "PED-001",
            PacienteId = Guid.NewGuid(),
            DentistaId = Guid.NewGuid(),
            TipoProtese = "Coroa",
            DataPrevista = DateTime.Now.AddDays(7),
            Valor = 500m
        };

        // Act & Assert
        await Assert.ThrowsAsync<InvalidOperationException>(() => _pedidoService.CriarAsync(dto));
    }

    [Fact]
    public async Task AtualizarStatusAsync_ComStatusValido_DeveAtualizarStatus()
    {
        // Arrange
        var pedidoId = Guid.NewGuid();
        var pedido = new Pedido("PED-001", Guid.NewGuid(), Guid.NewGuid(), "Coroa", DateTime.Now.AddDays(7), 500m);
        pedido.Id = pedidoId;

        _pedidoRepositoryMock
            .Setup(r => r.GetByIdAsync(pedidoId))
            .ReturnsAsync(pedido);

        _pedidoRepositoryMock
            .Setup(r => r.UpdateAsync(It.IsAny<Pedido>()))
            .Returns(Task.CompletedTask);

        _pedidoRepositoryMock
            .Setup(r => r.SaveAsync())
            .Returns(Task.CompletedTask);

        // Act
        var resultado = await _pedidoService.AtualizarStatusAsync(pedidoId, StatusPedido.EmProducao);

        // Assert
        resultado.Should().NotBeNull();
        resultado.Status.Should().Be(StatusPedido.EmProducao);
        _pedidoRepositoryMock.Verify(r => r.UpdateAsync(It.IsAny<Pedido>()), Times.Once);
    }

    [Fact]
    public async Task AtualizarStatusAsync_ParaFinalizado_DeveRegistrarDataEntrega()
    {
        // Arrange
        var pedidoId = Guid.NewGuid();
        var pedido = new Pedido("PED-001", Guid.NewGuid(), Guid.NewGuid(), "Coroa", DateTime.Now.AddDays(7), 500m);
        pedido.Id = pedidoId;

        _pedidoRepositoryMock
            .Setup(r => r.GetByIdAsync(pedidoId))
            .ReturnsAsync(pedido);

        _pedidoRepositoryMock
            .Setup(r => r.UpdateAsync(It.IsAny<Pedido>()))
            .Returns(Task.CompletedTask);

        _pedidoRepositoryMock
            .Setup(r => r.SaveAsync())
            .Returns(Task.CompletedTask);

        // Act
        var resultado = await _pedidoService.AtualizarStatusAsync(pedidoId, StatusPedido.Finalizado);

        // Assert
        resultado.Should().NotBeNull();
        resultado.Status.Should().Be(StatusPedido.Finalizado);
        resultado.DataEntrega.Should().NotBeNull();
    }

    [Fact]
    public async Task GetPorStatusAsync_DeveRetornarPedidosComStatusCorreto()
    {
        // Arrange
        var pedido1 = new Pedido("PED-001", Guid.NewGuid(), Guid.NewGuid(), "Coroa", DateTime.Now.AddDays(7), 500m);
        var pedido2 = new Pedido("PED-002", Guid.NewGuid(), Guid.NewGuid(), "Ponte", DateTime.Now.AddDays(7), 800m);

        _pedidoRepositoryMock
            .Setup(r => r.GetByStatusAsync(StatusPedido.Recebido))
            .ReturnsAsync(new[] { pedido1, pedido2 });

        // Act
        var resultado = await _pedidoService.GetPorStatusAsync(StatusPedido.Recebido);

        // Assert
        resultado.Should().HaveCount(2);
        resultado.All(p => p.Status == StatusPedido.Recebido).Should().BeTrue();
    }
}
