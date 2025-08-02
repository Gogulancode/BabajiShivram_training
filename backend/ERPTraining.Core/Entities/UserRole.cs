namespace ERPTraining.Core.Entities;

public class UserRole
{
    public int Id { get; set; }
    public string UserId { get; set; } = string.Empty;
    public int RoleId { get; set; }
    public DateTime AssignedAt { get; set; } = DateTime.UtcNow;
    public bool IsActive { get; set; } = true;

    // Navigation properties
    public virtual User User { get; set; } = null!;
    public virtual Role Role { get; set; } = null!;
}
