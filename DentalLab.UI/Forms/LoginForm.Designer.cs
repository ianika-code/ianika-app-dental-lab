namespace DentalLab.UI.Forms;

partial class LoginForm
{
    private System.ComponentModel.IContainer components = null;

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
        var labelEmail = new Label();
        var labelSenha = new Label();
        txtEmail = new TextBox();
        txtSenha = new TextBox();
        btnEntrar = new Button();
        btnSair = new Button();

        // Label Email
        labelEmail.AutoSize = true;
        labelEmail.Location = new Point(20, 30);
        labelEmail.Name = "labelEmail";
        labelEmail.Size = new Size(40, 15);
        labelEmail.TabIndex = 0;
        labelEmail.Text = "Email:";

        // TextBox Email
        txtEmail = new TextBox();
        txtEmail.Location = new Point(20, 50);
        txtEmail.Name = "txtEmail";
        txtEmail.Size = new Size(260, 23);
        txtEmail.TabIndex = 1;

        // Label Senha
        labelSenha.AutoSize = true;
        labelSenha.Location = new Point(20, 90);
        labelSenha.Name = "labelSenha";
        labelSenha.Size = new Size(50, 15);
        labelSenha.TabIndex = 2;
        labelSenha.Text = "Senha:";

        // TextBox Senha
        txtSenha = new TextBox();
        txtSenha.Location = new Point(20, 110);
        txtSenha.Name = "txtSenha";
        txtSenha.PasswordChar = '*';
        txtSenha.Size = new Size(260, 23);
        txtSenha.TabIndex = 3;

        // Button Entrar
        btnEntrar = new Button();
        btnEntrar.Location = new Point(20, 160);
        btnEntrar.Name = "btnEntrar";
        btnEntrar.Size = new Size(120, 35);
        btnEntrar.TabIndex = 4;
        btnEntrar.Text = "Entrar";
        btnEntrar.UseVisualStyleBackColor = true;
        btnEntrar.Click += btnEntrar_Click;

        // Button Sair
        btnSair = new Button();
        btnSair.Location = new Point(160, 160);
        btnSair.Name = "btnSair";
        btnSair.Size = new Size(120, 35);
        btnSair.TabIndex = 5;
        btnSair.Text = "Sair";
        btnSair.UseVisualStyleBackColor = true;
        btnSair.Click += btnSair_Click;

        // LoginForm
        this.AutoScaleDimensions = new SizeF(7F, 15F);
        this.AutoScaleMode = AutoScaleMode.Font;
        this.ClientSize = new Size(300, 220);
        this.Controls.Add(labelEmail);
        this.Controls.Add(txtEmail);
        this.Controls.Add(labelSenha);
        this.Controls.Add(txtSenha);
        this.Controls.Add(btnEntrar);
        this.Controls.Add(btnSair);
        this.Name = "LoginForm";
        this.Text = "Login";
        this.Load += LoginForm_Load;
        this.FormClosing += LoginForm_FormClosing;
        this.ResumeLayout(false);
        this.PerformLayout();
    }

    private TextBox txtEmail;
    private TextBox txtSenha;
    private Button btnEntrar;
    private Button btnSair;
}
