namespace DentalLab.Tests.Services;

using DentalLab.Application.DTOs;
using DentalLab.Application.Services;
using DentalLab.Domain.Entities;
using DentalLab.Domain.Interfaces;
using FluentAssertions;
using Moq;
using Microsoft.Extensions.Logging;
using Xunit;

public class LoginServiceTests
{
    private readonly Mock<IUsuarioRepository> _usuarioRepositoryMock;
    private readonly Mock<ILogger<LoginService>> _loggerMock;
    private readonly LoginService _loginService;

    public LoginServiceTests()
    {
        _usuarioRepositoryMock = new Mock<IUsuarioRepository>();
        _loggerMock = new Mock<ILogger<LoginService>>();
        _loginService = new LoginService(_usuarioRepositoryMock.Object, _loggerMock.Object);
    }

    [Fact]
    public async Task LoginAsync_ComCredenciaisValidas_DeveRetornarUsuario()
    {
        // Arrange
        var usuario = new Usuario("Administrador", "admin@dentallab.local")
        {
            Id = Guid.NewGuid(),
            SenhaHash = BCrypt.Net.BCrypt.EnhancedHashPassword("Admin@123"),
            Ativo = true
        };

        _usuarioRepositoryMock
            .Setup(r => r.GetByEmailAsync("admin@dentallab.local"))
            .ReturnsAsync(usuario);

        var request = new LoginRequestDto
        {
            Email = "admin@dentallab.local",
            Senha = "Admin@123"
        };

        // Act
        var resultado = await _loginService.LoginAsync(request);

        // Assert
        resultado.Should().NotBeNull();
        resultado!.Email.Should().Be("admin@dentallab.local");
        resultado.Nome.Should().Be("Administrador");
    }

    [Fact]
    public async Task LoginAsync_ComSenhaInvalida_DeveRetornarNull()
    {
        // Arrange
        var usuario = new Usuario("Administrador", "admin@dentallab.local")
        {
            Id = Guid.NewGuid(),
            SenhaHash = BCrypt.Net.BCrypt.EnhancedHashPassword("Admin@123"),
            Ativo = true
        };

        _usuarioRepositoryMock
            .Setup(r => r.GetByEmailAsync("admin@dentallab.local"))
            .ReturnsAsync(usuario);

        var request = new LoginRequestDto
        {
            Email = "admin@dentallab.local",
            Senha = "SenhaErrada"
        };

        // Act
        var resultado = await _loginService.LoginAsync(request);

        // Assert
        resultado.Should().BeNull();
    }

    [Fact]
    public async Task LoginAsync_ComEmailInvalido_DeveRetornarNull()
    {
        // Arrange
        _usuarioRepositoryMock
            .Setup(r => r.GetByEmailAsync(It.IsAny<string>()))
            .ReturnsAsync((Usuario?)null);

        var request = new LoginRequestDto
        {
            Email = "invalido@dentallab.local",
            Senha = "Admin@123"
        };

        // Act
        var resultado = await _loginService.LoginAsync(request);

        // Assert
        resultado.Should().BeNull();
    }

    [Fact]
    public async Task AlterarSenhaAsync_ComSenhaAtualCorreta_DeveAlterarSenha()
    {
        // Arrange
        var usuarioId = Guid.NewGuid();
        var senhaAtual = "Admin@123";
        var novaSenha = "NovaS3nh@";

        var usuario = new Usuario("Administrador", "admin@dentallab.local")
        {
            Id = usuarioId,
            SenhaHash = BCrypt.Net.BCrypt.EnhancedHashPassword(senhaAtual),
            Ativo = true
        };

        _usuarioRepositoryMock
            .Setup(r => r.GetByIdAsync(usuarioId))
            .ReturnsAsync(usuario);

        _usuarioRepositoryMock
            .Setup(r => r.UpdateAsync(It.IsAny<Usuario>()))
            .Returns(Task.CompletedTask);

        _usuarioRepositoryMock
            .Setup(r => r.SaveAsync())
            .Returns(Task.CompletedTask);

        // Act
        var resultado = await _loginService.AlterarSenhaAsync(usuarioId, senhaAtual, novaSenha);

        // Assert
        resultado.Should().BeTrue();
        _usuarioRepositoryMock.Verify(r => r.UpdateAsync(It.IsAny<Usuario>()), Times.Once);
        _usuarioRepositoryMock.Verify(r => r.SaveAsync(), Times.Once);
    }

    [Fact]
    public async Task AlterarSenhaAsync_ComSenhaAtualIncorreta_DeveFalhar()
    {
        // Arrange
        var usuarioId = Guid.NewGuid();
        var usuario = new Usuario("Administrador", "admin@dentallab.local")
        {
            Id = usuarioId,
            SenhaHash = BCrypt.Net.BCrypt.EnhancedHashPassword("Admin@123"),
            Ativo = true
        };

        _usuarioRepositoryMock
            .Setup(r => r.GetByIdAsync(usuarioId))
            .ReturnsAsync(usuario);

        // Act
        var resultado = await _loginService.AlterarSenhaAsync(usuarioId, "SenhaErrada", "Nova@123");

        // Assert
        resultado.Should().BeFalse();
    }

    [Fact]
    public async Task SolicitarRecuperacaoSenhaAsync_ComEmailValido_DeveGerarToken()
    {
        // Arrange
        var usuario = new Usuario("Administrador", "admin@dentallab.local")
        {
            Id = Guid.NewGuid(),
            SenhaHash = BCrypt.Net.BCrypt.EnhancedHashPassword("Admin@123"),
            Ativo = true
        };

        _usuarioRepositoryMock
            .Setup(r => r.GetByEmailAsync("admin@dentallab.local"))
            .ReturnsAsync(usuario);

        _usuarioRepositoryMock
            .Setup(r => r.UpdateAsync(It.IsAny<Usuario>()))
            .Returns(Task.CompletedTask);

        _usuarioRepositoryMock
            .Setup(r => r.SaveAsync())
            .Returns(Task.CompletedTask);

        // Act
        var resultado = await _loginService.SolicitarRecuperacaoSenhaAsync("admin@dentallab.local");

        // Assert
        resultado.Should().BeTrue();
        _usuarioRepositoryMock.Verify(r => r.UpdateAsync(It.IsAny<Usuario>()), Times.Once);
        _usuarioRepositoryMock.Verify(r => r.SaveAsync(), Times.Once);
    }
}
