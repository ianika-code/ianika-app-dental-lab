namespace DentalLab.UI.Forms;

using DentalLab.UI.Context;

/// <summary>
/// Formulário Principal (Dashboard)
/// </summary>
public partial class MainForm : Form
{
    public MainForm()
    {
        InitializeComponent();
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
}
