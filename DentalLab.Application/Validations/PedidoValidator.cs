namespace DentalLab.Application.Validations;

using DentalLab.Domain.Entities;
using FluentValidation;

/// <summary>
/// Validador para a entidade Pedido
/// </summary>
public class PedidoValidator : AbstractValidator<Pedido>
{
    public PedidoValidator()
    {
        RuleFor(p => p.NumeroPedido)
            .NotEmpty().WithMessage("Número do pedido é obrigatório")
            .MaximumLength(50).WithMessage("Número do pedido não pode exceder 50 caracteres");

        RuleFor(p => p.PacienteId)
            .NotEqual(Guid.Empty).WithMessage("Paciente é obrigatório");

        RuleFor(p => p.DentistaId)
            .NotEqual(Guid.Empty).WithMessage("Dentista é obrigatório");

        RuleFor(p => p.TipoProtese)
            .NotEmpty().WithMessage("Tipo de prótese é obrigatório")
            .MaximumLength(100).WithMessage("Tipo de prótese não pode exceder 100 caracteres");

        RuleFor(p => p.DataPrevista)
            .GreaterThan(p => p.DataPedido).WithMessage("Data prevista deve ser maior que a data do pedido");

        RuleFor(p => p.Valor)
            .GreaterThan(0).WithMessage("Valor deve ser maior que zero");
    }
}
