using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Identity;
using ERPTraining.Core.DTOs;
using ERPTraining.Core.Entities;
using ERPTraining.Core.Interfaces;
using ERPTraining.Infrastructure.Data;

namespace ERPTraining.Infrastructure.Services;

public class RoleAccessService : IRoleAccessService
{
    private readonly ApplicationDbContext _context;
    private readonly UserManager<User> _userManager;
    private readonly RoleManager<IdentityRole> _roleManager;

    public RoleAccessService(
        ApplicationDbContext context,
        UserManager<User> userManager,
        RoleManager<IdentityRole> roleManager)
    {
        _context = context;
        _userManager = userManager;
        _roleManager = roleManager;
    }

    public async Task<IEnumerable<RoleAccessDto>> GetRoleAccessByRoleIdAsync(string roleId)
    {
        var roleAccess = await _context.RoleModuleAccess
            .Include(rma => rma.Module)
            .Include(rma => rma.Section)
            .Where(rma => rma.RoleId == roleId)
            .Select(rma => new RoleAccessDto
            {
                Id = rma.Id,
                RoleId = rma.RoleId,
                ModuleId = rma.ModuleId,
                ModuleName = rma.Module.Title,
                SectionId = rma.SectionId ?? 0,
                SectionName = rma.Section != null ? rma.Section.Title : "",
                ErpRoleId = rma.ErpRoleId,
                ErpModuleId = rma.ErpModuleId,
                ErpSectionId = rma.ErpSectionId
            })
            .ToListAsync();

        // Add role name
        var role = await _roleManager.FindByIdAsync(roleId);
        foreach (var access in roleAccess)
        {
            access.RoleName = role?.Name ?? "";
        }

        return roleAccess;
    }

    public async Task<IEnumerable<RoleAccessDto>> GetAllRoleAccessAsync()
    {
        var roleAccess = await _context.RoleModuleAccess
            .Include(rma => rma.Module)
            .Include(rma => rma.Section)
            .Select(rma => new RoleAccessDto
            {
                Id = rma.Id,
                RoleId = rma.RoleId,
                ModuleId = rma.ModuleId,
                ModuleName = rma.Module.Title,
                SectionId = rma.SectionId ?? 0,
                SectionName = rma.Section != null ? rma.Section.Title : "",
                ErpRoleId = rma.ErpRoleId,
                ErpModuleId = rma.ErpModuleId,
                ErpSectionId = rma.ErpSectionId
            })
            .ToListAsync();

        // Add role names
        var roles = await _roleManager.Roles.ToListAsync();
        var roleDict = roles.ToDictionary(r => r.Id, r => r.Name);

        foreach (var access in roleAccess)
        {
            access.RoleName = roleDict.GetValueOrDefault(access.RoleId) ?? "";
        }

        return roleAccess;
    }

    public async Task<bool> UpdateRoleAccessAsync(string roleId, UpdateRoleAccessDto updateRoleAccessDto)
    {
        using var transaction = await _context.Database.BeginTransactionAsync();
        try
        {
            // Verify role exists
            var roleExists = await _roleManager.FindByIdAsync(roleId);
            if (roleExists == null)
            {
                Console.WriteLine($"Role {roleId} does not exist");
                return false; // Role doesn't exist
            }

            Console.WriteLine($"Role {roleId} exists, updating access");

            // Remove existing access for this role
            var existingAccess = await _context.RoleModuleAccess
                .Where(rma => rma.RoleId == roleId)
                .ToListAsync();

            Console.WriteLine($"Removing {existingAccess.Count} existing access records");
            _context.RoleModuleAccess.RemoveRange(existingAccess);

            // Add new access
            foreach (var moduleAccess in updateRoleAccessDto.ModuleAccess)
            {
                Console.WriteLine($"Processing module {moduleAccess.ModuleId} with {moduleAccess.SectionIds.Count} sections");
                
                if (moduleAccess.SectionIds.Count == 0)
                {
                    // Grant access to entire module if no specific sections
                    var roleModuleAccess = new RoleModuleAccess
                    {
                        RoleId = roleId,
                        ModuleId = moduleAccess.ModuleId,
                        SectionId = null // Full module access
                    };
                    _context.RoleModuleAccess.Add(roleModuleAccess);
                    Console.WriteLine($"Added full module access for module {moduleAccess.ModuleId}");
                }
                else
                {
                    foreach (var sectionId in moduleAccess.SectionIds)
                    {
                        var roleModuleAccess = new RoleModuleAccess
                        {
                            RoleId = roleId,
                            ModuleId = moduleAccess.ModuleId,
                            SectionId = sectionId
                        };

                        _context.RoleModuleAccess.Add(roleModuleAccess);
                        Console.WriteLine($"Added section access for module {moduleAccess.ModuleId}, section {sectionId}");
                    }
                }
            }

            Console.WriteLine("Saving changes to database");
            await _context.SaveChangesAsync();
            await transaction.CommitAsync();
            Console.WriteLine("Transaction committed successfully");
            return true;
        }
        catch (Exception ex)
        {
            await transaction.RollbackAsync();
            Console.WriteLine($"Error updating role access: {ex.Message}");
            Console.WriteLine($"Stack trace: {ex.StackTrace}");
            return false;
        }
    }

