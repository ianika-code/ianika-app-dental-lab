namespace DentalLab.Infrastructure.Data;

using BCrypt.Net;
using DentalLab.Domain.Entities;
using Microsoft.EntityFrameworkCore;

/// <summary>
/// Classe responsável pelo seed inicial do banco
/// </summary>
public static class DentalLabContextSeeder
{
    /// <summary>
    /// Cria banco e usuário administrador inicial
    /// </summary>
    public static async Task SeedAsync(DentalLabContext context)
    {
        try
        {
            await context.Database.EnsureCreatedAsync();

            if (!await context.Usuarios.AnyAsync())
            {
                var adminUser = new Usuario
                {
                    Id = Guid.NewGuid(),
                    Nome = "Administrador",
                    Email = "admin@dentallab.local",
                    SenhaHash = BCrypt.HashPassword("Admin@123"),
                    Ativo = true,
                    CreatedAt = DateTime.UtcNow,
                    IsDeleted = false
                };

                context.Usuarios.Add(adminUser);

                await context.SaveChangesAsync();
            }
        }
        catch (Exception ex)
        {
            throw new InvalidOperationException(
                "Erro ao fazer seeding do banco de dados",
                ex);
        }
    }
}