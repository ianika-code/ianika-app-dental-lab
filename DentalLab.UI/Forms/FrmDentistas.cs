using DentalLab.Application.DTOs;
using DentalLab.Application.Services;

namespace DentalLab.UI.Forms;

public partial class FrmDentistas : Form
{
    private readonly DentistaService _dentistaService;

    public FrmDentistas(DentistaService dentistaService)
    {
        InitializeComponent();
        _dentistaService = dentistaService;
    }

    private async void FrmDentistas_Load(object sender, EventArgs e)
    {
        await CarregarDados();
    }

    private async Task CarregarDados()
    {
        try
        {
            var lista = await _dentistaService.GetTodosAsync();

            dgvDentistas.DataSource = lista;

            dgvDentistas.Columns["Id"].Visible = false;
        }
        catch (Exception ex)
        {
            MessageBox.Show(
                ex.Message,
                "Erro",
                MessageBoxButtons.OK,
                MessageBoxIcon.Error);
        }
    }

    private async void btnAtualizar_Click(object sender, EventArgs e)
    {
        await CarregarDados();
    }

    private void btnNovo_Click(object sender, EventArgs e)
    {
        MessageBox.Show("Implementar cadastro.");
    }

    private void btnEditar_Click(object sender, EventArgs e)
    {
        if (dgvDentistas.CurrentRow == null)
            return;

        var id = (Guid)dgvDentistas.CurrentRow.Cells["Id"].Value;

        MessageBox.Show($"Editar: {id}");
    }

    private async void btnExcluir_Click(object sender, EventArgs e)
    {
        if (dgvDentistas.CurrentRow == null)
            return;

        var id = (Guid)dgvDentistas.CurrentRow.Cells["Id"].Value;

        if (MessageBox.Show(
                "Confirma exclusão?",
                "Excluir",
                MessageBoxButtons.YesNo,
                MessageBoxIcon.Question)
            == DialogResult.Yes)
        {
            await _dentistaService.DeletarAsync(id);

            await CarregarDados();
        }
    }
}