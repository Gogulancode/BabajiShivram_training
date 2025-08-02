using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ERPTraining.Core.DTOs;
using ERPTraining.Core.Interfaces;
using ERPTraining.Core.Entities;
using ERPTraining.Infrastructure.Data;

namespace ERPTraining.API.Controllers;

[ApiController]
[Route("api/[controller]")]
// [Authorize(Roles = "Admin,Super Admin")] // Temporarily commented for testing
public class RoleAccessController : ControllerBase
{
    private readonly IRoleAccessService _roleAccessService;

    public RoleAccessController(IRoleAccessService roleAccessService)
    {
        _roleAccessService = roleAccessService;
    }

    /// <summary>
    /// Get all role access mappings
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<IEnumerable<RoleAccessDto>>> GetAllRoleAccess()
    {
        var roleAccess = await _roleAccessService.GetAllRoleAccessAsync();
        return Ok(roleAccess);
    }

    /// <summary>
    /// Get role access by role ID
    /// </summary>
    [HttpGet("role/{roleId}")]
    public async Task<ActionResult<IEnumerable<RoleAccessDto>>> GetRoleAccessByRoleId(string roleId)
    {
        var roleAccess = await _roleAccessService.GetRoleAccessByRoleIdAsync(roleId);
        return Ok(roleAccess);
    }

    /// <summary>
    /// Get modules with sections and access status for a specific role
    /// </summary>
    [HttpGet("role/{roleId}/modules-sections")]
    public async Task<ActionResult<IEnumerable<ModuleWithSectionsDto>>> GetModulesWithSectionsForRole(string roleId)
    {
        var modulesWithSections = await _roleAccessService.GetModulesWithSectionsForRoleAsync(roleId);
        return Ok(modulesWithSections);
    }

    /// <summary>
    /// Get all roles with their access summary
    /// </summary>
    [HttpGet("roles-summary")]
    public async Task<ActionResult<IEnumerable<RoleWithAccessDto>>> GetRolesWithAccess()
    {
        var rolesWithAccess = await _roleAccessService.GetRolesWithAccessAsync();
        return Ok(rolesWithAccess);
    }

