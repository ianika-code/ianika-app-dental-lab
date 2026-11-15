namespace DentalLab.Application.Extensions;

using DentalLab.Application.Services;
using DentalLab.Application.Validations;
using DentalLab.Domain.Entities;
using FluentValidation;
using Microsoft.Extensions.DependencyInjection;

/// <summary>
/// Extensão para registrar serviços da camada Application
/// </summary>
public static class ApplicationServiceCollectionExtensions
{
    /// <summary>
    /// Adiciona os serviços da camada Application ao container de DI
    /// </summary>
    public static IServiceCollection AddApplicationServices(this IServiceCollection services)
    {
        // Registrar validadores
        services.AddScoped<IValidator<Usuario>, UsuarioValidator>();
        services.AddScoped<IValidator<Dentista>, DentistaValidator>();
        services.AddScoped<IValidator<Paciente>, PacienteValidator>();
        services.AddScoped<IValidator<Pedido>, PedidoValidator>();
        services.AddScoped<IValidator<EstoqueItem>, EstoqueItemValidator>();

        // Registrar serviços
        services.AddScoped<LoginService>();
        services.AddScoped<DentistaService>();
        services.AddScoped<PacienteService>();
        services.AddScoped<PedidoService>();
        services.AddScoped<EstoqueService>();
        services.AddScoped<EventoAgendaService>();
        services.AddScoped<EmailService>();

        return services;
    }
}
