namespace DentalLab.UI.Forms;

partial class MainForm
{
    private System.ComponentModel.IContainer? components = null;

    protected override void Dispose(bool disposing)
    {
        if (disposing && (components != null))
        {
            components.Dispose();
        }

        base.Dispose(disposing);
    }

    private void InitializeComponent()
    {
        components = new System.ComponentModel.Container();

        var menuStrip = new MenuStrip();

        var cadastrosToolStripMenuItem = new ToolStripMenuItem();
        var operacoesToolStripMenuItem = new ToolStripMenuItem();
        var relatoriosToolStripMenuItem = new ToolStripMenuItem();
        var configuracoesToolStripMenuItem = new ToolStripMenuItem();

        // Itens do menu Configurações
        var alterarSenhaMenuItem = new ToolStripMenuItem();
        var sairMenuItem = new ToolStripMenuItem();

        SuspendLayout();

        // Menu Principal
        menuStrip.Items.AddRange(new ToolStripItem[]
        {
            cadastrosToolStripMenuItem,
            operacoesToolStripMenuItem,
            relatoriosToolStripMenuItem,
            configuracoesToolStripMenuItem
        });

        menuStrip.Location = new Point(0, 0);
        menuStrip.Name = "menuStrip";
        menuStrip.Size = new Size(1024, 24);

        // Cadastros
        cadastrosToolStripMenuItem.Text = "Cadastros";
        cadastrosToolStripMenuItem.DropDownItems.AddRange(new ToolStripItem[]
        {
            new ToolStripMenuItem("Dentistas"),
            new ToolStripMenuItem("Pacientes")
        });

        // Operações
        operacoesToolStripMenuItem.Text = "Operações";
        operacoesToolStripMenuItem.DropDownItems.AddRange(new ToolStripItem[]
        {
            new ToolStripMenuItem("Pedidos"),
            new ToolStripMenuItem("Estoque"),
            new ToolStripMenuItem("Agenda")
        });

        // Relatórios
        relatoriosToolStripMenuItem.Text = "Relatórios";
        relatoriosToolStripMenuItem.DropDownItems.AddRange(new ToolStripItem[]
        {
            new ToolStripMenuItem("Dentistas"),
            new ToolStripMenuItem("Pacientes"),
            new ToolStripMenuItem("Pedidos"),
            new ToolStripMenuItem("Estoque")
        });

        // Configurações
        configuracoesToolStripMenuItem.Text = "Configurações";

        alterarSenhaMenuItem.Text = "Alterar Senha";

        sairMenuItem.Text = "Sair";
        sairMenuItem.Click += sairToolStripMenuItem_Click;

        configuracoesToolStripMenuItem.DropDownItems.AddRange(new ToolStripItem[]
        {
            alterarSenhaMenuItem,
            new ToolStripSeparator(),
            sairMenuItem
        });

        // MainForm
        AutoScaleDimensions = new SizeF(7F, 15F);
        AutoScaleMode = AutoScaleMode.Font;
        ClientSize = new Size(1024, 768);

        Controls.Add(menuStrip);

        MainMenuStrip = menuStrip;
        Name = "MainForm";
        StartPosition = FormStartPosition.CenterScreen;
        Text = "DentalLab";

        Load += MainForm_Load;

        ResumeLayout(false);
        PerformLayout();
    }
}