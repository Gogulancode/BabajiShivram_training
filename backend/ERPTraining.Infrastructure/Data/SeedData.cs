using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using ERPTraining.Core.Entities;

namespace ERPTraining.Infrastructure.Data;

public static class SeedData
{
    public static async Task Initialize(
        ApplicationDbContext context,
        UserManager<User> userManager,
        RoleManager<IdentityRole> roleManager)
    {
        // Ensure database is created
        await context.Database.EnsureCreatedAsync();

        // Seed roles
        await SeedRoles(roleManager);

        // Seed users
        await SeedUsers(userManager);

        // Seed modules and content
        await SeedModules(context);
    }

    private static async Task SeedRoles(RoleManager<IdentityRole> roleManager)
    {
        string[] roles = { "Admin", "QA", "User", "Manager", "Supervisor" };

        foreach (var role in roles)
        {
            if (!await roleManager.RoleExistsAsync(role))
            {
                await roleManager.CreateAsync(new IdentityRole(role));
            }
        }
    }

    private static async Task SeedUsers(UserManager<User> userManager)
    {
        // Admin user
        if (await userManager.FindByNameAsync("admin") == null)
        {
            var adminUser = new User
            {
                UserName = "admin",
                Email = "admin@erptraining.com",
                FirstName = "System",
                LastName = "Administrator",
                Department = "IT",
                JoinDate = DateTime.UtcNow,
                IsActive = true
            };

            var result = await userManager.CreateAsync(adminUser, "Admin123!");
            if (result.Succeeded)
            {
                await userManager.AddToRoleAsync(adminUser, "Admin");
            }
        }

        // QA user
        if (await userManager.FindByNameAsync("qa") == null)
        {
            var qaUser = new User
            {
                UserName = "qa",
                Email = "qa@erptraining.com",
                FirstName = "Quality",
                LastName = "Assurance",
                Department = "Training",
                JoinDate = DateTime.UtcNow,
                IsActive = true
            };

            var result = await userManager.CreateAsync(qaUser, "QA123!");
            if (result.Succeeded)
            {
                await userManager.AddToRoleAsync(qaUser, "QA");
            }
        }

        // Regular user
        if (await userManager.FindByNameAsync("john.doe") == null)
        {
            var regularUser = new User
            {
                UserName = "john.doe",
                Email = "john.doe@erptraining.com",
                FirstName = "John",
                LastName = "Doe",
                Department = "Operations",
                JoinDate = DateTime.UtcNow,
                IsActive = true
            };

            var result = await userManager.CreateAsync(regularUser, "User123!");
            if (result.Succeeded)
            {
                await userManager.AddToRoleAsync(regularUser, "User");
            }
        }
    }

