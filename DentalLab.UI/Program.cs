using DentalLab.Application.Extensions;
using DentalLab.Infrastructure.Data;
using DentalLab.Infrastructure.Extensions;
using DentalLab.UI.Forms;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Serilog;
using WinFormsApplication = System.Windows.Forms.Application;
using Microsoft.EntityFrameworkCore;

namespace DentalLab.UI;

static class Program
{
    /// <summary>
    ///  The main entry point for the application.
    /// </summary>
    [STAThread]
    static void Main()
    {
        // Configurar ambiente
        ApplicationConfiguration.Initialize();
        // Criar configuration
        var configuration = new ConfigurationBuilder()
            .SetBasePath(AppContext.BaseDirectory)
            .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
            .Build();

        // Configurar Serilog
        Log.Logger = new LoggerConfiguration()
            .MinimumLevel.Information()
            .WriteTo.File(
                "logs/dentallab-.txt",
                rollingInterval: RollingInterval.Day,
                outputTemplate: "[{Timestamp:yyyy-MM-dd HH:mm:ss}] [{Level:u3}] {Message:lj}{NewLine}{Exception}")
            .CreateLogger();

        try
        {
            Log.Information("Iniciando aplicação DentalLab");

            // Construir container de DI
            var serviceProvider = new ServiceCollection()
                .AddLogging(config =>
                {
                    config.ClearProviders();
                    config.AddSerilog();
                })
                .AddInfrastructureServices(configuration)
                .AddApplicationServices()

                .AddTransient<LoginForm>()
                .AddTransient<MainForm>()

                .BuildServiceProvider();

            // Aplicar migrations e seed
            using (var scope = serviceProvider.CreateScope())
            {
                try
                {
                    var context = scope.ServiceProvider.GetRequiredService<DentalLabContext>();

                    DentalLabContextSeeder.SeedAsync(context).Wait();
                }
                catch (Exception ex)
                {
                    MessageBox.Show(
                        ex.ToString(),
                        "ERRO DETALHADO",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Error);

                    throw;
                }
            }

            // Abrir formulário de login
            var loginForm = serviceProvider.GetRequiredService<LoginForm>();
            System.Windows.Forms.Application.Run(loginForm);

            Log.Information("Aplicação encerrada normalmente");
        }
        catch (Exception ex)
        {
            MessageBox.Show(
                ex.ToString(),
                "ERRO COMPLETO",
                MessageBoxButtons.OK,
                MessageBoxIcon.Error);

            Log.Fatal(ex, "Erro fatal na aplicação");

            throw;
        }
        finally
        {
            Log.CloseAndFlush();
        }
    }
}
