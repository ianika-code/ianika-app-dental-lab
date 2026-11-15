namespace DentalLab.UI.Context;

using DentalLab.Application.DTOs;

/// <summary>
/// Contexto de sessão do usuário logado
/// </summary>
public static class UserContext
{
    private static LoginResponseDto? _usuarioLogado;

    /// <summary>
    /// Obtém o usuário logado na sessão
    /// </summary>
    public static LoginResponseDto? GetUsuarioLogado()
    {
        return _usuarioLogado;
    }

    /// <summary>
    /// Define o usuário logado
    /// </summary>
    public static void SetUsuarioLogado(LoginResponseDto usuario)
    {
        _usuarioLogado = usuario;
    }

    /// <summary>
    /// Limpa a sessão do usuário
    /// </summary>
    public static void ClearSession()
    {
        _usuarioLogado = null;
    }

    /// <summary>
    /// Verifica se há usuário logado
    /// </summary>
    public static bool IsLoggedIn => _usuarioLogado != null;
}
