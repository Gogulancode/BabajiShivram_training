namespace ERPTraining.Core.Entities;

public class Section
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public int ModuleId { get; set; }
    public int Order { get; set; }
    public bool IsActive { get; set; } = true;
    public string? ErpSectionId { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    // Navigation properties
    public virtual Module Module { get; set; } = null!;
    public virtual ICollection<Lesson> Lessons { get; set; } = new List<Lesson>();
    public virtual ICollection<Assessment> Assessments { get; set; } = new List<Assessment>();
    public virtual ICollection<RoleModuleSection> RoleModuleSections { get; set; } = new List<RoleModuleSection>();
}