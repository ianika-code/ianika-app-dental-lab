namespace DentalLab.UI.Forms;

using DentalLab.Application.DTOs;
using DentalLab.Application.Services;
using DentalLab.UI.Context;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.DependencyInjection;
using WinFormsApplication = System.Windows.Forms.Application;

/// <summary>
/// Formulário de Login
/// </summary>
public partial class LoginForm : Form
{
    private readonly LoginService _loginService;
    private readonly ILogger<LoginForm> _logger;
    private readonly IServiceProvider _serviceProvider;

    public LoginForm(
        LoginService loginService,
        ILogger<LoginForm> logger,
        IServiceProvider serviceProvider)
    {
        InitializeComponent();

        _loginService = loginService;
        _logger = logger;
        _serviceProvider = serviceProvider;
    }

    private async void LoginForm_Load(object sender, EventArgs e)
    {
        this.Text = "DentalLab - Login";
        this.StartPosition = FormStartPosition.CenterScreen;
        this.FormBorderStyle = FormBorderStyle.FixedDialog;
        this.MaximizeBox = false;
        this.MinimizeBox = false;
    }

    private async void btnEntrar_Click(object sender, EventArgs e)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(txtEmail.Text))
            {
                MessageBox.Show("Email é obrigatório", "Validação", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtSenha.Text))
            {
                MessageBox.Show("Senha é obrigatória", "Validação", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            var request = new LoginRequestDto
            {
                Email = txtEmail.Text.Trim(),
                Senha = txtSenha.Text
            };

            var resultado = await _loginService.LoginAsync(request);

            if (resultado != null)
            {
                UserContext.SetUsuarioLogado(resultado);
                _logger.LogInformation($"Usuário {resultado.Email} logado com sucesso");

                // Abrir formulário principal
                var mainForm = _serviceProvider.GetRequiredService<MainForm>();

                this.Hide();
                mainForm.ShowDialog();
                this.Close();
            }
            else
            {
                MessageBox.Show("Email ou senha incorretos", "Erro de Login", MessageBoxButtons.OK, MessageBoxIcon.Error);
                _logger.LogWarning($"Tentativa de login falhada para: {txtEmail.Text}");
            }
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Erro ao realizar login: {ex.Message}", "Erro", MessageBoxButtons.OK, MessageBoxIcon.Error);
            _logger.LogError(ex, "Erro ao realizar login");
        }
    }

    private void btnSair_Click(object sender, EventArgs e)
    {
        WinFormsApplication.Exit();
    }

    private void LoginForm_FormClosing(object sender, FormClosingEventArgs e)
    {
        // Se fechar sem estar logado, sair da aplicação
        if (!UserContext.IsLoggedIn)
        {
            System.Windows.Forms.Application.Exit();
        }
    }
}
