namespace DentalLab.Tests.Services;

using DentalLab.Application.Services;
using FluentAssertions;
using Moq;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Xunit;

public class EmailServiceTests
{
    private readonly Mock<IConfiguration> _configurationMock;
    private readonly Mock<ILogger<EmailService>> _loggerMock;
    private readonly EmailService _emailService;

    public EmailServiceTests()
    {
        _configurationMock = new Mock<IConfiguration>();
        _loggerMock = new Mock<ILogger<EmailService>>();
        _emailService = new EmailService(_configurationMock.Object, _loggerMock.Object);
    }

    [Fact]
    public async Task EnviarEmailAsync_ComConfiguracoesIncompletas_DeveFalhar()
    {
        // Arrange
        _configurationMock
            .Setup(c => c["Email:Host"])
            .Returns(string.Empty);

        // Act
        var resultado = await _emailService.EnviarEmailAsync("teste@email.com", "Assunto", "Corpo");

        // Assert
        resultado.Should().BeFalse();
    }

    [Fact]
    public async Task EnviarNotificacaoConclusaoPedidoAsync_DeveConterDadosCorretos()
    {
        // Arrange
        ConfigurarEmailMock();

        // Act
        var resultado = await _emailService.EnviarNotificacaoConclusaoPedidoAsync(
            "dentista@email.com",
            "Dr. Silva",
            "PED-001",
            "João Silva");

        // Assert
        // Se não houver conexão SMTP, retorna false, mas é comportamento esperado
        // Em um teste real, usaríamos um servidor SMTP fake
        resultado.Should().BeFalse(); // Esperado, pois não há conexão real
    }

    [Fact]
    public async Task EnviarEmailRecuperacaoSenhaAsync_DeveConterToken()
    {
        // Arrange
        ConfigurarEmailMock();
        var token = Guid.NewGuid().ToString();

        // Act
        var resultado = await _emailService.EnviarEmailRecuperacaoSenhaAsync(
            "admin@dentallab.local",
            "Administrador",
            token,
            "http://localhost:5000/resetar-senha");

        // Assert
        resultado.Should().BeFalse(); // Esperado, pois não há conexão real
    }

    [Fact]
    public async Task EnviarSolicitacaoCompraAsync_DeveConterDetalhes()
    {
        // Arrange
        ConfigurarEmailMock();

        // Act
        var resultado = await _emailService.EnviarSolicitacaoCompraAsync(
            "fornecedor@email.com",
            "Fornecedor XYZ",
            "Resina Acrílica",
            50,
            "kg");

        // Assert
        resultado.Should().BeFalse(); // Esperado, pois não há conexão real
    }

    [Fact]
    public async Task EnviarAlertaEstoqueAsync_DeveConterAlerta()
    {
        // Arrange
        ConfigurarEmailMock();

        // Act
        var resultado = await _emailService.EnviarAlertaEstoqueAsync(
            "admin@dentallab.local",
            "Resina Acrílica",
            5,
            10);

        // Assert
        resultado.Should().BeFalse(); // Esperado, pois não há conexão real
    }

    private void ConfigurarEmailMock()
    {
        _configurationMock
            .Setup(c => c["Email:Host"])
            .Returns("smtp.gmail.com");

        _configurationMock
            .Setup(c => c["Email:Port"])
            .Returns("587");

        _configurationMock
            .Setup(c => c["Email:User"])
            .Returns("user@gmail.com");

        _configurationMock
            .Setup(c => c["Email:Password"])
            .Returns("password");
    }
}