    private static async Task SeedModules(ApplicationDbContext context)
    {
        if (await context.Modules.AnyAsync())
            return; // Already seeded

        var modules = new List<Module>
        {
            new Module
            {
                Title = "Import Management",
                Description = "Learn the fundamentals of import management, documentation, and compliance procedures.",
                Icon = "Package",
                Category = "Trade Operations",
                Color = "blue",
                EstimatedTime = "2-3 hours",
                Difficulty = "Beginner",
                Prerequisites = Array.Empty<string>(),
                LearningObjectives = new[] 
                {
                    "Understand import documentation requirements",
                    "Learn compliance procedures",
                    "Master import cost calculations"
                },
                IsActive = true,
                Order = 1,
                Sections = new List<Section>
                {
                    new Section
                    {
                        Title = "Import Fundamentals",
                        Description = "Basic concepts and terminology",
                        Order = 1,
                        IsActive = true,
                        Lessons = new List<Lesson>
                        {
                            new Lesson
                            {
                                Title = "Introduction to Import Management",
                                Description = "Overview of import processes and key stakeholders",
                                Type = LessonType.Video,
                                Duration = "15 min",
                                Order = 1,
                                IsActive = true,
                                VideoUrl = "https://www.youtube.com/embed/example",
                                HasAssessment = false
                            },
                            new Lesson
                            {
                                Title = "Import Terminology",
                                Description = "Key terms and definitions in import management",
                                Type = LessonType.Document,
                                Duration = "10 min",
                                Order = 2,
                                IsActive = true,
                                DocumentContent = "<h3>Import Terminology</h3><p>Key terms and definitions...</p>",
                                HasAssessment = false
                            }
                        }
                    },
                    new Section
                    {
                        Title = "Documentation & Compliance",
                        Description = "Required documents and regulatory compliance",
                        Order = 2,
                        IsActive = true,
                        Lessons = new List<Lesson>
                        {
                            new Lesson
                            {
                                Title = "Import Documentation Requirements",
                                Description = "Essential documents for import operations",
                                Type = LessonType.Document,
                                Duration = "25 min",
                                Order = 1,
                                IsActive = true,
                                DocumentContent = "<h3>Required Documents</h3><p>Essential import documents...</p>",
                                HasAssessment = false
                            }
                        }
                    }
                }
            },
            new Module
            {
                Title = "Export Operations",
                Description = "Master export procedures, documentation, and international shipping requirements.",
                Icon = "Truck",
                Category = "Trade Operations",
                Color = "green",
                EstimatedTime = "2-3 hours",
                Difficulty = "Intermediate",
                Prerequisites = new[] { "1" },
                LearningObjectives = new[]
                {
                    "Understand export documentation",
                    "Learn shipping procedures",
                    "Master export regulations"
                },
                IsActive = true,
                Order = 2,
                Sections = new List<Section>
                {
                    new Section
                    {
                        Title = "Export Basics",
                        Description = "Fundamental export concepts",
                        Order = 1,
                        IsActive = true,
                        Lessons = new List<Lesson>
                        {
                            new Lesson
                            {
                                Title = "Export Fundamentals",
                                Description = "Basic export procedures and requirements",
                                Type = LessonType.Video,
                                Duration = "20 min",
                                Order = 1,
                                IsActive = true,
                                VideoUrl = "https://www.youtube.com/embed/export-example",
                                HasAssessment = false
                            }
                        }
                    }
                }
            }
        };

        context.Modules.AddRange(modules);
        await context.SaveChangesAsync();

        // Seed sample assessments
        var importModule = await context.Modules.FirstAsync(m => m.Title == "Import Management");
        var importSection = importModule.Sections.First();

        var assessment = new Assessment
        {
            Title = "Import Management Fundamentals Quiz",
            Description = "Test your understanding of basic import concepts and procedures",
            ModuleId = importModule.Id,
            SectionId = importSection.Id,
            PassingScore = 70,
            TimeLimit = 30,
            MaxAttempts = 3,
            IsActive = true,
            IsRequired = true,
            TriggerType = AssessmentTriggerType.SectionCompletion,
            Questions = new List<Question>
            {
                new Question
                {
                    Type = QuestionType.MultipleChoice,
                    QuestionText = "What is the primary purpose of a Bill of Lading in import operations?",
                    Options = new[]
                    {
                        "To calculate customs duties",
                        "To serve as a receipt and contract for transportation",
                        "To determine product quality",
                        "To set the selling price"
                    },
                    CorrectAnswers = new[] { "To serve as a receipt and contract for transportation" },
                    Explanation = "A Bill of Lading serves as a receipt for goods shipped, a contract between the shipper and carrier, and a document of title.",
                    Points = 5,
                    Order = 1
                },
                new Question
                {
                    Type = QuestionType.TrueFalse,
                    QuestionText = "All imported goods must go through customs inspection regardless of their value.",
                    CorrectAnswers = new[] { "false" },
                    Explanation = "Not all goods require physical inspection. Many are cleared through automated systems based on risk assessment.",
                    Points = 3,
                    Order = 2
                }
            }
        };

        context.Assessments.Add(assessment);
        await context.SaveChangesAsync();
    }
}