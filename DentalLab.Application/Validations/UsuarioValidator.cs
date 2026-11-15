namespace DentalLab.Application.Validations;

using DentalLab.Domain.Entities;
using FluentValidation;

/// <summary>
/// Validador para a entidade Usuario
/// </summary>
public class UsuarioValidator : AbstractValidator<Usuario>
{
    public UsuarioValidator()
    {
        RuleFor(u => u.Nome)
            .NotEmpty().WithMessage("Nome é obrigatório")
            .MaximumLength(150).WithMessage("Nome não pode exceder 150 caracteres");

        RuleFor(u => u.Email)
            .NotEmpty().WithMessage("Email é obrigatório")
            .EmailAddress().WithMessage("Email inválido")
            .MaximumLength(150).WithMessage("Email não pode exceder 150 caracteres");

        RuleFor(u => u.SenhaHash)
            .NotEmpty().WithMessage("Senha é obrigatória");
    }
}
