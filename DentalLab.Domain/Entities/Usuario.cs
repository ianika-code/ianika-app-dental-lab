namespace DentalLab.Domain.Entities;

/// <summary>
/// Entidade de Usuário do sistema
/// Armazena informações de autenticação e perfil
/// </summary>
public class Usuario : EntityBase
{
    /// <summary>
    /// Nome completo do usuário
    /// </summary>
    public string Nome { get; set; } = string.Empty;

    /// <summary>
    /// Email único do usuário
    /// </summary>
    public string Email { get; set; } = string.Empty;

    /// <summary>
    /// Hash da senha criptografado com BCrypt
    /// </summary>
    public string SenhaHash { get; set; } = string.Empty;

    /// <summary>
    /// Indica se o usuário está ativo
    /// </summary>
    public bool Ativo { get; set; }

    /// <summary>
    /// Token para recuperação de senha
    /// </summary>
    public string? RecuperacaoToken { get; set; }

    /// <summary>
    /// Data de expiração do token de recuperação
    /// </summary>
    public DateTime? RecuperacaoTokenExpiracao { get; set; }

    /// <summary>
    /// Data do último login
    /// </summary>
    public DateTime? UltimoLogin { get; set; }

    public Usuario() { }

    public Usuario(string nome, string email)
    {
        Nome = nome;
        Email = email;
        Ativo = true;
    }
}
