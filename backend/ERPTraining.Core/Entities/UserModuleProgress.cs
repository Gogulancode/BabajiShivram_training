namespace ERPTraining.Core.Entities;

public class UserModuleProgress
{
    public int Id { get; set; }
    public string UserId { get; set; } = string.Empty;
    public int ModuleId { get; set; }
    public int CompletionPercentage { get; set; }
    public bool IsCompleted { get; set; }
    public DateTime? CompletedAt { get; set; }
    public DateTime StartedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    // Navigation properties
    public virtual User User { get; set; } = null!;
    public virtual Module Module { get; set; } = null!;
}