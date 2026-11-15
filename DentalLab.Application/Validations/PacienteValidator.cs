namespace DentalLab.Application.Validations;

using DentalLab.Domain.Entities;
using FluentValidation;

/// <summary>
/// Validador para a entidade Paciente
/// </summary>
public class PacienteValidator : AbstractValidator<Paciente>
{
    public PacienteValidator()
    {
        RuleFor(p => p.Nome)
            .NotEmpty().WithMessage("Nome é obrigatório")
            .MaximumLength(150).WithMessage("Nome não pode exceder 150 caracteres");

        RuleFor(p => p.CPF)
            .NotEmpty().WithMessage("CPF é obrigatório")
            .MaximumLength(14).WithMessage("CPF inválido")
            .Matches(@"^\d{3}\.\d{3}\.\d{3}-\d{2}$|^\d{11}$").WithMessage("CPF deve estar no formato 000.000.000-00 ou 00000000000");

        RuleFor(p => p.Telefone)
            .NotEmpty().WithMessage("Telefone é obrigatório")
            .MaximumLength(20).WithMessage("Telefone não pode exceder 20 caracteres");

        RuleFor(p => p.DataNascimento)
            .NotEmpty().WithMessage("Data de nascimento é obrigatória")
            .LessThan(DateTime.Today).WithMessage("Data de nascimento não pode ser no futuro");

        RuleFor(p => p.DentistaResponsavelId)
            .NotEqual(Guid.Empty).WithMessage("Dentista responsável é obrigatório");
    }
}