    /// <summary>
    /// Update role access for a specific role
    /// </summary>
    [HttpPut("role/{roleId}")]
    public async Task<ActionResult> UpdateRoleAccess(string roleId, [FromBody] UpdateRoleAccessDto updateRoleAccessDto)
    {
        try
        {
            var success = await _roleAccessService.UpdateRoleAccessAsync(roleId, updateRoleAccessDto);
            
            if (success)
            {
                return Ok(new { message = "Role access updated successfully" });
            }
            
            return BadRequest(new { message = "Failed to update role access" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Internal server error", error = ex.Message });
        }
    }

    /// <summary>
    /// Bulk update role access for multiple roles
    /// </summary>
    [HttpPut("bulk-update")]
    public async Task<ActionResult> BulkUpdateRoleAccess([FromBody] List<BulkRoleAccessDto> bulkRoleAccessDtos)
    {
        var success = await _roleAccessService.BulkUpdateRoleAccessAsync(bulkRoleAccessDtos);
        
        if (success)
        {
            return Ok(new { message = "Bulk role access updated successfully" });
        }
        
        return BadRequest(new { message = "Failed to update bulk role access" });
    }

    /// <summary>
    /// Check if a user has access to a specific section
    /// </summary>
    [HttpGet("check-access")]
    [AllowAnonymous] // Allow authenticated users to check their own access
    public async Task<ActionResult<bool>> CheckAccess([FromQuery] string userId, [FromQuery] int moduleId, [FromQuery] int sectionId)
    {
        var hasAccess = await _roleAccessService.HasAccessToSectionAsync(userId, moduleId, sectionId);
        return Ok(new { hasAccess });
    }

    /// <summary>
    /// Get all roles - temporary for testing
    /// </summary>
    [HttpGet("test-roles")]
    public async Task<ActionResult> GetAllRoles()
    {
        var roles = await _roleAccessService.GetAllRolesAsync();
        return Ok(roles);
    }

    /// <summary>
    /// Test sections - temporary for testing
    /// </summary>
    [HttpGet("test-simple")]
    public async Task<ActionResult> TestSimpleInsert()
    {
        try
        {
            // Direct database context test without service layer
            using var scope = HttpContext.RequestServices.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
            
            // Test simple insert
            var testAccess = new RoleModuleAccess
            {
                RoleId = "028ac3af-0917-425d-8688-1db0b3cbf2bd",
                ModuleId = 22,
                SectionId = null, // Test with null section
                IsActive = true,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
            
            context.RoleModuleAccess.Add(testAccess);
            await context.SaveChangesAsync();
            
            return Ok(new { success = true, message = "Direct insert successful", id = testAccess.Id });
        }
        catch (Exception ex)
        {
            return Ok(new { success = false, error = ex.Message, stackTrace = ex.StackTrace });
        }
    }

    /// <summary>
    /// Seed role module section data from the provided mapping
    /// </summary>
    [HttpPost("seed-data")]
    public async Task<ActionResult> SeedRoleModuleSectionData()
    {
        try
        {
            var success = await _roleAccessService.SeedRoleModuleSectionDataAsync();
            
            if (success)
            {
                return Ok(new { success = true, message = "Role module section data seeded successfully. Admin role now has access to all 70 ERP sections." });
            }
            else
            {
                return Conflict(new { success = false, message = "Role module section data already exists or seeding failed." });
            }
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { success = false, message = "An error occurred while seeding data.", error = ex.Message, stackTrace = ex.StackTrace });
        }
    }

    /// <summary>
    /// Manually seed Operations-Sea role with specific permissions
    /// </summary>
    [HttpPost("seed-operations-sea")]
    public async Task<ActionResult> SeedOperationsSeaRole()
    {
        try
        {
            var operationsSeaRoleId = "421d70ba-b799-4b6f-b4bf-41fcda2bb361";
            
            // Check if role already has permissions
            var existingAccess = await _roleAccessService.GetRoleAccessByRoleIdAsync(operationsSeaRoleId);
            if (existingAccess.Any())
            {
                return Ok(new { success = true, message = $"Operations-Sea role already has {existingAccess.Count()} permissions assigned." });
            }

            // Define the operations data as per Role 10 mapping
            var operationsAccessData = new List<(int moduleId, int sectionId, string sectionName)>
            {
                (1, 305, "Checklist Verification IN"),
                (1, 307, "Audit Rejected"),
                (1, 308, "Under Noting"),
                (1, 516, "User Report"),
                (1, 517, "View User Report"),
                (1, 318, "Job Tracking"),
                (1, 333, "Job Archive"),
                (1, 304, "Checklist Preparation"),
                (1, 340, "Other Job"),
                (1, 605, "Billing Advice"),
                (1, 360, "Task Request"),
                (1, 361, "Customer Task Request"),
                (1, 362, "Pending Task"),
                (1, 363, "Completed Task List"),
                (1, 344, "Provisional BE"),
                (1, 519, "Checklist KPI"),
                (1, 521, "BOE KPI"),
                (1, 401, "My Detail"),
                (1, 312, "1st Check Examine"),
                (1, 311, "Under Passing"),
                (4, 3001, "Service Request"),
                (4, 3021, "KPI"),
                (4, 3040, "Circular"),
                (4, 3041, "Circular"),
                (4, 7001, "Manpower Requisition")
            };

            // Use the database context directly for manual insert
            using var scope = HttpContext.RequestServices.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

            var insertCount = 0;
            foreach (var (moduleId, sectionId, sectionName) in operationsAccessData)
            {
                // Check if this specific access already exists
                var exists = await context.RoleModuleAccess.AnyAsync(rma => 
                    rma.RoleId == operationsSeaRoleId && 
                    rma.ModuleId == moduleId && 
                    rma.SectionId == sectionId);

                if (!exists)
                {
                    var roleAccess = new RoleModuleAccess
                    {
                        RoleId = operationsSeaRoleId,
                        ModuleId = moduleId,
                        SectionId = sectionId,
                        IsActive = true,
                        ErpRoleId = "10",
                        ErpModuleId = moduleId.ToString(),
                        ErpSectionId = sectionId.ToString(),
                        CreatedAt = DateTime.UtcNow,
                        UpdatedAt = DateTime.UtcNow
                    };
                    
                    context.RoleModuleAccess.Add(roleAccess);
                    insertCount++;
                }
            }

            await context.SaveChangesAsync();

            return Ok(new { success = true, message = $"Successfully assigned {insertCount} permissions to Operations-Sea role. Total permissions: {operationsAccessData.Count}" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { success = false, message = "An error occurred while seeding Operations-Sea role.", error = ex.Message, stackTrace = ex.StackTrace });
        }
    }
}
