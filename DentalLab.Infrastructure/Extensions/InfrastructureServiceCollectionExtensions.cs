namespace DentalLab.Infrastructure.Extensions;

using DentalLab.Domain.Interfaces;
using DentalLab.Infrastructure.Data;
using DentalLab.Infrastructure.Repositories;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

/// <summary>
/// Extensão para registrar serviços de infraestrutura
/// </summary>
public static class InfrastructureServiceCollectionExtensions
{
    /// <summary>
    /// Adiciona os serviços de infraestrutura ao container de DI
    /// </summary>
    public static IServiceCollection AddInfrastructureServices(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        // Configurar banco de dados SQLite
        var connectionString = configuration.GetConnectionString("DefaultConnection") 
            ?? "Data Source=DentalLab.db";
        
        services.AddDbContext<DentalLabContext>(options =>
            options.UseSqlite(connectionString)
        );

        // Registrar repositórios
        services.AddScoped<IUsuarioRepository, UsuarioRepository>();
        services.AddScoped<IDentistaRepository, DentistaRepository>();
        services.AddScoped<IPacienteRepository, PacienteRepository>();
        services.AddScoped<IPedidoRepository, PedidoRepository>();
        services.AddScoped<IEstoqueItemRepository, EstoqueItemRepository>();
        services.AddScoped<IMovimentacaoEstoqueRepository, MovimentacaoEstoqueRepository>();
        services.AddScoped<IEventoAgendaRepository, EventoAgendaRepository>();

        return services;
    }
}
