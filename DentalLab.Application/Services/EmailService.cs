namespace DentalLab.Application.Services;

using MailKit.Net.Smtp;
using MailKit.Security;
using MimeKit;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

/// <summary>
/// Serviço para envio de e-mails
/// </summary>
public class EmailService
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<EmailService> _logger;

    public EmailService(IConfiguration configuration, ILogger<EmailService> logger)
    {
        _configuration = configuration;
        _logger = logger;
    }

    /// <summary>
    /// Envia um e-mail simples
    /// </summary>
    public async Task<bool> EnviarEmailAsync(string destinatario, string assunto, string corpo, bool ehHtml = false)
    {
        try
        {
            var host = _configuration["Email:Host"];
            var port = int.Parse(_configuration["Email:Port"] ?? "587");
            var usuario = _configuration["Email:User"];
            var senha = _configuration["Email:Password"];

            // Validar configurações
            if (string.IsNullOrWhiteSpace(host) || string.IsNullOrWhiteSpace(usuario) || string.IsNullOrWhiteSpace(senha))
            {
                _logger.LogWarning("Configurações de email não foram informadas");
                return false;
            }

            var message = new MimeMessage();
            message.From.Add(new MailboxAddress("DentalLab", usuario));
            message.To.Add(new MailboxAddress(string.Empty, destinatario));
            message.Subject = assunto;

            message.Body = ehHtml
                ? new BodyBuilder { HtmlBody = corpo }.ToMessageBody()
                : new TextPart("plain") { Text = corpo };

            using (var client = new SmtpClient())
            {
                await client.ConnectAsync(host, port, SecureSocketOptions.StartTls);
                await client.AuthenticateAsync(usuario, senha);
                await client.SendAsync(message);
                await client.DisconnectAsync(true);
            }

            _logger.LogInformation($"E-mail enviado com sucesso para: {destinatario}");
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao enviar e-mail para: {destinatario}");
            return false;
        }
    }

    /// <summary>
    /// Envia notificação de conclusão de pedido para dentista
    /// </summary>
    public async Task<bool> EnviarNotificacaoConclusaoPedidoAsync(string emailDentista, string nomeDentista, string numeroPedido, string nomePaciente)
    {
        try
        {
            var assunto = $"Prótese Concluída - Pedido {numeroPedido}";
            var corpo = $@"
Prezado(a) Dr(a). {nomeDentista},

Informamos que a prótese do paciente {nomePaciente} (Pedido {numeroPedido}) foi concluída e está pronta para entrega.

Por favor, entre em contato para agendar o horário de retirada.

Atenciosamente,
DentalLab";

            return await EnviarEmailAsync(emailDentista, assunto, corpo);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao enviar notificação de conclusão de pedido para: {emailDentista}");
            return false;
        }
    }

    /// <summary>
    /// Envia e-mail de recuperação de senha
    /// </summary>
    public async Task<bool> EnviarEmailRecuperacaoSenhaAsync(string emailUsuario, string nomeUsuario, string token, string urlAplicacao)
    {
        try
        {
            var assunto = "Recuperação de Senha - DentalLab";
            var linkRecuperacao = $"{urlAplicacao}?token={token}";

            var corpo = $@"
Prezado(a) {nomeUsuario},

Você solicitou a recuperação de sua senha no sistema DentalLab.

Para resetar sua senha, clique no link abaixo:
{linkRecuperacao}

Este link expira em 1 hora.

Se você não solicitou esta recuperação, ignore este e-mail.

Atenciosamente,
DentalLab";

            return await EnviarEmailAsync(emailUsuario, assunto, corpo);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao enviar e-mail de recuperação de senha para: {emailUsuario}");
            return false;
        }
    }

    /// <summary>
    /// Envia solicitação de compra para fornecedor
    /// </summary>
    public async Task<bool> EnviarSolicitacaoCompraAsync(
        string emailFornecedor,
        string nomeFornecedor,
        string nomeMaterial,
        int quantidade,
        string unidadeMedida)
    {
        try
        {
            var assunto = $"Solicitação de Compra - {nomeMaterial}";
            var corpo = $@"
Prezado(a) {nomeFornecedor},

Solicitamos a compra do seguinte material:

Material: {nomeMaterial}
Quantidade: {quantidade} {unidadeMedida}

Por favor, confirme a disponibilidade e apresente proposta de preço.

Atenciosamente,
DentalLab";

            return await EnviarEmailAsync(emailFornecedor, assunto, corpo);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao enviar solicitação de compra para: {emailFornecedor}");
            return false;
        }
    }

    /// <summary>
    /// Envia alerta de estoque baixo
    /// </summary>
    public async Task<bool> EnviarAlertaEstoqueAsync(string emailAdministrador, string nomeMaterial, int quantidadeAtual, int quantidadeMinima)
    {
        try
        {
            var assunto = $"ALERTA: Estoque Baixo - {nomeMaterial}";
            var corpo = $@"
ALERTA DE ESTOQUE BAIXO

Material: {nomeMaterial}
Quantidade Atual: {quantidadeAtual}
Quantidade Mínima: {quantidadeMinima}

Por favor, proceda com a reposição do material.

Atenciosamente,
DentalLab";

            return await EnviarEmailAsync(emailAdministrador, assunto, corpo);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Erro ao enviar alerta de estoque para: {emailAdministrador}");
            return false;
        }
    }
}