    public async Task<bool> BulkUpdateRoleAccessAsync(List<BulkRoleAccessDto> bulkRoleAccessDtos)
    {
        using var transaction = await _context.Database.BeginTransactionAsync();
        try
        {
            foreach (var roleAccess in bulkRoleAccessDtos)
            {
                // Remove existing access for this role
                var existingAccess = await _context.RoleModuleAccess
                    .Where(rma => rma.RoleId == roleAccess.RoleId)
                    .ToListAsync();

                _context.RoleModuleAccess.RemoveRange(existingAccess);

                // Add new access
                foreach (var moduleAccess in roleAccess.ModuleAccess)
                {
                    foreach (var sectionId in moduleAccess.SectionIds)
                    {
                        var roleModuleAccess = new RoleModuleAccess
                        {
                            RoleId = roleAccess.RoleId,
                            ModuleId = moduleAccess.ModuleId,
                            SectionId = sectionId
                        };

                        _context.RoleModuleAccess.Add(roleModuleAccess);
                    }
                }
            }

            await _context.SaveChangesAsync();
            await transaction.CommitAsync();
            return true;
        }
        catch
        {
            await transaction.RollbackAsync();
            return false;
        }
    }

    public async Task<IEnumerable<ModuleWithSectionsDto>> GetModulesWithSectionsForRoleAsync(string roleId)
    {
        var modules = await _context.Modules
            .Include(m => m.Sections)
            .OrderBy(m => m.Title)
            .ToListAsync();

        var roleAccess = await _context.RoleModuleAccess
            .Where(rma => rma.RoleId == roleId)
            .ToListAsync();

        var result = modules.Select(module => new ModuleWithSectionsDto
        {
            ModuleId = module.Id,
            ModuleName = module.Title,
            Sections = module.Sections.Select(section => new SectionAccessDto
            {
                SectionId = section.Id,
                SectionName = section.Title,
                HasAccess = roleAccess.Any(ra => ra.ModuleId == module.Id && ra.SectionId == section.Id)
            }).OrderBy(s => s.SectionName).ToList()
        }).ToList();

        return result;
    }

