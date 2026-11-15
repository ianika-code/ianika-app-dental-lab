namespace DentalLab.UI.Forms;

using DentalLab.UI.Context;
using Microsoft.Extensions.DependencyInjection;

/// <summary>
/// Formulário Principal (Dashboard)
/// </summary>
public partial class MainForm : Form
{
    private readonly IServiceProvider _serviceProvider;

    public MainForm(IServiceProvider serviceProvider)
    {
        InitializeComponent();
        _serviceProvider = serviceProvider;
    }

    private void MainForm_Load(object sender, EventArgs e)
    {
        this.Text = "DentalLab - Sistema de Administração de Laboratório Odontológico";
        this.StartPosition = FormStartPosition.CenterScreen;
        this.WindowState = FormWindowState.Maximized;

        if (UserContext.IsLoggedIn)
        {
            var usuario = UserContext.GetUsuarioLogado();
            this.Text += $" - Usuário: {usuario?.Nome}";
        }
    }

    private void sairToolStripMenuItem_Click(object sender, EventArgs e)
    {
        UserContext.ClearSession();
        this.Close();
    }

    private void menuDentistas_Click(object sender, EventArgs e)
    {
        MessageBox.Show("Clique chegou aqui!");

        var frm = _serviceProvider.GetRequiredService<FrmDentistas>();

        frm.ShowDialog();
    }
}
