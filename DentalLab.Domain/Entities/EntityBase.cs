namespace DentalLab.Domain.Entities;

/// <summary>
/// Classe base abstrata para todas as entidades do sistema
/// Implementa auditoria básica com soft delete
/// </summary>
public abstract class EntityBase
{
    /// <summary>
    /// Identificador único da entidade
    /// </summary>
    public Guid Id { get; set; }

    /// <summary>
    /// Data e hora de criação do registro
    /// </summary>
    public DateTime CreatedAt { get; set; }

    /// <summary>
    /// Data e hora da última atualização do registro
    /// </summary>
    public DateTime? UpdatedAt { get; set; }

    /// <summary>
    /// Indica se o registro foi deletado (soft delete)
    /// </summary>
    public bool IsDeleted { get; set; }

    protected EntityBase()
    {
        Id = Guid.NewGuid();
        CreatedAt = DateTime.UtcNow;
        IsDeleted = false;
    }
}
