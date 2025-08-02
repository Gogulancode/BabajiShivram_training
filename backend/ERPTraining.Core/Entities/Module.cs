namespace ERPTraining.Core.Entities;

public class Module
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Icon { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty;
    public string Color { get; set; } = string.Empty;
    public string EstimatedTime { get; set; } = string.Empty;
    public string Difficulty { get; set; } = string.Empty;
    public string[] Prerequisites { get; set; } = Array.Empty<string>();
    public string[] LearningObjectives { get; set; } = Array.Empty<string>();
    public bool IsActive { get; set; } = true;
    public int Order { get; set; }
    public string? ErpModuleId { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    // Navigation properties
    public virtual ICollection<Section> Sections { get; set; } = new List<Section>();
    public virtual ICollection<Assessment> Assessments { get; set; } = new List<Assessment>();
    public virtual ICollection<UserModuleProgress> UserProgress { get; set; } = new List<UserModuleProgress>();
    public virtual ICollection<RoleModuleSection> RoleModuleSections { get; set; } = new List<RoleModuleSection>();
}