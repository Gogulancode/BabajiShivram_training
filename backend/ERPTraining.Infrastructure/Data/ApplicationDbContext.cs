using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using ERPTraining.Core.Entities;
using System.Text.Json;

namespace ERPTraining.Infrastructure.Data;

public class ApplicationDbContext : IdentityDbContext<User>
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
    {
    }

    public DbSet<Module> Modules { get; set; }
    public DbSet<Section> Sections { get; set; }
    public DbSet<Lesson> Lessons { get; set; }
    public DbSet<Assessment> Assessments { get; set; }
    public DbSet<Question> Questions { get; set; }
    public DbSet<AssessmentAttempt> AssessmentAttempts { get; set; }
    public DbSet<UserAnswer> UserAnswers { get; set; }
    public DbSet<UserModuleProgress> UserModuleProgress { get; set; }
    public DbSet<UserLessonProgress> UserLessonProgress { get; set; }
    public DbSet<UploadedContent> UploadedContents { get; set; }
    public DbSet<RoleModuleAccess> RoleModuleAccess { get; set; }

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        // Configure array properties to be stored as JSON
        builder.Entity<Module>()
            .Property(e => e.Prerequisites)
            .HasConversion(
                v => JsonSerializer.Serialize(v, (JsonSerializerOptions)null!),
                v => JsonSerializer.Deserialize<string[]>(v, (JsonSerializerOptions)null!) ?? Array.Empty<string>());

        builder.Entity<Module>()
            .Property(e => e.LearningObjectives)
            .HasConversion(
                v => JsonSerializer.Serialize(v, (JsonSerializerOptions)null!),
                v => JsonSerializer.Deserialize<string[]>(v, (JsonSerializerOptions)null!) ?? Array.Empty<string>());

        builder.Entity<Lesson>()
            .Property(e => e.InteractiveSteps)
            .HasConversion(
                v => JsonSerializer.Serialize(v, (JsonSerializerOptions)null!),
                v => JsonSerializer.Deserialize<string[]>(v, (JsonSerializerOptions)null!) ?? Array.Empty<string>());

        builder.Entity<Question>()
            .Property(e => e.Options)
            .HasConversion(
                v => JsonSerializer.Serialize(v, (JsonSerializerOptions)null!),
                v => JsonSerializer.Deserialize<string[]>(v, (JsonSerializerOptions)null!) ?? Array.Empty<string>());

        builder.Entity<Question>()
            .Property(e => e.CorrectAnswers)
            .HasConversion(
                v => JsonSerializer.Serialize(v, (JsonSerializerOptions)null!),
                v => JsonSerializer.Deserialize<string[]>(v, (JsonSerializerOptions)null!) ?? Array.Empty<string>());

        builder.Entity<UserAnswer>()
            .Property(e => e.SelectedAnswers)
            .HasConversion(
                v => JsonSerializer.Serialize(v, (JsonSerializerOptions)null!),
                v => JsonSerializer.Deserialize<string[]>(v, (JsonSerializerOptions)null!) ?? Array.Empty<string>());

        builder.Entity<UploadedContent>()
            .Property(e => e.Tags)
            .HasConversion(
                v => JsonSerializer.Serialize(v, (JsonSerializerOptions)null!),
                v => JsonSerializer.Deserialize<string[]>(v, (JsonSerializerOptions)null!) ?? Array.Empty<string>());

        builder.Entity<UploadedContent>()
            .Property(e => e.AccessRoles)
            .HasConversion(
                v => JsonSerializer.Serialize(v, (JsonSerializerOptions)null!),
                v => JsonSerializer.Deserialize<string[]>(v, (JsonSerializerOptions)null!) ?? Array.Empty<string>());

        // Configure relationships
        builder.Entity<Section>()
            .HasOne(s => s.Module)
            .WithMany(m => m.Sections)
            .HasForeignKey(s => s.ModuleId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Entity<Lesson>()
            .HasOne(l => l.Section)
            .WithMany(s => s.Lessons)
            .HasForeignKey(l => l.SectionId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Entity<Assessment>()
            .HasOne(a => a.Module)
            .WithMany(m => m.Assessments)
            .HasForeignKey(a => a.ModuleId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Entity<Assessment>()
            .HasOne(a => a.Section)
            .WithMany(s => s.Assessments)
            .HasForeignKey(a => a.SectionId)
            .OnDelete(DeleteBehavior.SetNull);

        builder.Entity<Question>()
            .HasOne(q => q.Assessment)
            .WithMany(a => a.Questions)
            .HasForeignKey(q => q.AssessmentId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Entity<AssessmentAttempt>()
            .HasOne(aa => aa.User)
            .WithMany(u => u.AssessmentAttempts)
            .HasForeignKey(aa => aa.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Entity<AssessmentAttempt>()
            .HasOne(aa => aa.Assessment)
            .WithMany(a => a.Attempts)
            .HasForeignKey(aa => aa.AssessmentId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Entity<UserAnswer>()
            .HasOne(ua => ua.AssessmentAttempt)
            .WithMany(aa => aa.UserAnswers)
            .HasForeignKey(ua => ua.AssessmentAttemptId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Entity<UserAnswer>()
            .HasOne(ua => ua.Question)
            .WithMany(q => q.UserAnswers)
            .HasForeignKey(ua => ua.QuestionId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.Entity<UserModuleProgress>()
            .HasOne(ump => ump.User)
            .WithMany(u => u.ModuleProgress)
            .HasForeignKey(ump => ump.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Entity<UserModuleProgress>()
            .HasOne(ump => ump.Module)
            .WithMany(m => m.UserProgress)
            .HasForeignKey(ump => ump.ModuleId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Entity<UserLessonProgress>()
            .HasOne(ulp => ulp.User)
            .WithMany()
            .HasForeignKey(ulp => ulp.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Entity<UserLessonProgress>()
            .HasOne(ulp => ulp.Lesson)
            .WithMany(l => l.UserProgress)
            .HasForeignKey(ulp => ulp.LessonId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Entity<UploadedContent>()
            .HasOne(uc => uc.Module)
            .WithMany()
            .HasForeignKey(uc => uc.ModuleId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Entity<UploadedContent>()
            .HasOne(uc => uc.Section)
            .WithMany()
            .HasForeignKey(uc => uc.SectionId)
            .OnDelete(DeleteBehavior.SetNull);

        builder.Entity<UploadedContent>()
            .HasOne(uc => uc.UploadedBy)
            .WithMany(u => u.UploadedContents)
            .HasForeignKey(uc => uc.UploadedById)
            .OnDelete(DeleteBehavior.Restrict);

        // Configure RoleModuleAccess relationships
        builder.Entity<RoleModuleAccess>()
            .HasOne(rma => rma.Module)
            .WithMany()
            .HasForeignKey(rma => rma.ModuleId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Entity<RoleModuleAccess>()
            .HasOne(rma => rma.Section)
            .WithMany()
            .HasForeignKey(rma => rma.SectionId)
            .OnDelete(DeleteBehavior.Cascade);

        // Configure indexes
        builder.Entity<Module>()
            .HasIndex(m => m.Order);

        builder.Entity<Section>()
            .HasIndex(s => new { s.ModuleId, s.Order });

        builder.Entity<Lesson>()
            .HasIndex(l => new { l.SectionId, l.Order });

        builder.Entity<Question>()
            .HasIndex(q => new { q.AssessmentId, q.Order });

        builder.Entity<UserModuleProgress>()
            .HasIndex(ump => new { ump.UserId, ump.ModuleId })
            .IsUnique();

        builder.Entity<UserLessonProgress>()
            .HasIndex(ulp => new { ulp.UserId, ulp.LessonId })
            .IsUnique();

        builder.Entity<RoleModuleAccess>()
            .HasIndex(rma => new { rma.RoleId, rma.ModuleId, rma.SectionId });

        builder.Entity<RoleModuleAccess>()
            .HasIndex(rma => rma.ErpRoleId);

        builder.Entity<RoleModuleAccess>()
            .HasIndex(rma => rma.ErpModuleId);
    }
}