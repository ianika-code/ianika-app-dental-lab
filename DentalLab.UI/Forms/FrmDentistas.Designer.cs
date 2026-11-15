namespace DentalLab.UI.Forms;

partial class FrmDentistas
{
    private DataGridView dgvDentistas;
    private Button btnNovo;
    private Button btnEditar;
    private Button btnExcluir;
    private Button btnAtualizar;

    private void InitializeComponent()
    {
        dgvDentistas = new DataGridView();
        btnNovo = new Button();
        btnEditar = new Button();
        btnExcluir = new Button();
        btnAtualizar = new Button();

        SuspendLayout();

        dgvDentistas.Anchor =
            AnchorStyles.Top |
            AnchorStyles.Bottom |
            AnchorStyles.Left |
            AnchorStyles.Right;

        dgvDentistas.Location = new Point(12, 50);
        dgvDentistas.Size = new Size(860, 450);

        btnNovo.Text = "Novo";
        btnNovo.Location = new Point(12, 12);
        btnNovo.Click += btnNovo_Click;

        btnEditar.Text = "Editar";
        btnEditar.Location = new Point(100, 12);
        btnEditar.Click += btnEditar_Click;

        btnExcluir.Text = "Excluir";
        btnExcluir.Location = new Point(188, 12);
        btnExcluir.Click += btnExcluir_Click;

        btnAtualizar.Text = "Atualizar";
        btnAtualizar.Location = new Point(276, 12);
        btnAtualizar.Click += btnAtualizar_Click;

        Controls.Add(dgvDentistas);
        Controls.Add(btnNovo);
        Controls.Add(btnEditar);
        Controls.Add(btnExcluir);
        Controls.Add(btnAtualizar);

        Text = "Cadastro de Dentistas";
        WindowState = FormWindowState.Maximized;
        Load += FrmDentistas_Load;

        ResumeLayout(false);
    }
}