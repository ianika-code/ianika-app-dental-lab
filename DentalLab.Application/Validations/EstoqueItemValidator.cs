namespace DentalLab.Application.Validations;

using DentalLab.Domain.Entities;
using FluentValidation;

/// <summary>
/// Validador para a entidade EstoqueItem
/// </summary>
public class EstoqueItemValidator : AbstractValidator<EstoqueItem>
{
    public EstoqueItemValidator()
    {
        RuleFor(e => e.Nome)
            .NotEmpty().WithMessage("Nome é obrigatório")
            .MaximumLength(150).WithMessage("Nome não pode exceder 150 caracteres");

        RuleFor(e => e.Categoria)
            .IsInEnum().WithMessage("Categoria inválida");

        RuleFor(e => e.UnidadeMedida)
            .NotEmpty().WithMessage("Unidade de medida é obrigatória")
            .MaximumLength(20).WithMessage("Unidade de medida não pode exceder 20 caracteres");

        RuleFor(e => e.QuantidadeMinima)
            .GreaterThanOrEqualTo(0).WithMessage("Quantidade mínima não pode ser negativa");

        RuleFor(e => e.ValorUnitario)
            .GreaterThanOrEqualTo(0).WithMessage("Valor unitário não pode ser negativo");
    }
}