    public async Task<IEnumerable<RoleWithAccessDto>> GetRolesWithAccessAsync()
    {
        var roles = await _roleManager.Roles.ToListAsync();
        var modules = await _context.Modules.Include(m => m.Sections).ToListAsync();
        var allRoleAccess = await _context.RoleModuleAccess.ToListAsync();

        // Create role ID mapping (from RolesController)
        var roleIdMapping = new Dictionary<string, int>
        {
            {"Admin", -1}, {"QA", -2},
            {"HOD", 1}, {"IGM", 2}, {"Checklist Preparation", 3}, {"KAM Assistant-Air", 4},
            {"KAM Assistant-Sea", 5}, {"KAM-Sea", 6}, {"KAM-Air", 7}, {"Checklist Approval", 8},
            {"Delivery Order", 9}, {"Operations-Sea", 10}, {"Operations-Air", 11}, {"Transport", 12},
            {"Post Clearance Advice-Sea", 13}, {"Billing Scrutiny", 14}, {"Billing", 15}, {"Dispatch", 16},
            {"Billing HOD", 17}, {"Branch KAM", 18}, {"Post Clearance Advice-Branches", 19},
            {"Operations-Sea-Shed", 20}, {"Warehousing", 21}, {"Freight User", 22}, {"Feedback", 23},
            {"CFS", 24}, {"Reports", 25}, {"ITADMIN", 26}, {"Super Admin", 27}, {"Documentation", 28},
            {"Custom HOD", 29}, {"Express User", 30}, {"Sea Export", 31}, {"Quotation", 32},
            {"Air Export", 33}, {"Sea Import", 34}, {"Air Import", 35}, {"Consolidation Export", 36},
            {"Consolidation Import", 37}, {"Delete Approved", 38}, {"EDIT APPROVED ROLE", 39},
            {"Credit Vendor", 40}, {"Cheque Printing", 41}, {"Daily Collection and Charges", 42},
            {"Payment Audit", 43}, {"TDS Computation", 44}, {"Office Manager", 45}, {"Expense Scrutiny", 46},
            {"Expense HOD", 47}, {"Transport Operations", 48}, {"Vessel Management", 49},
            {"Transport_Accounts", 50}, {"CC_Reports", 51}, {"CC_Operations", 52}, {"CC_Collection", 53},
            {"CC_Upload", 54}, {"View", 55}, {"CC_Collection_Report", 56}, {"Billing Manager", 57},
            {"Post Clearance Advice-Air", 58}, {"ICD Management", 59}, {"ICD_IT", 60}, {"MIS", 61},
            {"Executive", 62}, {"Document Print", 63}, {"Customer Enquiry", 64}, {"Transport Expense", 65},
            {"File Handling", 66}, {"Sales Coordinator", 67}, {"Manager", 68}, {"Operations Manager", 69},
            {"Project", 70}, {"AP Manager", 71}, {"AP L2", 72}, {"AP L1", 73}, {"Expense Audit", 74},
            {"CRM", 75}, {"Job Approval", 76}, {"AP_Expense", 77}, {"AP_Expense L2", 78},
            {"Cheque Audit", 79}, {"Memo Audit", 80}, {"AP_Freight", 81}, {"AR", 82},
            {"Freight Operation", 83}, {"KAM", 84}, {"BD", 85}, {"Marine", 86}, {"Customs", 87},
            {"File Management", 88}, {"Sales", 89}, {"Consolidation", 90}, {"C&F", 91},
            {"General Admin", 92}, {"Export", 93}, {"Import", 94}, {"Transport HOD", 95},
            {"Billing_Job_Access", 96}, {"AP_Transport", 97}, {"Billing_Dispatch", 98},
            {"Billing_Scrutiny_Dispatch", 99}, {"Billing_Scrutiny_HOD", 100}, {"Freight", 101},
            {"User", 103}, {"CRM_Admin", 104}, {"CRM_AP_Access", 105}, {"AP_Vitwo_Management", 106},
            {"AP_Vitwo_L1", 107}, {"PN Movement Admin", 108}, {"Billing_Current Job", 109},
            {"Assistant Role", 110}, {"Presentation Role", 111}, {"Transport_AP_Audit", 112},
            {"Stamp_Duty", 113}, {"Transport and Vendor AP Access", 114}, {"IT_Developer", 115},
            {"Blank Cheque Update", 116}, {"Invoice_Tracking", 117}, {"Customer_Implant", 118},
            {"Checklist_JOb_Opening", 119}, {"Contract_Role", 120}, {"Maintenance Transport_Exp", 121},
            {"EC User", 122}, {"Warehouse User", 123}, {"Project User", 124}, {"Marine User", 125},
            {"Implant_Fujifilms", 126}, {"CRM_TransAP", 127}, {"Role For Vitwo", 128},
            {"CRM_Freight", 129}, {"Branch_DO", 130}, {"Payment-Credit Vendor Memo", 131},
            {"Transport AP Module L1 and L2 and Memo", 132}, {"Project_Operation", 133},
            {"Credit Control HOD", 134}, {"Training", 135}, {"Dubai", 136}
        };

        var result = roles.Select(role => new RoleWithAccessDto
        {
            RoleId = role.Id,
            RoleName = role.Name ?? "",
            OriginalRoleId = roleIdMapping.ContainsKey(role.Name ?? "") ? roleIdMapping[role.Name ?? ""] : null,
            ModuleAccess = modules.Select(module => new ModuleAccessSummaryDto
            {
                ModuleId = module.Id,
                ModuleName = module.Title,
                TotalSections = module.Sections.Count,
                AccessibleSections = allRoleAccess.Count(ra => ra.RoleId == role.Id && ra.ModuleId == module.Id),
                AccessibleSectionNames = module.Sections
                    .Where(s => allRoleAccess.Any(ra => ra.RoleId == role.Id && ra.ModuleId == module.Id && ra.SectionId == s.Id))
                    .Select(s => s.Title)
                    .ToList()
            }).ToList()
        }).ToList();

        return result;
    }

