using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Identity;
using ERPTraining.Core.Entities;
using ERPTraining.Core.Interfaces;
using ERPTraining.Infrastructure.Data;
using System.Text.Json;

namespace ERPTraining.Infrastructure.Services;

public class RoleImportService : IRoleImportService
{
    private readonly ApplicationDbContext _context;
    private readonly UserManager<User> _userManager;
    private readonly RoleManager<IdentityRole> _roleManager;

    public RoleImportService(
        ApplicationDbContext context,
        UserManager<User> userManager,
        RoleManager<IdentityRole> roleManager)
    {
        _context = context;
        _userManager = userManager;
        _roleManager = roleManager;
    }

    public async Task<bool> ImportRolesFromJsonAsync(string jsonContent)
    {
        using var transaction = await _context.Database.BeginTransactionAsync();
        try
        {
            var roleImportData = JsonSerializer.Deserialize<RoleImportData>(jsonContent, new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            });

            if (roleImportData?.Roles == null || !roleImportData.Roles.Any())
            {
                Console.WriteLine("No roles found in import data");
                return false;
            }

            foreach (var roleData in roleImportData.Roles)
            {
                await ProcessRoleAsync(roleData);
            }

            await _context.SaveChangesAsync();
            await transaction.CommitAsync();
            Console.WriteLine($"Successfully imported {roleImportData.Roles.Count} roles");
            return true;
        }
        catch (Exception ex)
        {
            await transaction.RollbackAsync();
            Console.WriteLine($"Error importing roles: {ex.Message}");
            return false;
        }
    }

    private async Task ProcessRoleAsync(RoleImportDto roleData)
    {
        // Create or find the role in Identity
        var identityRole = await _roleManager.FindByNameAsync(roleData.RoleName);
        if (identityRole == null)
        {
            identityRole = new IdentityRole(roleData.RoleName);
            var result = await _roleManager.CreateAsync(identityRole);
            if (!result.Succeeded)
            {
                throw new Exception($"Failed to create role {roleData.RoleName}: {string.Join(", ", result.Errors.Select(e => e.Description))}");
            }
        }

        // Clear existing permissions for this role
        var existingAccess = await _context.RoleModuleAccess
            .Where(rma => rma.RoleId == identityRole.Id)
            .ToListAsync();
        _context.RoleModuleAccess.RemoveRange(existingAccess);

        // Add new permissions
        foreach (var moduleAccess in roleData.ModuleAccess)
        {
            await ProcessModuleAccessAsync(identityRole.Id, roleData.ErpRoleId, moduleAccess);
        }
    }

    private async Task ProcessModuleAccessAsync(string identityRoleId, string erpRoleId, ModuleAccessImportDto moduleAccess)
    {
        // Ensure module exists
        var module = await _context.Modules.FirstOrDefaultAsync(m => m.Id == moduleAccess.ModuleId);
        if (module == null)
        {
            Console.WriteLine($"Module {moduleAccess.ModuleId} not found, skipping");
            return;
        }

        // If no sections specified, give access to entire module
        if (moduleAccess.Sections == null || !moduleAccess.Sections.Any())
        {
            var roleModuleAccess = new RoleModuleAccess
            {
                RoleId = identityRoleId,
                ModuleId = moduleAccess.ModuleId,
                SectionId = null,
                SectionName = "Full Module Access",
                ErpRoleId = erpRoleId,
                ErpModuleId = moduleAccess.ModuleId.ToString(),
                ErpSectionId = null,
                CanView = true,
                CanEdit = moduleAccess.CanEdit,
                CanDelete = moduleAccess.CanDelete,
                IsActive = true,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
            _context.RoleModuleAccess.Add(roleModuleAccess);
            return;
        }

        // Add section-specific access
        foreach (var sectionAccess in moduleAccess.Sections)
        {
            // Find or create section
            var section = await _context.Sections.FirstOrDefaultAsync(s => s.Id == sectionAccess.SectionId);
            if (section == null)
            {
                // Create section if it doesn't exist
                section = new Section
                {
                    Id = sectionAccess.SectionId,
                    Title = sectionAccess.SectionName,
                    Description = sectionAccess.Description ?? sectionAccess.SectionName,
                    ModuleId = moduleAccess.ModuleId,
                    Order = sectionAccess.Order ?? 1,
                    IsActive = true,
                    ErpSectionId = sectionAccess.ErpSectionId,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };
                _context.Sections.Add(section);
                await _context.SaveChangesAsync(); // Save to get the ID
            }

            var roleModuleAccess = new RoleModuleAccess
            {
                RoleId = identityRoleId,
                ModuleId = moduleAccess.ModuleId,
                SectionId = section.Id,
                SectionName = section.Title,
                ErpRoleId = erpRoleId,
                ErpModuleId = moduleAccess.ModuleId.ToString(),
                ErpSectionId = sectionAccess.ErpSectionId,
                CanView = sectionAccess.CanView,
                CanEdit = sectionAccess.CanEdit,
                CanDelete = sectionAccess.CanDelete,
                IsActive = true,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
            _context.RoleModuleAccess.Add(roleModuleAccess);
        }
    }
}

// Data Transfer Objects for Import
public class RoleImportData
{
    public List<RoleImportDto> Roles { get; set; } = new();
}

public class RoleImportDto
{
    public string RoleName { get; set; } = string.Empty;
    public string ErpRoleId { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public List<ModuleAccessImportDto> ModuleAccess { get; set; } = new();
}

public class ModuleAccessImportDto
{
    public int ModuleId { get; set; }
    public string ModuleName { get; set; } = string.Empty;
    public bool CanEdit { get; set; } = false;
    public bool CanDelete { get; set; } = false;
    public List<SectionAccessImportDto>? Sections { get; set; } = new();
}

public class SectionAccessImportDto
{
    public int SectionId { get; set; }
    public string SectionName { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? ErpSectionId { get; set; }
    public int? Order { get; set; }
    public bool CanView { get; set; } = true;
    public bool CanEdit { get; set; } = false;
    public bool CanDelete { get; set; } = false;
}
