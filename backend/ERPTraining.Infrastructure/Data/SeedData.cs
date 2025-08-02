using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using ERPTraining.Core.Entities;
using System.Text.Json;

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
        
        // Seed sections
        await SeedSections(context);
    }

    private static async Task SeedRoles(RoleManager<IdentityRole> roleManager)
    {
        // First, remove existing roles except Admin and QA
        var existingRoles = roleManager.Roles.ToList();
        foreach (var role in existingRoles)
        {
            if (role.Name != "Admin" && role.Name != "QA")
            {
                await roleManager.DeleteAsync(role);
            }
        }

        // Define roles to be created/maintained (role names from your JSON)
        var roleNames = new[]
        {
            "Admin", "QA", "HOD", "IGM", "Checklist Preparation", "KAM Assistant-Air",
            "KAM Assistant-Sea", "KAM-Sea", "KAM-Air", "Checklist Approval", "Delivery Order",
            "Operations-Sea", "Operations-Air", "Transport", "Post Clearance Advice-Sea",
            "Billing Scrutiny", "Billing", "Dispatch", "Billing HOD", "Branch KAM",
            "Post Clearance Advice-Branches", "Operations-Sea-Shed", "Warehousing", "Freight User",
            "Feedback", "CFS", "Reports", "ITADMIN", "Super Admin", "Documentation", "Custom HOD",
            "Express User", "Sea Export", "Quotation", "Air Export", "Sea Import", "Air Import",
            "Consolidation Export", "Consolidation Import", "Delete Approved", "EDIT APPROVED ROLE",
            "Credit Vendor", "Cheque Printing", "Daily Collection and Charges", "Payment Audit",
            "TDS Computation", "Office Manager", "Expense Scrutiny", "Expense HOD",
            "Transport Operations", "Vessel Management", "Transport_Accounts", "CC_Reports",
            "CC_Operations", "CC_Collection", "CC_Upload", "View", "CC_Collection_Report",
            "Billing Manager", "Post Clearance Advice-Air", "ICD Management", "ICD_IT", "MIS",
            "Executive", "Document Print", "Customer Enquiry", "Transport Expense", "File Handling",
            "Sales Coordinator", "Manager", "Operations Manager", "Project", "AP Manager", "AP L2",
            "AP L1", "Expense Audit", "CRM", "Job Approval", "AP_Expense", "AP_Expense L2",
            "Cheque Audit", "Memo Audit", "AP_Freight", "AR", "Freight Operation", "KAM", "BD",
            "Marine", "Customs", "File Management", "Sales", "Consolidation", "C&F", "General Admin",
            "Export", "Import", "Transport HOD", "Billing_Job_Access", "AP_Transport",
            "Billing_Dispatch", "Billing_Scrutiny_Dispatch", "Billing_Scrutiny_HOD", "Freight",
            "User", "CRM_Admin", "CRM_AP_Access", "AP_Vitwo_Management", "AP_Vitwo_L1",
            "PN Movement Admin", "Billing_Current Job", "Assistant Role", "Presentation Role",
            "Transport_AP_Audit", "Stamp_Duty", "Transport and Vendor AP Access", "IT_Developer",
            "Blank Cheque Update", "Invoice_Tracking", "Customer_Implant", "Checklist_JOb_Opening",
            "Contract_Role", "Maintenance Transport_Exp", "EC User", "Warehouse User", "Project User",
            "Marine User", "Implant_Fujifilms", "CRM_TransAP", "Role For Vitwo", "CRM_Freight",
            "Branch_DO", "Payment-Credit Vendor Memo", "Transport AP Module L1 and L2 and Memo",
            "Project_Operation", "Credit Control HOD", "Training", "Dubai"
        };

        foreach (var roleName in roleNames)
        {
            if (!await roleManager.RoleExistsAsync(roleName))
            {
                await roleManager.CreateAsync(new IdentityRole(roleName));
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
                FirstName = "QA",
                LastName = "User",
                Department = "Quality Assurance",
                JoinDate = DateTime.UtcNow,
                IsActive = true
            };

            var result = await userManager.CreateAsync(qaUser, "QA123!");
            if (result.Succeeded)
            {
                await userManager.AddToRoleAsync(qaUser, "QA");
            }
        }
    }

    private static async Task SeedModules(ApplicationDbContext context)
    {
        // Check if modules already exist
        if (await context.Modules.AnyAsync())
            return;

        try
        {
            // Read ERP modules from JSON file
            var jsonPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Data", "erp-modules.json");
            if (!File.Exists(jsonPath))
            {
                // Fallback: look in the project directory
                jsonPath = Path.Combine(Directory.GetCurrentDirectory(), "Data", "erp-modules.json");
            }
            
            if (!File.Exists(jsonPath))
            {
                Console.WriteLine($"Warning: erp-modules.json not found at {jsonPath}. Falling back to simple modules.");
                await SeedModulesFromSimpleData(context);
                return;
            }

            var jsonContent = await File.ReadAllTextAsync(jsonPath);
            var moduleData = JsonSerializer.Deserialize<List<ModuleJsonData>>(jsonContent, new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            });

            if (moduleData == null || !moduleData.Any())
            {
                Console.WriteLine("Warning: No module data found in ERP modules JSON file");
                await SeedModulesFromSimpleData(context);
                return;
            }

            var modules = new List<Module>();

            foreach (var moduleJson in moduleData)
            {
                var module = new Module
                {
                    Title = moduleJson.Title,
                    Description = moduleJson.Description,
                    Icon = moduleJson.Icon,
                    Category = moduleJson.Category,
                    Color = moduleJson.Color,
                    EstimatedTime = moduleJson.EstimatedTime,
                    Difficulty = moduleJson.Difficulty,
                    Prerequisites = moduleJson.Prerequisites?.ToArray() ?? Array.Empty<string>(),
                    LearningObjectives = moduleJson.LearningObjectives?.ToArray() ?? Array.Empty<string>(),
                    IsActive = moduleJson.IsActive,
                    Order = moduleJson.Order,
                    ErpModuleId = moduleJson.ErpModuleId,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };

                modules.Add(module);
            }

            await context.Modules.AddRangeAsync(modules);
            await context.SaveChangesAsync();

            Console.WriteLine($"Successfully seeded {modules.Count} ERP modules from JSON");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error seeding modules from ERP JSON: {ex.Message}");
            // Fallback to simple module seeding
            await SeedModulesFromSimpleData(context);
        }
    }

    private static async Task SeedModulesFromSimpleData(ApplicationDbContext context)
    {
        try
        {
            // Read simple modules from JSON file
            var jsonPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Data", "simple-modules.json");
            if (!File.Exists(jsonPath))
            {
                jsonPath = Path.Combine(Directory.GetCurrentDirectory(), "Data", "simple-modules.json");
            }
            
            if (!File.Exists(jsonPath))
            {
                Console.WriteLine($"Warning: simple-modules.json not found at {jsonPath}");
                return;
            }

            var jsonContent = await File.ReadAllTextAsync(jsonPath);
            var moduleData = JsonSerializer.Deserialize<List<SimpleModuleData>>(jsonContent, new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            });

            if (moduleData == null || !moduleData.Any())
            {
                Console.WriteLine("Warning: No module data found in simple modules JSON file");
                return;
            }

            var modules = new List<Module>();

            foreach (var moduleJson in moduleData)
            {
                var module = new Module
                {
                    Title = moduleJson.sName,
                    Description = $"Training module for {moduleJson.sName}",
                    Icon = "📚",
                    Category = "ERP Training",
                    Color = "#3B82F6",
                    EstimatedTime = "2 hours",
                    Difficulty = "Intermediate",
                    Prerequisites = Array.Empty<string>(),
                    LearningObjectives = new[] { $"Learn {moduleJson.sName} processes and procedures" },
                    IsActive = true,
                    Order = moduleJson.lId,
                    ErpModuleId = moduleJson.lId.ToString(),
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };

                modules.Add(module);
            }

            await context.Modules.AddRangeAsync(modules);
            await context.SaveChangesAsync();

            Console.WriteLine($"Successfully seeded {modules.Count} modules from simple JSON");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error seeding modules from simple JSON: {ex.Message}");
        }
    }

    private static async Task SeedModulesHardcoded(ApplicationDbContext context)
    {
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
                ErpModuleId = "IMP001",
                Sections = new List<Section>
                {
                    new Section
                    {
                        Title = "Import Fundamentals",
                        Description = "Basic concepts and terminology",
                        Order = 1,
                        IsActive = true,
                        ErpSectionId = "IMP001-SEC01",
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
                            }
                        }
                    }
                }
            }
        };

        await context.Modules.AddRangeAsync(modules);
        await context.SaveChangesAsync();
        Console.WriteLine("Successfully seeded hardcoded modules as fallback");
    }

    private static async Task SeedSections(ApplicationDbContext context)
    {
        // Check if sections already exist
        if (await context.Sections.AnyAsync())
            return;

        try
        {
            // Get existing modules to map sections to
            var modules = await context.Modules.ToListAsync();
            var moduleDict = modules
                .Where(m => !string.IsNullOrEmpty(m.ErpModuleId))
                .ToDictionary(m => m.ErpModuleId!, m => m);

            var allSections = new List<Section>();

            // Seed Module 1 sections
            await SeedModuleSections(context, "1", "module-1-sections.json", moduleDict, allSections);

            // Seed Module 2 sections
            await SeedModuleSections(context, "2", "module-2-sections.json", moduleDict, allSections);

            // Seed Module 3 sections
            await SeedModuleSections(context, "3", "module-3-sections.json", moduleDict, allSections);

            // Seed Module 4 sections
            await SeedModuleSections(context, "4", "module-4-sections.json", moduleDict, allSections);

            // Seed Module 5 sections
            await SeedModuleSections(context, "5", "module-5-sections.json", moduleDict, allSections);

            // Seed Module 6 sections
            await SeedModuleSections(context, "6", "module-6-sections.json", moduleDict, allSections);

            // Seed Module 8 sections
            await SeedModuleSections(context, "8", "module-8-sections.json", moduleDict, allSections);

            // Seed Module 9 sections
            await SeedModuleSections(context, "9", "module-9-sections.json", moduleDict, allSections);

            // Seed Module 10 sections
            await SeedModuleSections(context, "10", "module-10-sections.json", moduleDict, allSections);

            // Seed Module 11 sections
            await SeedModuleSections(context, "11", "module-11-sections.json", moduleDict, allSections);

            // Seed Module 12 sections
            await SeedModuleSections(context, "12", "module-12-sections.json", moduleDict, allSections);

            // Seed Module 15 sections
            await SeedModuleSections(context, "15", "module-15-sections.json", moduleDict, allSections);

            // Add more modules as you provide more JSON data
            // await SeedModuleSections(context, "7", "module-7-sections.json", moduleDict, allSections);

            if (allSections.Any())
            {
                await context.Sections.AddRangeAsync(allSections);
                await context.SaveChangesAsync();
                Console.WriteLine($"Successfully seeded {allSections.Count} sections from module-specific JSON files");
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error seeding sections from JSON: {ex.Message}");
            Console.WriteLine("Proceeding without section seeding...");
        }
    }

    private static async Task SeedModuleSections(
        ApplicationDbContext context, 
        string moduleErpId, 
        string jsonFileName,
        Dictionary<string, Module> moduleDict,
        List<Section> allSections)
    {
        try
        {
            // Find the JSON file for this module
            var jsonPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Data", jsonFileName);
            if (!File.Exists(jsonPath))
            {
                // Fallback: look in the project directory
                jsonPath = Path.Combine(Directory.GetCurrentDirectory(), "Data", jsonFileName);
            }
            
            if (!File.Exists(jsonPath))
            {
                Console.WriteLine($"Warning: {jsonFileName} not found for module {moduleErpId}");
                return;
            }

            var jsonContent = await File.ReadAllTextAsync(jsonPath);
            var sectionData = JsonSerializer.Deserialize<List<ModuleSectionData>>(jsonContent, new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            });

            if (sectionData == null || !sectionData.Any())
            {
                Console.WriteLine($"Warning: No section data found in {jsonFileName}");
                return;
            }

            // Find the corresponding module
            if (!moduleDict.ContainsKey(moduleErpId))
            {
                Console.WriteLine($"Warning: Module with ERP ID {moduleErpId} not found in database");
                return;
            }

            var module = moduleDict[moduleErpId];
            var orderCounter = 1;

            foreach (var item in sectionData)
            {
                allSections.Add(new Section
                {
                    Title = item.SectionName,
                    Description = $"Training section for {item.SectionName}",
                    ModuleId = module.Id,
                    Order = orderCounter++,
                    IsActive = true,
                    ErpSectionId = item.SectionId,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                });
            }

            Console.WriteLine($"Prepared {sectionData.Count} sections for module {moduleErpId}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error processing sections for module {moduleErpId}: {ex.Message}");
        }
    }
}