    public async Task<bool> HasAccessToSectionAsync(string userId, int moduleId, int sectionId)
    {
        var user = await _userManager.FindByIdAsync(userId);
        if (user == null) return false;

        var userRoles = await _userManager.GetRolesAsync(user);
        
        foreach (var roleName in userRoles)
        {
            var role = await _roleManager.FindByNameAsync(roleName);
            if (role != null)
            {
                var hasAccess = await _context.RoleModuleAccess
                    .AnyAsync(rma => rma.RoleId == role.Id && rma.ModuleId == moduleId && rma.SectionId == sectionId);
                
                if (hasAccess) return true;
            }
        }

        return false;
    }

    public async Task<IEnumerable<object>> GetAllRolesAsync()
    {
        var roles = await _roleManager.Roles.Select(r => new { r.Id, r.Name }).ToListAsync();
        return roles;
    }

    public async Task<bool> SeedRoleModuleSectionDataAsync()
    {
        using var transaction = await _context.Database.BeginTransactionAsync();
        try
        {
            // Check if data already exists for roles 1, 10, or 100
            var existingData = await _context.RoleModuleAccess
                .Where(rma => rma.ErpRoleId == "1" || rma.ErpRoleId == "10" || rma.ErpRoleId == "100")
                .AnyAsync();

            if (existingData)
            {
                Console.WriteLine("Role module section data already exists for roles 1, 10, or 100.");
                return false; // Data already seeded
            }

            // First, ensure we have a module with ID 1 or create it
            var module1 = await _context.Modules.FirstOrDefaultAsync(m => m.Id == 1);
            if (module1 == null)
            {
                module1 = new Module
                {
                    Title = "ERP Training Module",
                    Description = "Complete ERP Training Module with all functional areas",
                    Icon = "fas fa-graduation-cap",
                    Category = "ERP Training",
                    Color = "#3B82F6",
                    EstimatedTime = "50 hours",
                    Difficulty = "Intermediate",
                    IsActive = true,
                    Order = 1,
                    ErpModuleId = "1",
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };
                _context.Modules.Add(module1);
                await _context.SaveChangesAsync(); // Save to get the ID
            }

            // Ensure we have a module with ID 4 or create it
            var module4 = await _context.Modules.FirstOrDefaultAsync(m => m.Id == 4);
            if (module4 == null)
            {
                module4 = new Module
                {
                    Title = "HR & Administrative Module",
                    Description = "Human Resources and Administrative functions module",
                    Icon = "fas fa-users-cog",
                    Category = "HR & Admin",
                    Color = "#10B981",
                    EstimatedTime = "30 hours",
                    Difficulty = "Beginner",
                    IsActive = true,
                    Order = 4,
                    ErpModuleId = "4",
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };
                _context.Modules.Add(module4);
                await _context.SaveChangesAsync(); // Save to get the ID
            }

            // Ensure we have module 2 (Freight Operations)
            var module2 = await _context.Modules.FirstOrDefaultAsync(m => m.Id == 2);
            if (module2 == null)
            {
                module2 = new Module
                {
                    Title = "Freight Operations Module",
                    Description = "Import/Export freight operations and tracking",
                    Icon = "fas fa-shipping-fast",
                    Category = "Operations",
                    Color = "#F59E0B",
                    EstimatedTime = "40 hours",
                    Difficulty = "Intermediate",
                    IsActive = true,
                    Order = 2,
                    ErpModuleId = "2",
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };
                _context.Modules.Add(module2);
                await _context.SaveChangesAsync();
            }

            // Ensure we have module 3 (Transport & Billing)
            var module3 = await _context.Modules.FirstOrDefaultAsync(m => m.Id == 3);
            if (module3 == null)
            {
                module3 = new Module
                {
                    Title = "Transport & Billing Module",
                    Description = "Transportation and billing management",
                    Icon = "fas fa-truck",
                    Category = "Transport",
                    Color = "#EF4444",
                    EstimatedTime = "35 hours",
                    Difficulty = "Intermediate",
                    IsActive = true,
                    Order = 3,
                    ErpModuleId = "3",
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };
                _context.Modules.Add(module3);
                await _context.SaveChangesAsync();
            }

            // Ensure we have module 5 (Export Operations)
            var module5 = await _context.Modules.FirstOrDefaultAsync(m => m.Id == 5);
            if (module5 == null)
            {
                module5 = new Module
                {
                    Title = "Export Operations Module",
                    Description = "Export shipment processing and documentation",
                    Icon = "fas fa-plane-departure",
                    Category = "Export",
                    Color = "#8B5CF6",
                    EstimatedTime = "45 hours",
                    Difficulty = "Advanced",
                    IsActive = true,
                    Order = 5,
                    ErpModuleId = "5",
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };
                _context.Modules.Add(module5);
                await _context.SaveChangesAsync();
            }

            // Ensure we have module 9 (Financial Operations)
            var module9 = await _context.Modules.FirstOrDefaultAsync(m => m.Id == 9);
            if (module9 == null)
            {
                module9 = new Module
                {
                    Title = "Financial Operations Module",
                    Description = "Invoice processing and financial management",
                    Icon = "fas fa-dollar-sign",
                    Category = "Finance",
                    Color = "#059669",
                    EstimatedTime = "30 hours",
                    Difficulty = "Intermediate",
                    IsActive = true,
                    Order = 9,
                    ErpModuleId = "9",
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };
                _context.Modules.Add(module9);
                await _context.SaveChangesAsync();
            }

            // Ensure we have module 12 (Transport Service)
            var module12 = await _context.Modules.FirstOrDefaultAsync(m => m.Id == 12);
            if (module12 == null)
            {
                module12 = new Module
                {
                    Title = "Transport Service Module",
                    Description = "Specialized transport service operations",
                    Icon = "fas fa-route",
                    Category = "Transport Service",
                    Color = "#DC2626",
                    EstimatedTime = "40 hours",
                    Difficulty = "Advanced",
                    IsActive = true,
                    Order = 12,
                    ErpModuleId = "12",
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };
                _context.Modules.Add(module12);
                await _context.SaveChangesAsync();
            }

            // Find or create Admin role (Role ID 1)
            var adminRole = await _roleManager.FindByNameAsync("Admin");
            if (adminRole == null)
            {
                adminRole = new IdentityRole("Admin");
                await _roleManager.CreateAsync(adminRole);
            }

            // Find or create Operations role (Role ID 10)
            var operationsRole = await _roleManager.FindByNameAsync("Operations-Sea");
            if (operationsRole == null)
            {
                operationsRole = new IdentityRole("Operations-Sea");
                await _roleManager.CreateAsync(operationsRole);
            }

            // Find or create Super Admin role (Role ID 100)
            var superAdminRole = await _roleManager.FindByNameAsync("SuperAdmin");
            if (superAdminRole == null)
            {
                superAdminRole = new IdentityRole("SuperAdmin");
                await _roleManager.CreateAsync(superAdminRole);
            }

            // Define the role access data from your provided structure
            // Role 1 - Admin access to Module 1
            var role1ModuleSectionData = new List<(int RoleId, int ModuleId, int SectionId, string SectionName)>
            {
                (1, 1, 100, "User Setup"),
                (1, 1, 101, "BS User"),
                (1, 1, 102, "Department"),
                (1, 1, 103, "BS Group"),
                (1, 1, 104, "Branch"),
                (1, 1, 105, "Port"),
                (1, 1, 113, "Loading Port"),
                (1, 1, 106, "Access Role"),
                (1, 1, 107, "CFS Master"),
                (1, 1, 108, "Passing Stages"),
                (1, 1, 109, "Expense Type"),
                (1, 1, 110, "Job Type"),
                (1, 1, 111, "Package Type"),
                (1, 1, 112, "Status Master"),
                (1, 1, 200, "Customer Setup"),
                (1, 1, 202, "Customer"),
                (1, 1, 203, "Consignee"),
                (1, 1, 204, "Location"),
                (1, 1, 205, "Checklist Document"),
                (1, 1, 206, "Scheme Type"),
                (1, 1, 207, "Incoterms of Shipment"),
                (1, 1, 208, "Field Master"),
                (1, 1, 209, "Warehouse Master"),
                (1, 1, 210, "Customer Sector Master"),
                (1, 1, 211, "PCD Document Master"),
                (1, 1, 212, "Vehicle Master"),
                (1, 1, 300, "Operation"),
                (1, 1, 301, "Pre-Alert Received"),
                (1, 1, 302, "Job Creation"),
                (1, 1, 303, "IGM Awaited"),
                (1, 1, 304, "Checklist Preparation"),
                (1, 1, 305, "Checklist Verification IN"),
                (1, 1, 306, "Customer Checklist"),
                (1, 1, 307, "Audit Rejected"),
                (1, 1, 309, "DO Awaited"),
                (1, 1, 308, "Under Noting"),
                (1, 1, 310, "Duty Request"),
                (1, 1, 312, "1st Check Examine"),
                (1, 1, 311, "Under Passing"),
                (1, 1, 330, "Pending ADC/PHO"),
                (1, 1, 313, "Delivery Planning"),
                (1, 1, 320, "In General Warehouse"),
                (1, 1, 314, "Under Delivery"),
                (1, 1, 319, "Shipment Cleared"),
                (1, 1, 315, "Job Expense"),
                (1, 1, 317, "Job Activity"),
                (1, 1, 318, "Job Tracking"),
                (1, 1, 321, "Pending Document"),
                (1, 1, 322, "Admin Job Tracking"),
                (1, 1, 323, "Copy Job"),
                (1, 1, 324, "Edit invoice"),
                (1, 1, 329, "Inbond Jobs"),
                (1, 1, 400, "General/Administration"),
                (1, 1, 401, "My Detail"),
                (1, 1, 402, "Holiday List"),
                (1, 1, 500, "Reports"),
                (1, 1, 512, "Report"),
                (1, 1, 508, "MIS Port"),
                (1, 1, 509, "MIS Customer"),
                (1, 1, 510, "MIS Ageing"),
                (1, 1, 513, "Job Expenses Report"),
                (1, 1, 514, "Group User Report"),
                (1, 1, 516, "User Report"),
                (1, 1, 517, "View User Report"),
                (1, 1, 600, "Post Clearance"),
                (1, 1, 601, "PCA Document"),
                (1, 1, 605, "Billing Advice"),
                (1, 1, 606, "Billing Rejected"),
                (1, 1, 602, "Billing Scrutiny"),
                (1, 1, 603, "Billing Dept"),
                (1, 1, 604, "Dispatch Dept")
            };

            // Role 10 - Operations role with access to Modules 1 and 4
            var role10ModuleSectionData = new List<(int RoleId, int ModuleId, int SectionId, string SectionName)>
            {
                (10, 1, 305, "Checklist Verification IN"),
                (10, 1, 307, "Audit Rejected"),
                (10, 1, 308, "Under Noting"),
                (10, 1, 516, "User Report"),
                (10, 1, 517, "View User Report"),
                (10, 1, 318, "Job Tracking"),
                (10, 1, 333, "Job Archive"),
                (10, 1, 304, "Checklist Preparation"),
                (10, 1, 340, "Other Job"),
                (10, 1, 605, "Billing Advice"),
                (10, 1, 360, "Task Request"),
                (10, 1, 361, "Customer Task Request"),
                (10, 1, 362, "Pending Task"),
                (10, 1, 363, "Completed Task List"),
                (10, 1, 344, "Provisional BE"),
                (10, 1, 519, "Checklist KPI"),
                (10, 1, 521, "BOE KPI"),
                (10, 1, 401, "My Detail"),
                (10, 1, 312, "1st Check Examine"),
                (10, 1, 311, "Under Passing"),
                (10, 4, 3001, "Service Request"),
                (10, 4, 3021, "KPI"),
                (10, 4, 3040, "Circular"),
                (10, 4, 3041, "Circular"),
                (10, 4, 7001, "Manpower Requisition")
            };

            // Role 100 - Super Admin with comprehensive access (126 sections across 7 modules)
            var role100ModuleSectionData = new List<(int RoleId, int ModuleId, int SectionId, string SectionName)>
            {
                // Module 1 - Core Operations (26 sections)
                (100, 1, 318, "Job Tracking"),
                (100, 1, 333, "Job Archive"),
                (100, 1, 302, "Job Creation"),
                (100, 1, 303, "IGM Awaited"),
                (100, 1, 304, "Checklist Preparation"),
                (100, 1, 305, "Checklist Verification"),
                (100, 1, 307, "Audit Rejected"),
                (100, 1, 309, "DO Awaited"),
                (100, 1, 308, "Under Noting"),
                (100, 1, 310, "Duty Request"),
                (100, 1, 312, "1st Check Examine"),
                (100, 1, 311, "Under Passing"),
                (100, 1, 330, "Pending ADC/PHO"),
                (100, 1, 341, "Pending OOC"),
                (100, 1, 314, "Under Delivery"),
                (100, 1, 320, "In General Warehouse"),
                (100, 1, 3013, "FA Current Job"),
                (100, 1, 345, "Cancelled Job"),
                (100, 1, 516, "User Report"),
                (100, 1, 517, "View User Report"),
                (100, 1, 601, "PCA Document"),
                (100, 1, 605, "Billing Advice"),
                (100, 1, 618, "LR Pending"),
                (100, 1, 604, "Dispatch Dept - Billing"),
                (100, 1, 1024, "Pending Bill Dispatch"),
                (100, 1, 315, "Job Expense"),

                // Module 2 - Freight Operations (19 sections)
                (100, 2, 1017, "Tracking"),
                (100, 2, 6016, "Tracking"),
                (100, 2, 1001, "Freight Tracking"),
                (100, 2, 1002, "Freight Executed"),
                (100, 2, 1004, "Freight Awarded"),
                (100, 2, 1010, "Import Operation"),
                (100, 2, 1011, "Awaiting Booking"),
                (100, 2, 1012, "Agent PreAlert"),
                (100, 2, 1013, "Customer PreAlert"),
                (100, 2, 1014, "Cargo Arrival Notice"),
                (100, 2, 1015, "Delivery Order"),
                (100, 2, 1019, "Billing Advice"),
                (100, 2, 1025, "Bill Status"),
                (100, 2, 6010, "Export Operation"),
                (100, 2, 6015, "Awaiting Booking"),
                (100, 2, 6011, "Operation"),
                (100, 2, 6012, "VGM-Form13"),
                (100, 2, 6013, "Cust PreAlert"),
                (100, 2, 6014, "Shipped Onboard"),

                // Module 3 - Transport & Billing (18 sections)
                (100, 3, 2043, "Bill Tracking"),
                (100, 3, 2032, "Request Received"),
                (100, 3, 2035, "Movement"),
                (100, 3, 2047, "Job Tracking"),
                (100, 3, 2078, "Eway Bill Request"),
                (100, 3, 2079, "Show Eway Bill"),
                (100, 3, 2080, "Update Part B"),
                (100, 3, 2090, "Eway Tracking"),
                (100, 3, 4704, "Pending Bill"),
                (100, 3, 4708, "Bill Received"),
                (100, 3, 4710, "Bill Rejected"),
                (100, 3, 4715, "Payment Report"),
                (100, 3, 4716, "Tracking"),
                (100, 3, 2050, "Vehicle Placed"),
                (100, 3, 2081, "Cancel EWay Bill"),
                (100, 3, 2082, "Reject EWay Bill"),
                (100, 3, 2083, "Extend Validity"),

                // Module 4 - Admin & HR (2 sections)
                (100, 4, 3085, "Admin Expense"),
                (100, 4, 3086, "Maintenance Expense"),

                // Module 5 - Export Operations (15 sections)
                (100, 5, 4011, "Shipment Tracking"),
                (100, 5, 4001, "Job Creation"),
                (100, 5, 4002, "SB Preparation"),
                (100, 5, 4003, "SB Filing"),
                (100, 5, 4009, "Warehouse"),
                (100, 5, 4014, "Customer Transport"),
                (100, 5, 4004, "Custom Process"),
                (100, 5, 4005, "Form 13"),
                (100, 5, 4008, "Shipment Get In"),
                (100, 5, 4016, "Vehicle Request"),
                (100, 5, 4050, "Post Clearance"),
                (100, 5, 4051, "PCA Document"),
                (100, 5, 4052, "Billing Advice"),
                (100, 5, 4081, "User Reports"),
                (100, 5, 4082, "View User Reports"),

                // Module 9 - Financial Operations (9 sections)
                (100, 9, 3090, "Vendor Invoice"),
                (100, 9, 3091, "New Invoice"),
                (100, 9, 3094, "Invoice Rejected"),
                (100, 9, 3095, "Final Invoice Pending"),
                (100, 9, 30935, "Payment Receipt"),
                (100, 9, 3099, "Invoice Tracking"),
                (100, 9, 9052, "Cheque Issue"),
                (100, 9, 9053, "Cheque Invoice Submission"),
                (100, 9, 4620, "Tracking"),

                // Module 12 - Transport Service (18 sections)
                (100, 12, 309334, "Job Creation -TS"),
                (100, 12, 309335, "Request Received"),
                (100, 12, 309353, "Vehicle Placed"),
                (100, 12, 309351, "Dispatch - TS/FF"),
                (100, 12, 309338, "IN - Transit"),
                (100, 12, 309350, "Job Tracking"),
                (100, 12, 309378, "Pending Bill"),
                (100, 12, 309381, "Bill Rejected"),
                (100, 12, 309383, "Tracking"),
                (100, 12, 309384, "HOD Rejected"),
                (100, 12, 309362, "Eway Bill Request"),
                (100, 12, 309363, "Show Eway Bill"),
                (100, 12, 309364, "Update Part B"),
                (100, 12, 309365, "Cancel EWay Bill"),
                (100, 12, 309366, "Reject EWay Bill"),
                (100, 12, 309367, "Extend Validity"),
                (100, 12, 309371, "Multiple Vehicle"),
                (100, 12, 309372, "Eway Tracking")
            };

            // Combine all role data
            var allRoleModuleSectionData = new List<(int RoleId, int ModuleId, int SectionId, string SectionName)>();
            allRoleModuleSectionData.AddRange(role1ModuleSectionData);
            allRoleModuleSectionData.AddRange(role10ModuleSectionData);
            allRoleModuleSectionData.AddRange(role100ModuleSectionData);

            Console.WriteLine($"Starting to seed {allRoleModuleSectionData.Count} role module section mappings");
            Console.WriteLine($"Role 1: {role1ModuleSectionData.Count} sections");
            Console.WriteLine($"Role 10: {role10ModuleSectionData.Count} sections");
            Console.WriteLine($"Role 100: {role100ModuleSectionData.Count} sections");

            // Create sections and role access entries
            foreach (var (roleId, moduleId, sectionId, sectionName) in allRoleModuleSectionData)
            {
                // Get the appropriate module
                var targetModule = moduleId == 1 ? module1 : moduleId == 4 ? module4 : null;
                if (targetModule == null)
                {
                    Console.WriteLine($"Warning: Module {moduleId} not found, skipping section {sectionId}");
                    continue;
                }

                // Get the appropriate role
                var targetRole = roleId == 1 ? adminRole : 
                               roleId == 10 ? operationsRole : 
                               roleId == 100 ? superAdminRole : null;
                if (targetRole == null)
                {
                    Console.WriteLine($"Warning: Role {roleId} not found, skipping section {sectionId}");
                    continue;
                }

                // First, ensure the section exists or create it
                var section = await _context.Sections.FirstOrDefaultAsync(s => s.Id == sectionId);
                if (section == null)
                {
                    section = new Section
                    {
                        Id = sectionId,
                        Title = sectionName,
                        Description = $"ERP section for {sectionName}",
                        ModuleId = targetModule.Id,
                        Order = sectionId,
                        IsActive = true,
                        ErpSectionId = sectionId.ToString(),
                        CreatedAt = DateTime.UtcNow,
                        UpdatedAt = DateTime.UtcNow
                    };
                    _context.Sections.Add(section);
                }

                // Check if role access entry already exists
                var existingAccess = await _context.RoleModuleAccess
                    .FirstOrDefaultAsync(rma => rma.RoleId == targetRole.Id && 
                                               rma.ModuleId == targetModule.Id && 
                                               rma.SectionId == sectionId);

                if (existingAccess == null)
                {
                    // Create role access entry
                    var roleAccess = new RoleModuleAccess
                    {
                        RoleId = targetRole.Id, // Use the actual Role ID from Identity
                        ModuleId = targetModule.Id,
                        SectionId = sectionId,
                        SectionName = sectionName,
                        ErpRoleId = roleId.ToString(), // Your original role ID from the data
                        ErpModuleId = moduleId.ToString(), // Your original module ID from the data
                        ErpSectionId = sectionId.ToString(),
                        CanView = true,
                        CanEdit = roleId == 1 || roleId == 100, // Admin and Super Admin can edit, Operations can only view
                        CanDelete = roleId == 100, // Only Super Admin can delete
                        IsActive = true,
                        CreatedAt = DateTime.UtcNow,
                        UpdatedAt = DateTime.UtcNow
                    };

                    _context.RoleModuleAccess.Add(roleAccess);
                }
            }

            await _context.SaveChangesAsync();
            await transaction.CommitAsync();

            Console.WriteLine($"Successfully seeded {allRoleModuleSectionData.Count} role module section mappings");
            Console.WriteLine("Roles seeded:");
            Console.WriteLine("- Admin (Role 1): Access to Module 1 with 70 sections");
            Console.WriteLine("- Operations-Sea (Role 10): Access to Module 1 (20 sections) and Module 4 (5 sections)");
            return true;
        }
        catch (Exception ex)
        {
            await transaction.RollbackAsync();
            Console.WriteLine($"Error seeding role module section data: {ex.Message}");
            Console.WriteLine($"Stack trace: {ex.StackTrace}");
            return false;
        }
    }
}
