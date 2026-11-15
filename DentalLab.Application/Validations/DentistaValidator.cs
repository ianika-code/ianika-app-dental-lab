namespace DentalLab.Application.Validations;

using DentalLab.Domain.Entities;
using FluentValidation;

/// <summary>
/// Validador para a entidade Dentista
/// </summary>
public class DentistaValidator : AbstractValidator<Dentista>
{
    public DentistaValidator()
    {
        RuleFor(d => d.Nome)
            .NotEmpty().WithMessage("Nome é obrigatório")
            .MaximumLength(150).WithMessage("Nome não pode exceder 150 caracteres");

        RuleFor(d => d.CRO)
            .NotEmpty().WithMessage("CRO é obrigatório")
            .MaximumLength(20).WithMessage("CRO não pode exceder 20 caracteres")
            .Matches(@"^\d+$").WithMessage("CRO deve conter apenas números");

        RuleFor(d => d.Telefone)
            .NotEmpty().WithMessage("Telefone é obrigatório")
            .MaximumLength(20).WithMessage("Telefone não pode exceder 20 caracteres");

        RuleFor(d => d.Email)
            .NotEmpty().WithMessage("Email é obrigatório")
            .EmailAddress().WithMessage("Email inválido")
            .MaximumLength(150).WithMessage("Email não pode exceder 150 caracteres");

        RuleFor(d => d.Endereco)
            .NotEmpty().WithMessage("Endereço é obrigatório")
            .MaximumLength(300).WithMessage("Endereço não pode exceder 300 caracteres");
    }
}