// JSON Data Transfer Classes for Module Seeding
public class ModuleJsonData
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Icon { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty;
    public string Color { get; set; } = string.Empty;
    public string EstimatedTime { get; set; } = string.Empty;
    public string Difficulty { get; set; } = string.Empty;
    public List<string> Prerequisites { get; set; } = new();
    public List<string> LearningObjectives { get; set; } = new();
    public bool IsActive { get; set; } = true;
    public int Order { get; set; }
    public string? ErpModuleId { get; set; }
    public List<SectionJsonData> Sections { get; set; } = new();
}

public class SectionJsonData
{
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public int Order { get; set; }
    public bool IsActive { get; set; } = true;
    public string? ErpSectionId { get; set; }
    public List<LessonJsonData> Lessons { get; set; } = new();
}

public class LessonJsonData
{
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Type { get; set; } = string.Empty; // Video, Document, Interactive, Quiz
    public string Duration { get; set; } = string.Empty;
    public int Order { get; set; }
    public bool IsActive { get; set; } = true;
    public string? VideoUrl { get; set; }
    public string? DocumentContent { get; set; }
    public string? ScribeLink { get; set; }
    public List<string> InteractiveSteps { get; set; } = new();
    public bool HasAssessment { get; set; }
}

public class SimpleModuleData
{
    public int lId { get; set; }
    public string sName { get; set; } = string.Empty;
}

public class SimpleSectionData
{
    public int SectionId { get; set; }
    public string SectionName { get; set; } = string.Empty;
    public int ModuleId { get; set; }
}

public class ModuleSectionData
{
    public string lModuleId { get; set; } = string.Empty;
    public string SectionId { get; set; } = string.Empty;
    public string SectionName { get; set; } = string.Empty;
}
