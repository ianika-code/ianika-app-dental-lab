namespace DentalLab.Infrastructure.Data;

using DentalLab.Domain.Entities;
using Microsoft.EntityFrameworkCore;

/// <summary>
/// DbContext para o banco de dados SQLite do DentalLab
/// Gerencia todas as entidades e configurações do EF Core
/// </summary>
public class DentalLabContext : DbContext
{
    public DentalLabContext(DbContextOptions<DentalLabContext> options) : base(options)
    {
    }

    // DbSets para todas as entidades
    public DbSet<Usuario> Usuarios { get; set; } = null!;
    public DbSet<Dentista> Dentistas { get; set; } = null!;
    public DbSet<Paciente> Pacientes { get; set; } = null!;
    public DbSet<Pedido> Pedidos { get; set; } = null!;
    public DbSet<EstoqueItem> EstoqueItems { get; set; } = null!;
    public DbSet<MovimentacaoEstoque> MovimentacoesEstoque { get; set; } = null!;
    public DbSet<EventoAgenda> EventosAgenda { get; set; } = null!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Configuração de Usuario
        modelBuilder.Entity<Usuario>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Nome).IsRequired().HasMaxLength(150);
            entity.Property(e => e.Email).IsRequired().HasMaxLength(150);
            entity.Property(e => e.SenhaHash).IsRequired();
            entity.Property(e => e.Ativo).IsRequired();
            
            entity.HasIndex(e => e.Email).IsUnique();
            
            // Soft delete global filter
            entity.HasQueryFilter(e => !e.IsDeleted);
        });

        // Configuração de Dentista
        modelBuilder.Entity<Dentista>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Nome).IsRequired().HasMaxLength(150);
            entity.Property(e => e.CRO).IsRequired().HasMaxLength(20);
            entity.Property(e => e.Telefone).IsRequired().HasMaxLength(20);
            entity.Property(e => e.Email).IsRequired().HasMaxLength(150);
            entity.Property(e => e.Endereco).IsRequired().HasMaxLength(300);
            
            entity.HasIndex(e => e.CRO).IsUnique();
            
            // Soft delete global filter
            entity.HasQueryFilter(e => !e.IsDeleted);
        });

        // Configuração de Paciente
        modelBuilder.Entity<Paciente>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Nome).IsRequired().HasMaxLength(150);
            entity.Property(e => e.CPF).IsRequired().HasMaxLength(14);
            entity.Property(e => e.Telefone).IsRequired().HasMaxLength(20);
            
            entity.HasIndex(e => e.CPF).IsUnique();
            
            entity.HasOne(e => e.DentistaResponsavel)
                .WithMany(d => d.Pacientes)
                .HasForeignKey(e => e.DentistaResponsavelId)
                .OnDelete(DeleteBehavior.Restrict);
            
            // Soft delete global filter
            entity.HasQueryFilter(e => !e.IsDeleted);
        });

        // Configuração de Pedido
        modelBuilder.Entity<Pedido>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.NumeroPedido).IsRequired().HasMaxLength(50);
            entity.Property(e => e.TipoProtese).IsRequired().HasMaxLength(100);
            entity.Property(e => e.Valor).HasPrecision(10, 2);
            entity.Property(e => e.Status).IsRequired();
            
            entity.HasIndex(e => e.NumeroPedido).IsUnique();
            
            entity.HasOne(e => e.Paciente)
                .WithMany(p => p.Pedidos)
                .HasForeignKey(e => e.PacienteId)
                .OnDelete(DeleteBehavior.Restrict);
            
            entity.HasOne(e => e.Dentista)
                .WithMany(d => d.Pedidos)
                .HasForeignKey(e => e.DentistaId)
                .OnDelete(DeleteBehavior.Restrict);
            
            // Soft delete global filter
            entity.HasQueryFilter(e => !e.IsDeleted);
        });

        // Configuração de EstoqueItem
        modelBuilder.Entity<EstoqueItem>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Nome).IsRequired().HasMaxLength(150);
            entity.Property(e => e.UnidadeMedida).IsRequired().HasMaxLength(20);
            entity.Property(e => e.ValorUnitario).HasPrecision(10, 2);
            entity.Property(e => e.QuantidadeAtual).IsRequired();
            entity.Property(e => e.QuantidadeMinima).IsRequired();
            
            // Soft delete global filter
            entity.HasQueryFilter(e => !e.IsDeleted);
        });

        // Configuração de MovimentacaoEstoque
        modelBuilder.Entity<MovimentacaoEstoque>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Motivo).IsRequired().HasMaxLength(200);
            entity.Property(e => e.Quantidade).IsRequired();
            
            entity.HasOne(e => e.EstoqueItem)
                .WithMany(ei => ei.Movimentacoes)
                .HasForeignKey(e => e.EstoqueItemId)
                .OnDelete(DeleteBehavior.Restrict);
            
            // Soft delete global filter
            entity.HasQueryFilter(e => !e.IsDeleted);
        });

        // Configuração de EventoAgenda
        modelBuilder.Entity<EventoAgenda>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Titulo).IsRequired().HasMaxLength(200);
            entity.Property(e => e.Tipo).IsRequired();
            
            entity.HasOne(e => e.Pedido)
                .WithMany()
                .HasForeignKey(e => e.PedidoId)
                .OnDelete(DeleteBehavior.SetNull);
            
            entity.HasOne(e => e.Dentista)
                .WithMany()
                .HasForeignKey(e => e.DentistaId)
                .OnDelete(DeleteBehavior.SetNull);
            
            // Soft delete global filter
            entity.HasQueryFilter(e => !e.IsDeleted);
        });
    }
}
