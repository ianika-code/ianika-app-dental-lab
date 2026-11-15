namespace DentalLab.Application.DTOs;

/// <summary>
/// DTO para login do usuário
/// </summary>
public class LoginRequestDto
{
    public string Email { get; set; } = string.Empty;
    public string Senha { get; set; } = string.Empty;
}

/// <summary>
/// DTO para resposta de login
/// </summary>
public class LoginResponseDto
{
    public Guid Id { get; set; }
    public string Nome { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public bool Ativo { get; set; }
}
