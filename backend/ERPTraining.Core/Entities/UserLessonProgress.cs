namespace ERPTraining.Core.Entities;

public class UserLessonProgress
{
    public int Id { get; set; }
    public string UserId { get; set; } = string.Empty;
    public int LessonId { get; set; }
    public bool IsCompleted { get; set; }
    public DateTime? CompletedAt { get; set; }
    public DateTime StartedAt { get; set; } = DateTime.UtcNow;
    public int TimeSpent { get; set; } // in seconds

    // Navigation properties
    public virtual User User { get; set; } = null!;
    public virtual Lesson Lesson { get; set; } = null!;
}